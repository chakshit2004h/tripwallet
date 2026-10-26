import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/app_error.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/proration_engine.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../domain/receipt_models.dart';
import 'item_claim_screen.dart';
import 'receipt_totals.dart';

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
  late String _payer =
      widget.members.any((m) => m.id == widget.receipt.payerMemberId)
      ? widget.receipt.payerMemberId
      : widget.members.first.id;
  bool _busy = false;
  String? _error;
  Future<void> _save() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final receipt = widget.receipt;
      final shares = receiptAllocations(receipt, _payer, widget.members);
      await ref
          .read(tripRepositoryProvider)
          .saveExpense(
            id: receipt.id,
            tripId: receipt.tripId,
            title: receipt.title,
            amountMinor: receipt.totalMinor,
            payerId: _payer,
            splits: {for (final e in shares.entries) e.key: e.value.totalMinor},
            category: 'food',
            splitMethod: 'itemized',
            taxMinor: receipt.taxMinor,
            serviceChargeMinor: receipt.serviceChargeMinor,
            items: receipt.items
                .map(
                  (i) => <String, dynamic>{
                    'id': i.id,
                    'label': i.label,
                    'price_minor': i.priceMinor,
                    'confidence': i.confidence,
                    'member_ids': receiptItemClaims(receipt, i).toList(),
                  },
                )
                .toList(),
          );
      if (mounted) context.go('/trip/${receipt.tripId}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = appError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shares = receiptAllocations(widget.receipt, _payer, widget.members);
    final currency = widget.receipt.currency;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm split')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(widget.receipt.title, style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            Text(
              formatMoney(widget.receipt.totalMinor, currency),
              style: AppTypography.display,
            ),
            const SizedBox(height: 8),
            ReceiptTotals(receipt: widget.receipt),
            const SizedBox(height: 28),
            DropdownButtonFormField<String>(
              initialValue: _payer,
              decoration: const InputDecoration(
                labelText: 'Who paid the bill?',
              ),
              items: widget.members
                  .map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _payer = v!),
            ),
            const SizedBox(height: 24),
            Text('Everyone’s share', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            ...widget.members.map(
              (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(m.name),
                subtitle: Text(
                  '${m.id == _payer ? 'Paid the bill · ' : ''}Tax ${formatMoney(shares[m.id]?.taxMinor ?? 0, currency)} · Round-off ${formatMoney(shares[m.id]?.adjustmentMinor ?? 0, currency)}',
                ),
                trailing: Text(
                  formatMoney(shares[m.id]?.totalMinor ?? 0, currency),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_error!),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving…' : 'Save expense'),
            ),
          ],
        ),
      ),
    );
  }
}
