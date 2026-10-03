import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/auth/supabase_auth_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = ref.read(supabaseAuthServiceProvider);
    final prof = await auth.fetchUserProfile();
    if (mounted) {
      setState(() {
        _profile = prof;
        _isLoading = false;
      });
    }
  }

  void _showEditVpaDialog() {
    final controller = TextEditingController(text: _profile?.paymentVpa ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit UPI ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. yourname@okhdfcbank',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newVpa = controller.text.trim();
              Navigator.of(ctx).pop();
              final auth = ref.read(supabaseAuthServiceProvider);
              await auth.updateProfile(paymentVpa: newVpa);
              _loadProfile();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UPI ID updated!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(supabaseAuthServiceProvider);
    final user = auth.currentUser;
    final displayName = _profile?.displayName ?? auth.currentDisplayName;
    final email = _profile?.email ?? user?.email ?? 'Offline guest';
    final vpa = _profile?.paymentVpa ?? 'Not set';
    final initials = displayName.length >= 2 ? displayName.substring(0, 2).toUpperCase() : 'YO';

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.coralTint,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: AppTypography.titleMedium.copyWith(color: AppColors.coral, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: AppTypography.titleMedium),
                            const SizedBox(height: 2),
                            Text(email, style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Linked UPI
                ListTile(
                  leading: const Icon(Icons.payment_rounded, color: AppColors.inkSoft),
                  title: Text('UPI ID for Settlements', style: AppTypography.bodyMedium),
                  subtitle: Text(vpa, style: AppTypography.caption.copyWith(color: AppColors.coral)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.inkSoft),
                  onTap: _showEditVpaDialog,
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.notifications_none_rounded, color: AppColors.inkSoft),
                  title: Text('Notifications', style: AppTypography.bodyMedium),
                  subtitle: const Text('Activity alerts enabled', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppColors.inkSoft),
                  title: Text('Data & Privacy', style: AppTypography.bodyMedium),
                  subtitle: const Text('Cloud synced via Supabase', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                ),
                const Divider(height: 1),

                // Sign in / Sign out action
                if (auth.isAuthenticated) ...[
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.coral),
                    title: Text('Sign out', style: AppTypography.bodyMedium.copyWith(color: AppColors.coral, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      await auth.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.login_rounded, color: AppColors.ink),
                    title: Text('Sign in / Create Account', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    onTap: () => context.push('/login'),
                  ),
                ],
                const Divider(height: 1),
              ],
            ),
    );
  }
}
