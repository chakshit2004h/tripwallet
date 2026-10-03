import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../expenses/data/supabase_expenses_service.dart';

class SettlementConfirmDialog extends ConsumerStatefulWidget {
  final String tripId;
  final String fromMemberId;
  final String toMemberId;
  final String payeeName;
  final int amountMinor;
  final String method;

  const SettlementConfirmDialog({
    super.key,
    required this.tripId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.payeeName,
    required this.amountMinor,
    required this.method,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String tripId,
    required String fromMemberId,
    required String toMemberId,
    required String payeeName,
    required int amountMinor,
    required String method,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SettlementConfirmDialog(
        tripId: tripId,
        fromMemberId: fromMemberId,
        toMemberId: toMemberId,
        payeeName: payeeName,
        amountMinor: amountMinor,
        method: method,
      ),
    );
  }

  @override
  ConsumerState<SettlementConfirmDialog> createState() => _SettlementConfirmDialogState();
}

class _SettlementConfirmDialogState extends ConsumerState<SettlementConfirmDialog> {
  bool _isSaving = false;

  Future<void> _confirmSettlement() async {
    setState(() => _isSaving = true);
    final db = ref.read(databaseProvider);
    final syncEngine = ref.read(syncEngineProvider);

    final settlementId = const Uuid().v4();

    try {
      // 1. Insert into local SQLite
      await db.into(db.localSettlements).insertOnConflictUpdate(
            LocalSettlementsCompanion(
              id: drift.Value(settlementId),
              tripId: drift.Value(widget.tripId),
              fromMemberId: drift.Value(widget.fromMemberId),
              toMemberId: drift.Value(widget.toMemberId),
              amountMinor: drift.Value(widget.amountMinor),
              currency: const drift.Value('INR'),
              method: drift.Value(widget.method),
              status: const drift.Value('confirmed'),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 2. Enqueue into OutboundSyncQueue for CRDT sync
      final payload = utf8.encode(jsonEncode({
        'mutation': 'add_settlement',
        'id': settlementId,
        'from_member': widget.fromMemberId,
        'to_member': widget.toMemberId,
        'amount_minor': widget.amountMinor,
        'currency': 'INR',
        'method': widget.method,
      }));

      await db.into(db.outboundSyncQueue).insert(
            OutboundSyncQueueCompanion(
              tripId: drift.Value(widget.tripId),
              crdtUpdate: drift.Value(payload),
              status: const drift.Value('pending'),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 3. Flush queue in background
      syncEngine.flushQueue(tripId: widget.tripId);

      // 4. Record to Supabase cloud
      try {
        final expenseService = ref.read(supabaseExpensesServiceProvider);
        await expenseService.recordSettlement(
          tripId: widget.tripId,
          fromUserId: widget.fromMemberId,
          toUserId: widget.toMemberId,
          amountMinor: widget.amountMinor,
          currency: 'INR',
          method: widget.method,
        );
      } catch (e) {
        debugPrint('Supabase recordSettlement note: $e');
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of ₹${(widget.amountMinor / 100).toStringAsFixed(2)} to ${widget.payeeName} marked as settled!'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record settlement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountFormatted = (widget.amountMinor / 100).toStringAsFixed(2);

    return Dialog(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.coral.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.coral,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Did the payment go through?',
              style: AppTypography.titleMedium.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Confirm that ₹$amountFormatted was successfully transferred to ${widget.payeeName} via ${widget.method.toUpperCase()}.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.line),
                      foregroundColor: AppColors.creamSoft,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Not yet'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _confirmSettlement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Yes, settled'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
