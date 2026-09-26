import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Expense detail', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<LocalExpense?>(
        stream: (db.select(db.localExpenses)..where((e) => e.id.equals(expenseId))).watchSingleOrNull(),
        builder: (context, snapshot) {
          final expense = snapshot.data;
          final title = expense?.title ?? 'Beach shack dinner';
          final amount = expense != null ? '₹${(expense.amountMinor / 100).toStringAsFixed(0)}' : '₹4,800';
          final yourShare = expense != null ? '₹${((expense.amountMinor / 100) / 4).toStringAsFixed(0)}' : '₹1,325';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt box
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.receipt_long_rounded, color: AppColors.inkSoft, size: 32),
                  ),
                ),
                const SizedBox(height: 16),

                Text(title, style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Paid by ${expense?.paidByMemberId == 'm_you' ? 'You' : 'Aisha'} · split ${expense?.splitMethod ?? 'equal'}',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 20),

                _buildRow('Amount', amount),
                _buildRow('Your share', yourShare),

                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Expense edit enabled')),
                          );
                        },
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await (db.delete(db.localExpenses)..where((e) => e.id.equals(expenseId))).go();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Expense "$title" deleted!'),
                                backgroundColor: AppColors.coralDark,
                              ),
                            );
                            context.pop();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coralDark,
                          side: const BorderSide(color: Color(0xFFF2C9BE), width: 1.4),
                        ),
                        child: const Text('Delete', style: TextStyle(color: AppColors.coralDark, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.inkSoft)),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
