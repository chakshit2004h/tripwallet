import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../trips/data/supabase_trips_service.dart';

class TripSettingsScreen extends ConsumerWidget {
  final String tripId;

  const TripSettingsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Trip settings', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<LocalTrip?>(
        stream: (db.select(db.localTrips)..where((t) => t.id.equals(tripId))).watchSingleOrNull(),
        builder: (context, snapshot) {
          final trip = snapshot.data;
          final tripName = trip?.name ?? 'Goa weekend';
          final currency = '${trip?.baseCurrency ?? 'INR'} ₹';

          return StreamBuilder<List<LocalMember>>(
            stream: (db.select(db.localMembers)..where((m) => m.tripId.equals(tripId))).watch(),
            builder: (context, memberSnapshot) {
              final memberCount = memberSnapshot.data?.length ?? 4;

              return Column(
                children: [
                  _buildSettingRow('Trip name', tripName),
                  _buildSettingRow('Currency', currency),
                  _buildSettingRow('Members', '$memberCount'),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            await (db.update(db.localTrips)..where((t) => t.id.equals(tripId))).write(
                              const LocalTripsCompanion(status: drift.Value('archived')),
                            );
                            try {
                              await ref.read(supabaseTripsServiceProvider).archiveTrip(tripId);
                            } catch (_) {}

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Trip "$tripName" archived!'),
                                  backgroundColor: AppColors.ink,
                                ),
                              );
                              context.go('/trips');
                            }
                          },
                          child: const Text('Archive trip'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () async {
                            await (db.delete(db.localTrips)..where((t) => t.id.equals(tripId))).go();
                            await (db.delete(db.localExpenses)..where((e) => e.tripId.equals(tripId))).go();
                            await (db.delete(db.localMembers)..where((m) => m.tripId.equals(tripId))).go();
                            try {
                              await ref.read(supabaseTripsServiceProvider).deleteTrip(tripId);
                            } catch (_) {}

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Trip "$tripName" deleted!'),
                                  backgroundColor: AppColors.coralDark,
                                ),
                              );
                              context.go('/trips');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.coralDark,
                            side: const BorderSide(color: Color(0xFFF2C9BE), width: 1.4),
                          ),
                          child: const Text('Delete trip', style: TextStyle(color: AppColors.coralDark, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          Text(value, style: AppTypography.bodyMedium.copyWith(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}
