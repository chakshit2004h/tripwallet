import 'package:flutter/material.dart';
import '../../../core/payment/payment_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'settlement_confirm_dialog.dart';

class PaymentHandoffScreen extends StatefulWidget {
  final String tripId;
  final String fromMemberId;
  final String toMemberId;
  final String payeeName;
  final int amountMinor;
  final String paymentMethod;
  final String launchUri;

  const PaymentHandoffScreen({
    super.key,
    required this.tripId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.payeeName,
    required this.amountMinor,
    required this.paymentMethod,
    required this.launchUri,
  });

  @override
  State<PaymentHandoffScreen> createState() => _PaymentHandoffScreenState();
}

class _PaymentHandoffScreenState extends State<PaymentHandoffScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Attempt native URL launch after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptLaunch();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _attemptLaunch() async {
    if (widget.launchUri.isNotEmpty) {
      await PaymentLauncher.launchPayment(widget.launchUri);
    }
  }

  Future<void> _onReturnFromPayment() async {
    final confirmed = await SettlementConfirmDialog.show(
      context,
      tripId: widget.tripId,
      fromMemberId: widget.fromMemberId,
      toMemberId: widget.toMemberId,
      payeeName: widget.payeeName,
      amountMinor: widget.amountMinor,
      method: widget.paymentMethod,
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountFormatted = (widget.amountMinor / 100).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.inkSoft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing logo animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.paper,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coral.withOpacity(0.35),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                        border: Border.all(color: AppColors.coral, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 48,
                          color: AppColors.coral,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),
              Text(
                'Opening ${widget.paymentMethod}...',
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Transfer ₹$amountFormatted to ${widget.payeeName}',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  'Amount pre-filled',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Button 1: Return from payment
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onReturnFromPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text("I've completed payment", style: AppTypography.button),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Button 2: Desktop Simulator fallback
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _onReturnFromPayment,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.line),
                    foregroundColor: AppColors.creamSoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Simulate Payment Success', style: AppTypography.caption.copyWith(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
