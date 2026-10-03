import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../data/supabase_expenses_service.dart';

class ManualExpenseScreen extends ConsumerStatefulWidget {
  final String tripId;

  const ManualExpenseScreen({super.key, required this.tripId});

  @override
  ConsumerState<ManualExpenseScreen> createState() => _ManualExpenseScreenState();
}

class _ManualExpenseScreenState extends ConsumerState<ManualExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _splitMethod = 'Equally';
  String _selectedPayerId = 'm_you';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    if (title.isEmpty || amountText.isEmpty) return;

    final amountNum = double.tryParse(amountText) ?? 0.0;
    final amountMinor = (amountNum * 100).toInt();

    final db = ref.read(databaseProvider);
    final expenseId = 'exp_${DateTime.now().millisecondsSinceEpoch}';

    await db.into(db.localExpenses).insert(
          LocalExpensesCompanion.insert(
            id: expenseId,
            tripId: widget.tripId,
            title: title,
            amountMinor: amountMinor,
            currency: 'INR',
            paidByMemberId: _selectedPayerId,
            splitMethod: drift.Value(_splitMethod.toLowerCase()),
          ),
        );

    try {
      final expenseService = ref.read(supabaseExpensesServiceProvider);
      await expenseService.addExpense(
        tripId: widget.tripId,
        title: title,
        amountMinor: amountMinor,
        category: 'other',
        currency: 'INR',
        paidByUserId: _selectedPayerId,
        splitMethod: _splitMethod.toLowerCase(),
      );
    } catch (e) {
      debugPrint('Supabase addExpense note: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense "$title" saved!'),
          backgroundColor: AppColors.ink,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Manual entry', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What was it for', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'e.g. Scooter rental, Groceries',
                ),
              ),
              const SizedBox(height: 16),

              Text('Amount', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text('₹', style: AppTypography.titleMedium.copyWith(color: AppColors.inkSoft)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text('Paid by', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              StreamBuilder<List<LocalMember>>(
                stream: (db.select(db.localMembers)..where((m) => m.tripId.equals(widget.tripId))).watch(),
                builder: (context, snapshot) {
                  final members = snapshot.data ?? [];
                  if (members.isNotEmpty && !members.any((m) => m.id == _selectedPayerId)) {
                    _selectedPayerId = members.first.id;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line, width: 1.4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPayerId,
                        isExpanded: true,
                        dropdownColor: AppColors.paper,
                        items: members.map((m) {
                          return DropdownMenuItem(
                            value: m.id,
                            child: Text(m.displayName, style: AppTypography.bodyMedium),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPayerId = val);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              Text('Split', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: ['Equally', 'By %', 'Exact'].map((opt) {
                  final isSelected = _splitMethod == opt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _splitMethod = opt),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.ink : AppColors.card,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected ? AppColors.ink : AppColors.line,
                            width: 1.4,
                          ),
                        ),
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
