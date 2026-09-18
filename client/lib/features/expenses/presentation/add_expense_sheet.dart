import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'receipt_camera_screen.dart';

class AddExpenseSheet extends StatelessWidget {
  final String tripId;

  const AddExpenseSheet({
    super.key,
    required this.tripId,
  });

  static Future<void> show(BuildContext context, {required String tripId}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddExpenseSheet(tripId: tripId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Add Expense', style: AppTypography.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.creamSoft, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Option 1: Scan Receipt
          _buildOptionTile(
            context,
            title: 'Scan Receipt',
            subtitle: 'Auto-extract dishes, prices & tax using OCR',
            icon: Icons.document_scanner_rounded,
            badge: 'RECOMMENDED',
            isPrimary: true,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReceiptCameraScreen(tripId: tripId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Enter Manually
          _buildOptionTile(
            context,
            title: 'Enter Manually',
            subtitle: 'Quick total or equal split without receipt',
            icon: Icons.edit_note_rounded,
            isPrimary: false,
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quick manual entry available via Receipt Scanner fallback')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.card : AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? AppColors.coral.withOpacity(0.5) : AppColors.line,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.coral.withOpacity(0.15) : AppColors.line.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? AppColors.coral : AppColors.cream,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 16)),
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
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.creamSoft, size: 16),
          ],
        ),
      ),
    );
  }
}
