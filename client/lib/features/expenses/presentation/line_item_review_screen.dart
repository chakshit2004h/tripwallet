import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/data/app_error.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/expense_members.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../domain/receipt_models.dart';
import 'item_claim_screen.dart';
import 'receipt_totals.dart';

class LineItemReviewScreen extends ConsumerStatefulWidget {
  final ReceiptData receipt;
  const LineItemReviewScreen({super.key, required this.receipt});
  @override
  ConsumerState<LineItemReviewScreen> createState() =>
      _LineItemReviewScreenState();
}

class _LineItemReviewScreenState extends ConsumerState<LineItemReviewScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.receipt.title);
  late final _tax = TextEditingController(
    text: decimalAmount(widget.receipt.taxMinor, widget.receipt.currency),
  );
  late final _service = TextEditingController(
    text: decimalAmount(
      widget.receipt.serviceChargeMinor,
      widget.receipt.currency,
    ),
  );
  late final _printedTotal = TextEditingController(
    text: widget.receipt.printedTotalMinor == null
        ? ''
        : decimalAmount(
            widget.receipt.printedTotalMinor!,
            widget.receipt.currency,
          ),
  );
  String? _error;
  void _refreshTotals() {
    setState(() {
      try {
        widget.receipt.taxMinor = parseMinor(
          _tax.text,
          widget.receipt.currency,
          allowZero: true,
        );
      } catch (_) {}
      try {
        widget.receipt.serviceChargeMinor = parseMinor(
          _service.text,
          widget.receipt.currency,
          allowZero: true,
        );
      } catch (_) {}
      try {
        widget.receipt.printedTotalMinor = _printedTotal.text.trim().isEmpty
            ? null
            : parseMinor(_printedTotal.text, widget.receipt.currency);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _tax.dispose();
    _service.dispose();
    _printedTotal.dispose();
    super.dispose();
  }

  String? _priceValidator(String? text, {bool allowZero = false}) {
    try {
      parseMinor(text ?? '', widget.receipt.currency, allowZero: allowZero);
      return null;
    } catch (e) {
      return 'Invalid amount';
    }
  }

  Future<void> _continue() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    try {
      widget.receipt.title = _title.text.trim();
      widget.receipt.taxMinor = parseMinor(
        _tax.text,
        widget.receipt.currency,
        allowZero: true,
      );
      widget.receipt.serviceChargeMinor = parseMinor(
        _service.text,
        widget.receipt.currency,
        allowZero: true,
      );
      widget.receipt.printedTotalMinor = _printedTotal.text.trim().isEmpty
          ? null
          : parseMinor(_printedTotal.text, widget.receipt.currency);
      if (widget.receipt.printedTotalMinor != null &&
          widget.receipt.totalMinor != widget.receipt.printedTotalMinor) {
        throw const FormatException(
          'Items and charges must match the printed bill total. Correct missed items, discounts or charges, or correct the printed total if it was scanned incorrectly.',
        );
      }
      final data = await ref.read(tripRepositoryProvider).read();
      final members = data.members
          .where(
            (m) => m.tripId == widget.receipt.tripId && canShareNewExpense(m),
          )
          .map(
            (m) => MemberProfile(
              id: m.id,
              name: m.displayName,
              initial: m.displayName.characters.firstOrNull ?? '?',
              color: AppColors.coralDark,
            ),
          )
          .toList();
      if (members.isEmpty) {
        throw StateError('Load the trip members before splitting.');
      }
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ItemClaimScreen(receipt: widget.receipt, members: members),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = appError(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review receipt')),
    body: ContentWidth(
      child: Form(
        key: _form,
        onChanged: _refreshTotals,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Check the little details.', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Correct any missed items or prices. Compare the final total with your receipt.',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Expense title'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 20),
            ...widget.receipt.items.map(
              (item) => Card(
                key: ValueKey(item.id),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item.label,
                              decoration: const InputDecoration(
                                labelText: 'Item',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter an item name'
                                  : null,
                              onSaved: (v) => item.label = v!.trim(),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove item',
                            onPressed: () => setState(
                              () => widget.receipt.items.remove(item),
                            ),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      if (item.unitPriceMinor != null)
                        Text(
                          'Scanned: quantity ${item.quantity} · Unit price ${formatMoney(item.unitPriceMinor!, widget.receipt.currency)}${item.taxRatePercent == null ? '' : ' · Tax ${item.taxRatePercent}%'}',
                          style: AppTypography.bodySmall,
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: decimalAmount(
                          item.priceMinor,
                          widget.receipt.currency,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Line total (${widget.receipt.currency})',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) {
                          try {
                            item.priceMinor = parseMinor(
                              v,
                              widget.receipt.currency,
                            );
                            _refreshTotals();
                          } catch (_) {}
                        },
                        validator: _priceValidator,
                        onSaved: (v) => item.priceMinor = parseMinor(
                          v!,
                          widget.receipt.currency,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(
                () => widget.receipt.items.add(
                  ReceiptItem(label: '', priceMinor: 0),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tax,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Tax (${widget.receipt.currency})',
              ),
              validator: (v) => _priceValidator(v, allowZero: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _service,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Service charge / tip (${widget.receipt.currency})',
              ),
              validator: (v) => _priceValidator(v, allowZero: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _printedTotal,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Printed bill total (${widget.receipt.currency})',
                helperText:
                    'Correct this if the scanner read the total incorrectly.',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? null : _priceValidator(v),
            ),
            const SizedBox(height: 16),
            ReceiptTotals(receipt: widget.receipt),
            if (_error != null)
              Padding(padding: const EdgeInsets.all(16), child: Text(_error!)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.receipt.items.every((i) => i.isAdjustment)
                  ? null
                  : _continue,
              child: const Text('Choose who shares each item'),
            ),
          ],
        ),
      ),
    ),
  );
}
