import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/trip_repository.dart';
import '../db/app_database.dart';
import '../domain/money.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ContentWidth extends StatelessWidget {
  final Widget child;
  const ContentWidth({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: child,
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: AppColors.coralTint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 36, color: AppColors.coralDark),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: AppTypography.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    ),
  );
}

IconData categoryIcon(String category) => switch (category) {
  'food' => Icons.restaurant_rounded,
  'stay' => Icons.bed_rounded,
  'transport' => Icons.directions_car_rounded,
  'activity' => Icons.explore_rounded,
  'shopping' => Icons.shopping_bag_outlined,
  _ => Icons.receipt_long_rounded,
};
String tripDates(LocalTrip trip) {
  if (trip.startDate == null) return 'Dates to be decided';
  final start = DateFormat('d MMM').format(trip.startDate!);
  return trip.endDate == null
      ? start
      : '$start – ${DateFormat('d MMM y').format(trip.endDate!)}';
}

class ExpenseTile extends StatelessWidget {
  final LocalExpense expense;
  final LedgerData data;
  const ExpenseTile({super.key, required this.expense, required this.data});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/expense/${expense.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.coralTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                categoryIcon(expense.category),
                size: 22,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: AppTypography.titleMedium),
                  const SizedBox(height: 5),
                  Text(
                    '${data.memberName(expense.paidByMemberId)} paid · ${DateFormat('d MMM').format(expense.createdAt)}',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(expense.amountMinor, expense.currency),
                    style: AppTypography.labelLarge,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.inkSoft,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTypography.titleLarge.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}
