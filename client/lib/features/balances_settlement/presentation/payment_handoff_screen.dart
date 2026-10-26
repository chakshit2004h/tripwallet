import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/domain/money.dart';
import '../../../core/payment/payment_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import 'settlement_confirm_dialog.dart';

class PaymentHandoffScreen extends StatefulWidget {
  final String tripId,
      fromMemberId,
      toMemberId,
      payeeName,
      paymentMethod,
      launchUri,
      currency,
      tripName;
  final int amountMinor;
  final UpiApp app;
  const PaymentHandoffScreen({
    super.key,
    required this.tripId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.payeeName,
    required this.amountMinor,
    required this.paymentMethod,
    required this.launchUri,
    this.currency = 'INR',
    this.tripName = '',
    this.app = UpiApp.googlePay,
  });
  @override
  State<PaymentHandoffScreen> createState() => _PaymentHandoffScreenState();
}

class _PaymentHandoffScreenState extends State<PaymentHandoffScreen> {
  bool _launching = false, _confirming = false;
  bool? _launched;
  bool get _upi => widget.launchUri.isNotEmpty;
  String get _vpa => Uri.parse(widget.launchUri).queryParameters['pa'] ?? '';

  Future<void> _launch() async {
    if (_launching || _confirming) return;
    setState(() => _launching = true);
    final result = await PaymentLauncher.launchPayment(
      widget.launchUri,
      app: widget.app,
    );
    if (mounted) {
      setState(() {
        _launched = result;
        _launching = false;
      });
    }
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label copied')));
    }
  }

  Future<void> _confirm() async {
    if (_confirming || _launching) return;
    setState(() => _confirming = true);
    final result = await SettlementConfirmDialog.show(
      context,
      tripId: widget.tripId,
      fromMemberId: widget.fromMemberId,
      toMemberId: widget.toMemberId,
      payeeName: widget.payeeName,
      amountMinor: widget.amountMinor,
      method: widget.paymentMethod,
      currency: widget.currency,
    );
    if (!mounted) return;
    if (result == true) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review payment')),
    body: ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C123D38),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    backgroundColor: AppColors.coralTint,
                    foregroundColor: AppColors.ink,
                    child: Icon(Icons.north_east),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pay ${widget.payeeName}',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.tripName.isEmpty
                      ? 'One-time settlement'
                      : widget.tripName,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 24),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatMoney(widget.amountMinor, widget.currency),
                    style: AppTypography.display.copyWith(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  _upi ? 'Recipient UPI ID' : 'Payment method',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  _upi
                      ? _vpa
                      : (widget.paymentMethod == 'cash' ? 'Cash' : 'Online'),
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  _launched == true
                      ? 'Payment app opened · Not confirmed'
                      : 'Awaiting your payment',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
                if (_upi) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _launching || _confirming ? null : _launch,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(
                      _launching
                          ? 'Opening…'
                          : _launched == true
                          ? 'Reopen ${widget.app.label}'
                          : widget.app == UpiApp.other
                          ? 'Choose UPI app'
                          : 'Pay with ${widget.app.label}',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_launched == false)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${widget.app.label} could not be opened. Go back to choose another app, or copy the details and pay manually.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Text(
            _upi
                ? 'Check the recipient’s bank name and amount in your UPI app. Enter your UPI PIN only there.'
                : 'Only record this settlement after you have paid your friend.',
            style: AppTypography.bodyLarge,
          ),
          if (_upi) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => _copy(_vpa, 'UPI ID'),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy UPI ID'),
                ),
                TextButton.icon(
                  onPressed: () => _copy(
                    decimalAmount(widget.amountMinor, widget.currency),
                    'Amount',
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy amount'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _confirming || _launching ? null : _confirm,
            child: const Text('I have paid'),
          ),
          const SizedBox(height: 8),
          Text(
            'Recorded on your confirmation. TripWallet cannot verify the bank transfer.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.inkSoft),
          ),
          TextButton(
            onPressed: _confirming || _launching
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Not paid yet'),
          ),
        ],
      ),
    ),
  );
}
