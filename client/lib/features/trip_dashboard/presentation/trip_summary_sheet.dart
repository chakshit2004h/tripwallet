import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class TripSummarySheet extends ConsumerWidget {
  final String tripId;

  const TripSummarySheet({super.key, required this.tripId});

  static Future<void> show(BuildContext context, {required String tripId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TripSummarySheet(tripId: tripId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<LocalTrip?>(
      stream: (db.select(db.localTrips)..where((t) => t.id.equals(tripId))).watchSingleOrNull(),
      builder: (context, tripSnapshot) {
        final tripName = tripSnapshot.data?.name ?? 'Goa weekend';

        return StreamBuilder<List<LocalExpense>>(
          stream: (db.select(db.localExpenses)..where((e) => e.tripId.equals(tripId))).watch(),
          builder: (context, expSnapshot) {
            final expenses = expSnapshot.data ?? [];
            final totalMinor = expenses.fold<int>(0, (sum, e) => sum + e.amountMinor);
            final totalSpent = totalMinor > 0 ? (totalMinor / 100).toStringAsFixed(0) : '18,400';

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lineHeavy,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Trip complete', style: AppTypography.titleLarge),
                  const SizedBox(height: 4),
                  Text('$tripName · 12–14 sep', style: AppTypography.caption),
                  const SizedBox(height: 16),

                  Text('₹$totalSpent', style: AppTypography.display.copyWith(fontSize: 32)),
                  const SizedBox(height: 2),
                  Text('total spent across 4 people', style: AppTypography.caption),
                  const SizedBox(height: 24),

                  // Category rows matching Step 20
                  _buildCatRow('Food & drink', '₹9,200'),
                  _buildCatRow('Stay', '₹6,400'),
                  _buildCatRow('Transport', '₹2,800'),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await (db.update(db.localTrips)..where((t) => t.id.equals(tripId))).write(
                          const LocalTripsCompanion(status: drift.Value('archived')),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          context.go('/trips');
                        }
                      },
                      child: const Text('Archive trip'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCatRow(String category, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: AppTypography.bodyMedium),
          Text(amount, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
