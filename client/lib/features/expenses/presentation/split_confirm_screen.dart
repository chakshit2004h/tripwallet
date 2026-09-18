import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/domain/proration_engine.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/receipt_models.dart';
import 'item_claim_screen.dart';

class SplitConfirmScreen extends ConsumerStatefulWidget {
  final ReceiptData receipt;
  final List<MemberProfile> members;
  final Map<String, ClaimAllocation> allocations;

  const SplitConfirmScreen({
    super.key,
    required this.receipt,
    required this.members,
    required this.allocations,
  });

  @override
  ConsumerState<SplitConfirmScreen> createState() => _SplitConfirmScreenState();
}

class _SplitConfirmScreenState extends ConsumerState<SplitConfirmScreen> {
  late String _payerId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _payerId = widget.receipt.payerMemberId;
  }

  Future<void> _saveAndSync() async {
    setState(() => _isSaving = true);
    final db = ref.read(databaseProvider);
    final syncEngine = ref.read(syncEngineProvider);

    try {
      // 1. Insert local expense
      await db.into(db.localExpenses).insertOnConflictUpdate(
            LocalExpensesCompanion(
              id: drift.Value(widget.receipt.id),
              tripId: drift.Value(widget.receipt.tripId),
              title: drift.Value(widget.receipt.title),
              amountMinor: drift.Value(widget.receipt.totalMinor),
              currency: drift.Value(widget.receipt.currency),
              paidByMemberId: drift.Value(_payerId),
              splitMethod: const drift.Value('itemized'),
              taxMinor: drift.Value(widget.receipt.taxMinor),
              serviceChargeMinor: drift.Value(widget.receipt.serviceChargeMinor),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 2. Insert line items & claims
      for (final item in widget.receipt.items) {
        await db.into(db.localLineItems).insertOnConflictUpdate(
              LocalLineItemsCompanion(
                id: drift.Value(item.id),
                expenseId: drift.Value(widget.receipt.id),
                label: drift.Value(item.label),
                priceMinor: drift.Value(item.priceMinor),
                ocrConfidence: drift.Value(item.confidence),
              ),
            );

        final claimCount = item.claimedMemberIds.length;
        if (claimCount > 0) {
          final fraction = 1.0 / claimCount;
          for (final memberId in item.claimedMemberIds) {
            await db.into(db.localItemClaims).insertOnConflictUpdate(
                  LocalItemClaimsCompanion(
                    id: drift.Value('${item.id}_$memberId'),
                    lineItemId: drift.Value(item.id),
                    memberId: drift.Value(memberId),
                    shareFraction: drift.Value(fraction),
                  ),
                );
          }
        }
      }

      // 3. Enqueue into OutboundSyncQueue
      final mutationPayload = utf8.encode(
        '{"mutation": "add_itemized_expense", "expense_id": "${widget.receipt.id}", "title": "${widget.receipt.title}", "amount_minor": ${widget.receipt.totalMinor}}',
      );

      await db.into(db.outboundSyncQueue).insert(
            OutboundSyncQueueCompanion(
              tripId: drift.Value(widget.receipt.tripId),
              crdtUpdate: drift.Value(mutationPayload),
              status: const drift.Value('pending'),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 4. Trigger background flush
      syncEngine.flushQueue(tripId: widget.receipt.tripId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense "${widget.receipt.title}" saved & queued for sync!'),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Pop back to TripDashboardScreen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text('Confirm Split', style: AppTypography.titleMedium),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.receipt.title, style: AppTypography.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Grand Total: ',
                            style: AppTypography.caption.copyWith(color: AppColors.creamSoft),
                          ),
                          Text(
                            '₹${(widget.receipt.totalMinor / 100).toStringAsFixed(2)}',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.coral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Payer Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WHO PAID THE BILL?', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 12),
                      Row(
                        children: widget.members.map((member) {
                          final isSelected = member.id == _payerId;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _payerId = member.id),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? member.color.withOpacity(0.15) : AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? member.color : AppColors.line,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: member.color,
                                      child: Text(
                                        member.initial,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      member.name,
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? AppColors.cream : AppColors.creamSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Breakdown per member
                Text('INDIVIDUAL MEMBER SHARES', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 10),

                ...widget.members.map((member) {
                  final alloc = widget.allocations[member.id];
                  final totalMinor = alloc?.totalMinor ?? 0;
                  final subtotalMinor = alloc?.subtotalMinor ?? 0;
                  final taxMinor = alloc?.taxMinor ?? 0;
                  final serviceMinor = alloc?.serviceChargeMinor ?? 0;
                  final isPayer = member.id == _payerId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: member.color,
                          child: Text(
                            member.initial,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(member.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                  if (isPayer) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.coral.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'PAID',
                                        style: AppTypography.caption.copyWith(fontSize: 9, color: AppColors.coral, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Items: ₹${(subtotalMinor / 100).toStringAsFixed(0)} · Tax: +₹${(taxMinor / 100).toStringAsFixed(0)} · Svc: +₹${(serviceMinor / 100).toStringAsFixed(0)}',
                                style: AppTypography.caption.copyWith(color: AppColors.creamSoft, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${(totalMinor / 100).toStringAsFixed(2)}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.paper,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAndSync,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text('Save & Sync Expense', style: AppTypography.button),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
