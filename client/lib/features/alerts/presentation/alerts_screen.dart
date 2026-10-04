import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class ActivityItem {
  final String id;
  final String title;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color badgeBg;
  final DateTime timestamp;

  ActivityItem({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.badgeBg,
    required this.timestamp,
  });
}

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Activity & Alerts', style: AppTypography.titleLarge),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<LocalExpense>>(
        stream: db.select(db.localExpenses).watch(),
        builder: (context, expSnapshot) {
          final expenses = expSnapshot.data ?? [];

          return StreamBuilder<List<LocalSettlement>>(
            stream: db.select(db.localSettlements).watch(),
            builder: (context, setSnapshot) {
              final settlements = setSnapshot.data ?? [];

              return StreamBuilder<List<LocalTrip>>(
                stream: db.select(db.localTrips).watch(),
                builder: (context, tripSnapshot) {
                  final trips = tripSnapshot.data ?? [];

                  return StreamBuilder<List<LocalAlert>>(
                    stream: db.select(db.localAlerts).watch(),
                    builder: (context, alertSnapshot) {
                      final rawAlerts = alertSnapshot.data ?? [];

                      // Aggregate into unified Activity timeline
                      final List<ActivityItem> activityTimeline = [];

                      // 1. From Expenses (Logs every bill added from small to small)
                      for (final exp in expenses) {
                        final formattedAmount = (exp.amountMinor / 100).toStringAsFixed(0);
                        activityTimeline.add(
                          ActivityItem(
                            id: 'exp_${exp.id}',
                            title: 'Added "${exp.title}" · ₹$formattedAmount',
                            timeAgo: _formatTimeAgo(exp.createdAt),
                            icon: Icons.receipt_long_outlined,
                            iconColor: AppColors.coral,
                            badgeBg: AppColors.coralTint,
                            timestamp: exp.createdAt,
                          ),
                        );
                      }

                      // 2. From Settlements (Logs every payment made)
                      for (final s in settlements) {
                        final formattedAmount = (s.amountMinor / 100).toStringAsFixed(0);
                        activityTimeline.add(
                          ActivityItem(
                            id: 'set_${s.id}',
                            title: 'Settled ₹$formattedAmount via ${s.method.toUpperCase()}',
                            timeAgo: _formatTimeAgo(s.createdAt),
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: AppColors.green,
                            badgeBg: const Color(0xFFE1F5EE),
                            timestamp: s.createdAt,
                          ),
                        );
                      }

                      // 3. From Trips (Logs trips joined or created)
                      for (final t in trips) {
                        activityTimeline.add(
                          ActivityItem(
                            id: 'trip_${t.id}',
                            title: 'Active in trip "${t.name}"',
                            timeAgo: _formatTimeAgo(t.updatedAt),
                            icon: Icons.flight_takeoff_rounded,
                            iconColor: AppColors.inkText,
                            badgeBg: AppColors.paper,
                            timestamp: t.updatedAt,
                          ),
                        );
                      }

                      // 4. From explicit localAlerts table
                      for (final a in rawAlerts) {
                        // Prevent duplicates if already present
                        if (!activityTimeline.any((it) => it.title == a.title)) {
                          IconData ic;
                          if (a.iconType == 'wallet') {
                            ic = Icons.account_balance_wallet_outlined;
                          } else if (a.iconType == 'receipt') {
                            ic = Icons.receipt_long_outlined;
                          } else {
                            ic = Icons.person_outline_rounded;
                          }

                          activityTimeline.add(
                            ActivityItem(
                              id: 'alt_${a.id}',
                              title: a.title,
                              timeAgo: a.timeAgo,
                              icon: ic,
                              iconColor: a.isCoral ? AppColors.coral : AppColors.green,
                              badgeBg: a.isCoral ? AppColors.coralTint : const Color(0xFFE1F5EE),
                              timestamp: a.createdAt,
                            ),
                          );
                        }
                      }

                      // Sort with newest on top
                      activityTimeline.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                      if (activityTimeline.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  color: AppColors.paper,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.bolt_rounded, color: AppColors.muted, size: 28),
                              ),
                              const SizedBox(height: 12),
                              Text('No activity yet', style: AppTypography.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                'Expenses, payments, and trip updates will appear here.',
                                style: AppTypography.caption.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: activityTimeline.length,
                        itemBuilder: (context, index) {
                          final item = activityTimeline[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.line, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: item.badgeBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.iconColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.timeAgo,
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 10.5,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
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
            },
          );
        },
      ),
    );
  }
}
