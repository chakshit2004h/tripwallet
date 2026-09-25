import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PaywallModal extends StatefulWidget {
  const PaywallModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PaywallModal(),
    );
  }

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  int _selectedPlan = 1; // 0 = Trip Pass, 1 = Annual Pro

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lineHeavy,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.coral.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.coral.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.coral, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'TRIPWALLET PRO',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.coral,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Never stress over trip bills again.',
            style: AppTypography.display.copyWith(fontSize: 24, height: 1.2),
          ),
          const SizedBox(height: 6),
          Text(
            'Unlock receipt OCR, unlimited friends, multi-currency conversion, and offline CRDT sync.',
            style: AppTypography.caption.copyWith(color: AppColors.muted, height: 1.35),
          ),
          const SizedBox(height: 18),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Plan A: Trip Pass
                  _buildPlanCard(
                    index: 0,
                    title: 'Trip Pass',
                    price: '\$2.99',
                    subtitle: 'One-time payment for 1 trip',
                    tag: 'FOR SINGLE TRIPS',
                    tagColor: AppColors.muted,
                    features: [
                      'Unlimited OCR receipt scanning',
                      'Instant CRDT live sync with crew',
                      'Direct UPI & Revolut payment links',
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Plan B: Annual Pro (Selected by default)
                  _buildPlanCard(
                    index: 1,
                    title: 'Annual Pro',
                    price: '\$19.99 / yr',
                    subtitle: '\$1.67 / month · Cancel anytime',
                    tag: 'BEST VALUE · SAVE 60%',
                    tagColor: AppColors.coral,
                    features: [
                      'Unlimited group trips & members',
                      'Real-time offline multi-device sync',
                      'Multi-currency live FX conversion',
                      'PDF & Excel CSV expense export',
                      'Priority 24/7 travel support',
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Primary Purchase CTA
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _selectedPlan == 1
                                  ? 'Unlocked TripWallet Pro Annual!'
                                  : 'Trip Pass activated for Goa Weekend!',
                              style: AppTypography.bodyMedium,
                            ),
                            backgroundColor: AppColors.card,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: Text(
                        _selectedPlan == 1 ? 'Start 7-Day Free Trial' : 'Unlock Trip Pass (\$2.99)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Footer links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Purchases restored successfully.', style: AppTypography.bodyMedium),
                              backgroundColor: AppColors.card,
                            ),
                          );
                        },
                        child: Text('Restore Purchases', style: AppTypography.caption.copyWith(color: AppColors.muted)),
                      ),
                      Text('·', style: AppTypography.caption.copyWith(color: AppColors.muted)),
                      TextButton(
                        onPressed: () {},
                        child: Text('Terms & Privacy', style: AppTypography.caption.copyWith(color: AppColors.muted)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required List<String> features,
  }) {
    final isSelected = _selectedPlan == index;

    return InkWell(
      onTap: () => setState(() => _selectedPlan = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.coral : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.caption.copyWith(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.coral : AppColors.muted,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 18)),
                Text(
                  price,
                  style: AppTypography.display.copyWith(
                    fontSize: 18,
                    color: isSelected ? AppColors.coral : AppColors.cream,
                  ),
                ),
              ],
            ),
            Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.muted)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_rounded, color: AppColors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTypography.caption.copyWith(color: AppColors.cream),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
