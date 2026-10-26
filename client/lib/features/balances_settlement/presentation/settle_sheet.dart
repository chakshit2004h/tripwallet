import 'package:flutter/material.dart';
import '../../../core/domain/money.dart';
import '../../../core/payment/payment_launcher.dart';
import '../../../core/theme/app_typography.dart';
import 'payment_handoff_screen.dart';

class SettleSheet extends StatefulWidget {
  final String tripId,
      fromMemberId,
      toMemberId,
      payeeName,
      payeeVpa,
      currency,
      tripName;
  final int amountMinor;
  const SettleSheet({
    super.key,
    required this.tripId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.payeeName,
    this.payeeVpa = '',
    required this.amountMinor,
    this.currency = 'INR',
    this.tripName = '',
  });

  static Future<bool?> show(
    BuildContext context, {
    required String tripId,
    required String fromMemberId,
    required String toMemberId,
    required String payeeName,
    String payeeVpa = '',
    required int amountMinor,
    String currency = 'INR',
    String tripName = '',
  }) => showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => SettleSheet(
      tripId: tripId,
      fromMemberId: fromMemberId,
      toMemberId: toMemberId,
      payeeName: payeeName,
      payeeVpa: payeeVpa,
      amountMinor: amountMinor,
      currency: currency,
      tripName: tripName,
    ),
  );

  @override
  State<SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends State<SettleSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _vpa;
  String _method = 'cash';
  UpiApp _app = UpiApp.googlePay;
  bool _proceeding = false;
  bool get _upi => _method == 'online' && widget.currency == 'INR';

  @override
  void initState() {
    super.initState();
    _vpa = TextEditingController(text: widget.payeeVpa.trim());
    if (widget.currency == 'INR' && PaymentLauncher.validVpa(_vpa.text)) {
      _method = 'online';
    }
  }

  @override
  void dispose() {
    _vpa.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    if (_proceeding || !_form.currentState!.validate()) return;
    setState(() => _proceeding = true);
    final uri = _upi
        ? PaymentLauncher.buildUpiUri(
            payeeVpa: _vpa.text.trim(),
            payeeName: widget.payeeName,
            amountMinor: widget.amountMinor,
          )
        : '';
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentHandoffScreen(
          tripId: widget.tripId,
          fromMemberId: widget.fromMemberId,
          toMemberId: widget.toMemberId,
          payeeName: widget.payeeName,
          amountMinor: widget.amountMinor,
          paymentMethod: _upi ? 'upi' : (_method == 'online' ? 'bank' : 'cash'),
          launchUri: uri,
          currency: widget.currency,
          tripName: widget.tripName,
          app: _app,
        ),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _proceeding = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      24,
      24,
      24,
      24 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settle with ${widget.payeeName}',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            formatMoney(widget.amountMinor, widget.currency),
            style: AppTypography.display,
          ),
          const SizedBox(height: 24),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'cash',
                icon: Icon(Icons.payments_outlined),
                label: Text('Cash'),
              ),
              ButtonSegment(
                value: 'online',
                icon: Icon(Icons.account_balance_outlined),
                label: Text('Online'),
              ),
            ],
            selected: {_method},
            onSelectionChanged: _proceeding
                ? null
                : (value) => setState(() => _method = value.single),
          ),
          const SizedBox(height: 20),
          if (_upi) ...[
            Text('Choose your payment app', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final app in UpiApp.values)
                  ChoiceChip(
                    label: Text(app.label),
                    selected: _app == app,
                    onSelected: _proceeding
                        ? null
                        : (_) => setState(() => _app = app),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _vpa,
              autocorrect: false,
              enableSuggestions: false,
              readOnly: _proceeding,
              maxLength: 321,
              decoration: InputDecoration(
                labelText: "${widget.payeeName}'s UPI ID",
                hintText: 'name@bank',
                helperText: "Enter the recipient’s ID, not your own.",
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  PaymentLauncher.validVpa((value ?? '').trim())
                  ? null
                  : 'Enter a valid recipient UPI ID, such as name@bank.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Check the bank account name in your payment app before paying.',
            ),
          ] else
            Text(
              _method == 'cash'
                  ? 'Record cash you have handed over.'
                  : 'Pay your friend in ${widget.currency} using your bank or payment app, then record it here.',
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _proceeding || widget.amountMinor <= 0 ? null : _proceed,
            child: const Text('Review payment'),
          ),
        ],
      ),
    ),
  );
}
