import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/trip_repository.dart';
import '../sync/sync_engine.dart';
import '../theme/app_colors.dart';

class SyncStatusBanner extends ConsumerWidget {
  final String? tripId;
  const SyncStatusBanner({super.key, this.tripId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncEngineProvider);
    final count =
        ref
            .watch(ledgerProvider)
            .asData
            ?.value
            .pending
            .where((q) => tripId == null || q.tripId == tripId)
            .length ??
        0;
    // Routine sync is silent; only show changes waiting or a failed refresh.
    if (status.busy || (status.error == null && count == 0)) {
      return const SizedBox.shrink();
    }
    return Material(
      color: status.error == null ? AppColors.paper : AppColors.coralTint,
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.cloud_off_outlined, size: 20),
        title: Text(
          count > 0
              ? 'Saved on your phone · waiting to share'
              : 'Couldn’t refresh your trip',
        ),

        trailing: IconButton(
          tooltip: 'Retry sync',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(syncEngineProvider.notifier).sync(),
        ),
      ),
    );
  }
}
