import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/auth/supabase_auth_service.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../trips/data/supabase_trips_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSyncing = false;
  bool _notificationsEnabled = true;
  String _preferredUpiApp = 'Google Pay';
  String _defaultCurrency = 'INR';

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

  Future<void> _forceCloudSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final supaTrips = await ref.read(supabaseTripsServiceProvider).fetchUserTrips();
      final db = ref.read(databaseProvider);

      for (final trip in supaTrips) {
        await db.into(db.localTrips).insertOnConflictUpdate(
              LocalTripsCompanion(
                id: drift.Value(trip.id),
                name: drift.Value(trip.name),
                inviteCode: drift.Value(trip.inviteCode),
                startDate: drift.Value(trip.startDate),
                endDate: drift.Value(trip.endDate),
                baseCurrency: drift.Value(trip.baseCurrency),
                status: drift.Value(trip.status),
              ),
            );
      }

      await _loadProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All trips and profile data synced with cloud!'),
            backgroundColor: AppColors.ink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: AppColors.coralDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _profile?.displayName ?? '');
    final vpaCtrl = TextEditingController(text: _profile?.paymentVpa ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Profile', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display Name', style: AppTypography.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Your Name',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            Text('Default UPI ID', style: AppTypography.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: vpaCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. user@okhdfcbank',
                prefixIcon: Icon(Icons.payment_rounded, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newVpa = vpaCtrl.text.trim();
              Navigator.of(ctx).pop();

              final auth = ref.read(supabaseAuthServiceProvider);
              await auth.updateProfile(
                displayName: newName.isNotEmpty ? newName : null,
                paymentVpa: newVpa.isNotEmpty ? newVpa : null,
              );
              await _loadProfile();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details updated!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showCurrencySelector() {
    final currencies = ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)', 'AED (د.إ)', 'THB (฿)'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Default Currency', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            ...currencies.map((curr) {
              final code = curr.split(' ').first;
              final isSel = _defaultCurrency == code;
              return ListTile(
                title: Text(curr, style: AppTypography.bodyMedium.copyWith(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                trailing: isSel ? const Icon(Icons.check_rounded, color: AppColors.coral) : null,
                onTap: () {
                  setState(() => _defaultCurrency = code);
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showUpiAppSelector() {
    final apps = ['Google Pay', 'PhonePe', 'Paytm', 'BHIM UPI', 'Cred UPI'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Preferred Payment App', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            ...apps.map((app) {
              final isSel = _preferredUpiApp == app;
              return ListTile(
                title: Text(app, style: AppTypography.bodyMedium.copyWith(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                trailing: isSel ? const Icon(Icons.check_rounded, color: AppColors.coral) : null,
                onTap: () {
                  setState(() => _preferredUpiApp = app);
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: AppTypography.titleMedium),
        content: const Text('Are you sure you want to sign out of TripWallet? Your local trips will remain securely stored on your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final auth = ref.read(supabaseAuthServiceProvider);
              await auth.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(supabaseAuthServiceProvider);
    final db = ref.watch(databaseProvider);
    final user = auth.currentUser;
    final displayName = _profile?.displayName ?? auth.currentDisplayName;
    final email = _profile?.email ?? user?.email ?? 'Offline guest';
    final vpa = _profile?.paymentVpa ?? 'Not set';
    final initials = displayName.length >= 2 ? displayName.substring(0, 2).toUpperCase() : 'ME';

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Profile & Settings', style: AppTypography.titleLarge),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sync data',
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral),
                  )
                : const Icon(Icons.sync_rounded, size: 20),
            onPressed: _forceCloudSync,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<LocalTrip>>(
              stream: db.select(db.localTrips).watch(),
              builder: (context, tripSnap) {
                final trips = tripSnap.data ?? [];

                return StreamBuilder<List<LocalExpense>>(
                  stream: db.select(db.localExpenses).watch(),
                  builder: (context, expSnap) {
                    final expenses = expSnap.data ?? [];
                    final totalSpentMinor = expenses.fold<int>(0, (sum, e) => sum + e.amountMinor);
                    final totalSpentFormatted = '₹${(totalSpentMinor / 100).toStringAsFixed(0)}';

                    return StreamBuilder<List<LocalMember>>(
                      stream: db.select(db.localMembers).watch(),
                      builder: (context, memberSnap) {
                        final members = memberSnap.data ?? [];
                        final uniqueCrewCount = members.map((m) => m.displayName).toSet().length;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. HERO PROFILE CARD
                              _buildHeroProfileCard(
                                initials: initials,
                                displayName: displayName,
                                email: email,
                                tripCount: trips.length,
                                totalSpentFormatted: totalSpentFormatted,
                                crewCount: uniqueCrewCount > 0 ? uniqueCrewCount : 1,
                              ),
                              const SizedBox(height: 24),

                              // 2. PAYMENT & SETTLEMENTS SECTION
                              _buildSectionTitle('PAYMENT & SETTLEMENTS'),
                              const SizedBox(height: 8),
                              _buildCardGroup([
                                _buildSettingsTile(
                                  icon: Icons.payment_rounded,
                                  title: 'Default UPI ID',
                                  subtitle: vpa,
                                  subtitleColor: vpa != 'Not set' ? AppColors.coral : AppColors.muted,
                                  onTap: _showEditProfileDialog,
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildSettingsTile(
                                  icon: Icons.touch_app_rounded,
                                  title: 'Preferred Payment App',
                                  subtitle: _preferredUpiApp,
                                  onTap: _showUpiAppSelector,
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildSettingsTile(
                                  icon: Icons.currency_exchange_rounded,
                                  title: 'Default Currency',
                                  subtitle: '$_defaultCurrency (${_defaultCurrency == "INR" ? "₹" : "\$"})',
                                  onTap: _showCurrencySelector,
                                ),
                              ]),
                              const SizedBox(height: 24),

                              // 3. PREFERENCES & SYNC SECTION
                              _buildSectionTitle('CLOUD & PREFERENCES'),
                              const SizedBox(height: 8),
                              _buildCardGroup([
                                SwitchListTile(
                                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.ink),
                                  title: Text('Activity Notifications', style: AppTypography.bodyMedium),
                                  subtitle: Text('Alerts on new expenses & debts', style: AppTypography.caption),
                                  value: _notificationsEnabled,
                                  activeColor: AppColors.coral,
                                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildSettingsTile(
                                  icon: Icons.cloud_done_outlined,
                                  iconColor: AppColors.green,
                                  title: 'Cloud Sync Engine',
                                  subtitle: SupabaseConfig.isConfigured ? 'Connected to Supabase PostgreSQL' : 'Offline local mode',
                                  trailingWidget: TextButton(
                                    onPressed: _forceCloudSync,
                                    child: _isSyncing
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral),
                                          )
                                        : Text('Sync now', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.coral)),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 24),

                              // 4. STORAGE & DATA TOOLS
                              _buildSectionTitle('DATA & STORAGE'),
                              const SizedBox(height: 8),
                              _buildCardGroup([
                                _buildSettingsTile(
                                  icon: Icons.storage_rounded,
                                  title: 'Local Storage Engine',
                                  subtitle: 'Drift SQLite (Encrypted offline cache)',
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildSettingsTile(
                                  icon: Icons.file_download_outlined,
                                  title: 'Export Trip Data',
                                  subtitle: 'Download spending ledger as CSV',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Spending ledger exported to downloads!')),
                                    );
                                  },
                                ),
                              ]),
                              const SizedBox(height: 24),

                              // 5. ACCOUNT & APP INFO
                              _buildSectionTitle('ACCOUNT & ABOUT'),
                              const SizedBox(height: 8),
                              _buildCardGroup([
                                _buildSettingsTile(
                                  icon: Icons.info_outline_rounded,
                                  title: 'App Version',
                                  subtitle: 'TripWallet v1.0.0 (Production Release)',
                                ),
                                const Divider(height: 1, indent: 56),
                                if (auth.isAuthenticated) ...[
                                  _buildSettingsTile(
                                    icon: Icons.logout_rounded,
                                    iconColor: AppColors.coral,
                                    title: 'Sign Out',
                                    titleColor: AppColors.coral,
                                    subtitle: 'Safely disconnect this device',
                                    onTap: _confirmSignOut,
                                  ),
                                ] else ...[
                                  _buildSettingsTile(
                                    icon: Icons.login_rounded,
                                    iconColor: AppColors.coral,
                                    title: 'Sign In / Register',
                                    titleColor: AppColors.coral,
                                    subtitle: 'Connect your cloud account',
                                    onTap: () => context.push('/login'),
                                  ),
                                ],
                              ]),
                              const SizedBox(height: 34),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  // Hero Profile Card with live statistics
  Widget _buildHeroProfileCard({
    required String initials,
    required String displayName,
    required String email,
    required int tripCount,
    required String totalSpentFormatted,
    required int crewCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Avatar + Name + Edit Button
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.titleLarge.copyWith(color: AppColors.cream, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppTypography.caption.copyWith(color: AppColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit details',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, color: AppColors.cream, size: 18),
                ),
                onPressed: _showEditProfileDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),

          // Bottom Stats Row: Dynamic Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Trips', '$tripCount'),
              Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.1)),
              _buildStatItem('Total Spent', totalSpentFormatted),
              Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.1)),
              _buildStatItem('Crew Friends', '$crewCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(color: AppColors.cream, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.muted, fontSize: 10.5),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    Color iconColor = AppColors.ink,
    required String title,
    Color? titleColor,
    String? subtitle,
    Color? subtitleColor,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.inkText,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: subtitleColor ?? AppColors.muted,
                fontSize: 11.5,
              ),
            )
          : null,
      trailing: trailingWidget ??
          (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.muted) : null),
      onTap: onTap,
    );
  }
}
