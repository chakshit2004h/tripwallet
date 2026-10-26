import 'package:flutter/material.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/proration_engine.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../domain/receipt_models.dart';
import 'split_confirm_screen.dart';
import 'receipt_totals.dart';

class MemberProfile {
  final String id, name, initial;
  final Color color;
  const MemberProfile({
    required this.id,
    required this.name,
    required this.initial,
    required this.color,
  });
}

Set<String> receiptItemClaims(ReceiptData receipt, ReceiptItem item) =>
    item.isAdjustment
    ? receipt.items
          .where((i) => !i.isAdjustment)
          .expand((i) => i.claimedMemberIds)
          .toSet()
    : item.claimedMemberIds;

Map<String, ClaimAllocation> receiptAllocations(
  ReceiptData receipt,
  String payer,
  List<MemberProfile> members,
) {
  final subtotals = {for (final member in members) member.id: 0};
  for (final item in receipt.items) {
    if (item.isAdjustment || item.claimedMemberIds.isEmpty) continue;
    for (final share in splitEqually(
      item.priceMinor,
      item.claimedMemberIds,
    ).entries) {
      subtotals[share.key] = (subtotals[share.key] ?? 0) + share.value;
    }
  }
  final shares = prorateReceipt(
    payerId: payer,
    memberSubtotals: subtotals,
    totalTaxMinor: receipt.taxMinor,
    totalServiceChargeMinor: receipt.serviceChargeMinor,
  );
  for (final item in receipt.items.where((i) => i.isAdjustment)) {
    final claimants = receiptItemClaims(receipt, item);
    if (claimants.isEmpty) continue;
    for (final entry in splitEqually(item.priceMinor, claimants).entries) {
      final prior = shares[entry.key]!;
      shares[entry.key] = ClaimAllocation(
        memberId: prior.memberId,
        subtotalMinor: prior.subtotalMinor,
        taxMinor: prior.taxMinor,
        serviceChargeMinor: prior.serviceChargeMinor,
        adjustmentMinor: prior.adjustmentMinor + entry.value,
        totalMinor: prior.totalMinor + entry.value,
      );
    }
  }
  return shares;
}

class ItemClaimScreen extends StatefulWidget {
  final ReceiptData receipt;
  final List<MemberProfile> members;
  const ItemClaimScreen({
    super.key,
    required this.receipt,
    required this.members,
  });
  @override
  State<ItemClaimScreen> createState() => _ItemClaimScreenState();
}

class _ItemClaimScreenState extends State<ItemClaimScreen> {
  @override
  Widget build(BuildContext context) {
    final dishes = widget.receipt.items.where((i) => !i.isAdjustment).toList();
    final complete =
        dishes.isNotEmpty && dishes.every((i) => i.claimedMemberIds.isNotEmpty);
    return Scaffold(
      appBar: AppBar(title: const Text('Split by item')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Who had what?', style: AppTypography.display),
            const SizedBox(height: 8),
            Text(
              'Choose everyone who shared each item. Shared dishes are split equally, down to the last cent.',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: 12),
            ReceiptTotals(receipt: widget.receipt),
            const Text(
              'Tax and service charges are included and shared in proportion to your items. Round-off is shared equally by the people sharing the bill.',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                for (final item in dishes) {
                  item.claimedMemberIds.addAll(widget.members.map((m) => m.id));
                }
              }),
              child: const Text('Select everyone for all items'),
            ),
            ...dishes.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        formatMoney(item.priceMinor, widget.receipt.currency),
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.members
                            .map(
                              (m) => FilterChip(
                                label: Text(m.name),
                                selected: item.claimedMemberIds.contains(m.id),
                                onSelected: (selected) => setState(() {
                                  if (selected) {
                                    item.claimedMemberIds.add(m.id);
                                  } else {
                                    item.claimedMemberIds.remove(m.id);
                                  }
                                }),
                              ),
                            )
                            .toList(),
                      ),
                      if (item.claimedMemberIds.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Choose at least one person'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: ElevatedButton(
            onPressed: !complete
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SplitConfirmScreen(
                        receipt: widget.receipt,
                        members: widget.members,
                        allocations: receiptAllocations(
                          widget.receipt,
                          widget.receipt.payerMemberId,
                          widget.members,
                        ),
                      ),
                    ),
                  ),
            child: const Text('Review split'),
          ),
        ),
      ),
    );
  }
}
