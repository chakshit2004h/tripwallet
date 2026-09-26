import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Profile header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.coralTint,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'CH',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.coral, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chirag', style: AppTypography.titleMedium),
                    const SizedBox(height: 2),
                    Text('Guest on 3 trips', style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          _buildListRow(Icons.account_balance_wallet_outlined, 'Linked payment apps'),
          _buildListRow(Icons.notifications_none_rounded, 'Notification settings'),
          _buildListRow(Icons.person_outline_rounded, 'Save my identity (make an account)'),
          _buildListRow(Icons.help_outline_rounded, 'Help & support'),
          _buildListRow(
            Icons.logout_rounded,
            'Log out of this device',
            isDanger: true,
            onTap: () {
              context.go('/landing');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(
    IconData icon,
    String label, {
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDanger ? AppColors.coralDark : AppColors.inkSoft,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: isDanger ? FontWeight.w600 : FontWeight.w500,
                  color: isDanger ? AppColors.coralDark : AppColors.inkText,
                ),
              ),
            ),
            if (!isDanger)
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFC7CCC8)),
          ],
        ),
      ),
    );
  }
}
