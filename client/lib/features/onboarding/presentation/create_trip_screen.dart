import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Goa Weekend 2026');
  final TextEditingController _dateController = TextEditingController(text: '12 Oct – 16 Oct');
  String _selectedCurrency = 'INR (₹)';

  final List<String> _currencies = [
    'INR (₹)',
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: Text('New Trip', style: AppTypography.titleMedium),
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
              // Dashed cover photo picker
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lineHeavy,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.coral, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add cover photo (optional)',
                        style: AppTypography.caption.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Trip Name
              Text('TRIP NAME', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
                decoration: const InputDecoration(
                  hintText: 'e.g. Goa Weekend, Tokyo 2026',
                  prefixIcon: Icon(Icons.beach_access_rounded, color: AppColors.coral),
                ),
              ),
              const SizedBox(height: 18),

              // Trip Dates
              Text('DATES', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
                decoration: const InputDecoration(
                  hintText: 'e.g. 12 Oct – 16 Oct',
                  prefixIcon: Icon(Icons.date_range_rounded, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 18),

              // Base Currency
              Text('DEFAULT CURRENCY', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _currencies.map((currency) {
                  final isSelected = _selectedCurrency == currency;
                  return ChoiceChip(
                    label: Text(currency),
                    selected: isSelected,
                    selectedColor: AppColors.coral.withOpacity(0.2),
                    backgroundColor: AppColors.paper,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.coral : AppColors.cream,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.coral : AppColors.line,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCurrency = currency);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Crew info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group_add_rounded, color: AppColors.coral, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1 member (You)', style: AppTypography.bodyMedium),
                          const SizedBox(height: 2),
                          Text(
                            'You will get a shareable QR and link to invite your crew right next.',
                            style: AppTypography.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create Trip CTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/invite');
                  },
                  child: const Text('Create Trip & Invite Crew', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
