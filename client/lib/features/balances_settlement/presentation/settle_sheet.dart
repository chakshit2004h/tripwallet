import 'package:flutter/material.dart';
import '../../../core/payment/payment_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'payment_handoff_screen.dart';

class SettleSheet extends StatefulWidget {
  final String tripId;
  final String fromMemberId;
  final String toMemberId;
  final String payeeName;
  final String payeeVpa;
  final int amountMinor;

  const SettleSheet({
    super.key,
    required this.tripId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.payeeName,
    this.payeeVpa = 'amit@okaxis',
    required this.amountMinor,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String tripId,
    required String fromMemberId,
    required String toMemberId,
    required String payeeName,
    String payeeVpa = 'amit@okaxis',
    required int amountMinor,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SettleSheet(
        tripId: tripId,
        fromMemberId: fromMemberId,
        toMemberId: toMemberId,
        payeeName: payeeName,
        payeeVpa: payeeVpa,
        amountMinor: amountMinor,
      ),
    );
  }

  @override
  State<SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends State<SettleSheet> {
  String _selectedMethod = 'gpay';

  void _proceedToPayment() async {
    Navigator.of(context).pop();

    String launchUri = '';
    String methodName = 'Payment App';

    switch (_selectedMethod) {
      case 'gpay':
        methodName = 'Google Pay';
        launchUri = PaymentLauncher.buildUpiUri(
          payeeVpa: widget.payeeVpa,
          payeeName: widget.payeeName,
          amountMinor: widget.amountMinor,
          note: 'TripWallet Settlement',
        );
        break;
      case 'phonepe':
        methodName = 'PhonePe';
        launchUri = PaymentLauncher.buildUpiUri(
          payeeVpa: widget.payeeVpa,
          payeeName: widget.payeeName,
          amountMinor: widget.amountMinor,
          note: 'TripWallet Settlement',
        );
        break;
      case 'paytm':
        methodName = 'Paytm';
        launchUri = PaymentLauncher.buildUpiUri(
          payeeVpa: widget.payeeVpa,
          payeeName: widget.payeeName,
          amountMinor: widget.amountMinor,
          note: 'TripWallet Settlement',
        );
        break;
      case 'revolut':
        methodName = 'Revolut';
        launchUri = PaymentLauncher.buildRevolutUri(
          username: widget.payeeName.toLowerCase().replaceAll(' ', ''),
          amountMinor: widget.amountMinor,
        );
        break;
      case 'cash':
        methodName = 'Cash';
        launchUri = '';
        break;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentHandoffScreen(
          tripId: widget.tripId,
          fromMemberId: widget.fromMemberId,
          toMemberId: widget.toMemberId,
          payeeName: widget.payeeName,
          amountMinor: widget.amountMinor,
          paymentMethod: methodName,
          launchUri: launchUri,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountFormatted = (widget.amountMinor / 100).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Settle Up', style: AppTypography.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.creamSoft, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payee & Amount Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.coral.withOpacity(0.2),
                  child: Text(
                    widget.payeeName.isNotEmpty ? widget.payeeName[0] : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paying ${widget.payeeName}', style: AppTypography.titleMedium),
                      const SizedBox(height: 3),
                      Text('UPI: ${widget.payeeVpa}', style: AppTypography.caption.copyWith(color: AppColors.creamSoft)),
                    ],
                  ),
                ),
                Text(
                  '₹$amountFormatted',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.coral, fontSize: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text('SELECT PAYMENT RAIL', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 10),

          // Payment rails list
          _buildMethodTile(
            id: 'gpay',
            title: 'Google Pay',
            subtitle: 'Direct UPI intent via GPay app',
            icon: Icons.bolt_rounded,
            badge: 'RECOMMENDED',
            iconColor: AppColors.yellow,
          ),
          _buildMethodTile(
            id: 'phonepe',
            title: 'PhonePe',
            subtitle: 'Direct UPI intent via PhonePe',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF5F259F),
          ),
          _buildMethodTile(
            id: 'paytm',
            title: 'Paytm UPI',
            subtitle: 'Direct UPI intent via Paytm',
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFF00B9F1),
          ),
          _buildMethodTile(
            id: 'revolut',
            title: 'Revolut.me',
            subtitle: 'Instant link for EUR / GBP accounts',
            icon: Icons.public_rounded,
            iconColor: AppColors.teal,
          ),
          _buildMethodTile(
            id: 'cash',
            title: 'Cash / Settled Directly',
            subtitle: 'Record payment without digital transfer',
            icon: Icons.money_rounded,
            iconColor: AppColors.green,
          ),

          const SizedBox(height: 20),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pay ₹$amountFormatted Now', style: AppTypography.button),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? badge,
  }) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral.withOpacity(0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.coral : AppColors.line,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: AppTypography.caption.copyWith(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              activeColor: AppColors.coral,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
