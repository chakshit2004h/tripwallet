import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Alerts', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<LocalAlert>>(
        stream: db.select(db.localAlerts).watch(),
        builder: (context, snapshot) {
          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return Center(
              child: Text('No alerts yet', style: AppTypography.bodyMedium),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isCoral = alert.isCoral;

              IconData icon;
              if (alert.iconType == 'wallet') {
                icon = Icons.account_balance_wallet_outlined;
              } else if (alert.iconType == 'receipt') {
                icon = Icons.receipt_long_outlined;
              } else {
                icon = Icons.person_outline_rounded;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.line, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isCoral ? AppColors.coralTint : const Color(0xFFE1F5EE),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        icon,
                        color: isCoral ? AppColors.coral : AppColors.green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.title, style: AppTypography.bodyMedium.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(alert.timeAgo, style: AppTypography.caption.copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
