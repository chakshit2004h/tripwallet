import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../trips/data/supabase_trips_service.dart';

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

  String _formatDates(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Active trip';
    const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    if (start.month == end.month) {
      return '${start.day}–${end.day} ${months[start.month - 1]}';
    }
    return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<LocalTrip?>(
      stream: (db.select(db.localTrips)..where((t) => t.id.equals(tripId))).watchSingleOrNull(),
      builder: (context, tripSnapshot) {
        final trip = tripSnapshot.data;
        final tripName = trip?.name ?? 'Trip';
        final tripDates = _formatDates(trip?.startDate, trip?.endDate);

        return StreamBuilder<List<LocalMember>>(
          stream: (db.select(db.localMembers)..where((m) => m.tripId.equals(tripId))).watch(),
          builder: (context, memberSnapshot) {
            final members = memberSnapshot.data ?? [];
            final memberCount = members.isNotEmpty ? members.length : 1;

            return StreamBuilder<List<LocalExpense>>(
              stream: (db.select(db.localExpenses)..where((e) => e.tripId.equals(tripId))).watch(),
              builder: (context, expSnapshot) {
                final expenses = expSnapshot.data ?? [];
                final totalMinor = expenses.fold<int>(0, (sum, e) => sum + e.amountMinor);
                final totalSpent = (totalMinor / 100).toStringAsFixed(0);

                // Group expenses by category derived from title
                final catTotals = <String, int>{};
                for (final e in expenses) {
                  final titleLower = e.title.toLowerCase();
                  String cat = 'General';
                  if (titleLower.contains('food') || titleLower.contains('dinner') || titleLower.contains('lunch') || titleLower.contains('drink') || titleLower.contains('cafe') || titleLower.contains('restaurant')) {
                    cat = 'Food & drink';
                  } else if (titleLower.contains('hotel') || titleLower.contains('resort') || titleLower.contains('stay') || titleLower.contains('villa') || titleLower.contains('airbnb')) {
                    cat = 'Stay';
                  } else if (titleLower.contains('cab') || titleLower.contains('taxi') || titleLower.contains('uber') || titleLower.contains('scooter') || titleLower.contains('flight') || titleLower.contains('fuel')) {
                    cat = 'Transport';
                  } else if (titleLower.contains('ticket') || titleLower.contains('surf') || titleLower.contains('tour') || titleLower.contains('boat')) {
                    cat = 'Activities';
                  }
                  catTotals[cat] = (catTotals[cat] ?? 0) + e.amountMinor;
                }

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
                      Text('$tripName · $tripDates', style: AppTypography.caption),
                      const SizedBox(height: 16),

                      Text('₹$totalSpent', style: AppTypography.display.copyWith(fontSize: 32)),
                      const SizedBox(height: 2),
                      Text(
                        'total spent across $memberCount ${memberCount == 1 ? 'person' : 'people'}',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 24),

                      // Real category breakdown
                      if (catTotals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('No categorized expenses logged yet.', style: AppTypography.bodySmall),
                        )
                      else
                        ...catTotals.entries.map((entry) {
                          final categoryName = entry.key[0].toUpperCase() + entry.key.substring(1);
                          final amountFormatted = '₹${(entry.value / 100).toStringAsFixed(0)}';
                          return _buildCatRow(categoryName, amountFormatted);
                        }),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await (db.update(db.localTrips)..where((t) => t.id.equals(tripId))).write(
                              const LocalTripsCompanion(status: drift.Value('archived')),
                            );
                            try {
                              await ref.read(supabaseTripsServiceProvider).archiveTrip(tripId);
                            } catch (_) {}

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
