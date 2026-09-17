import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../sync/sync_providers.dart';
import '../sync/sync_engine.dart';

class SyncStatusBanner extends ConsumerWidget {
  final String tripId;

  const SyncStatusBanner({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingSyncCountProvider);

    return pendingCountAsync.when(
      data: (count) {
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.card,
            border: Border(
              bottom: BorderSide(
                color: Color(0x66FF5C35),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_queue_rounded,
                color: AppColors.coral,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Offline · 1 change pending sync'
                      : 'Offline · $count changes pending sync',
                  style: AppTypography.caption.copyWith(color: AppColors.creamSoft),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(syncEngineProvider).flushQueue(tripId: tripId);
                },
                child: Text(
                  'Sync now',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
