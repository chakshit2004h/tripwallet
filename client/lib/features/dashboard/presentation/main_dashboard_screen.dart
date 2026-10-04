import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/auth/supabase_auth_service.dart';
import '../../trips/data/supabase_trips_service.dart';
import '../../alerts/presentation/alerts_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class MainDashboardScreen extends ConsumerStatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  ConsumerState<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends ConsumerState<MainDashboardScreen> {
  int _currentTab = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCloudData();
    });
  }

  Future<void> _fetchCloudData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

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
    } catch (e) {
      debugPrint('Dashboard cloud sync note: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildJourneysTab(),
          _buildBalancesTab(),
          const AlertsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildFloatingBottomDock(),
    );
  }

  Widget _buildFloatingBottomDock() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.line.withValues(alpha: 0.7), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockItem(index: 0, icon: Icons.flight_takeoff_rounded, label: 'Journeys'),
              _buildDockItem(index: 1, icon: Icons.account_balance_wallet_outlined, label: 'Balances'),
              _buildDockItem(index: 2, icon: Icons.bolt_rounded, label: 'Activity'),
              _buildDockItem(index: 3, icon: Icons.person_outline_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem({required int index, required IconData icon, required String label}) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.coral : AppColors.muted,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.coral,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: JOURNEYS (HOME / TRAVEL JOURNAL)
  // ---------------------------------------------------------------------------
  Widget _buildJourneysTab() {
    final db = ref.watch(databaseProvider);
    final auth = ref.watch(supabaseAuthServiceProvider);
    final travelerName = auth.currentDisplayName;

    return StreamBuilder<List<LocalTrip>>(
      stream: db.select(db.localTrips).watch(),
      builder: (context, tripSnap) {
        final allTrips = tripSnap.data ?? [];
        final activeTrips = allTrips.where((t) => t.status == 'active').toList();
        final heroTrip = activeTrips.isNotEmpty ? activeTrips.first : (allTrips.isNotEmpty ? allTrips.first : null);

        return StreamBuilder<List<LocalExpense>>(
          stream: db.select(db.localExpenses).watch(),
          builder: (context, expSnap) {
            final allExpenses = expSnap.data ?? [];

            // Compute dynamic net balance for current user
            final currentUserId = auth.currentUserId ?? '';
            int totalPaidByMe = 0;
            int totalSpentAcrossTrips = 0;

            for (final exp in allExpenses) {
              totalSpentAcrossTrips += exp.amountMinor;
              if (exp.paidByMemberId == currentUserId) {
                totalPaidByMe += exp.amountMinor;
              }
            }

            // Estimate share (if member count > 1)
            final netPositionMinor = totalPaidByMe - (totalSpentAcrossTrips ~/ (allTrips.isEmpty ? 1 : 2));
            final isOwed = netPositionMinor >= 0;
            final netFormatted = '₹${(netPositionMinor.abs() / 100).toStringAsFixed(0)}';

            return RefreshIndicator(
              onRefresh: _fetchCloudData,
              color: AppColors.coral,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header: Greeting + Net Balance Chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hey $travelerName ✈️',
                                  style: AppTypography.display.copyWith(fontSize: 24, letterSpacing: -0.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  allTrips.isEmpty ? 'Ready for your next journey?' : 'Here is your travel summary',
                                  style: AppTypography.caption.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Dynamic Net Balance Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isOwed ? AppColors.green.withValues(alpha: 0.1) : AppColors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isOwed ? AppColors.green.withValues(alpha: 0.25) : AppColors.amber.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOwed ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  size: 14,
                                  color: isOwed ? AppColors.green : AppColors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  netPositionMinor == 0 ? 'Settled up ✓' : (isOwed ? '$netFormatted back' : 'Owe $netFormatted'),
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isOwed ? AppColors.green : AppColors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. HERO CARD (Active Trip or Zero-Trip Onboarding)
                      if (heroTrip != null) ...[
                        _buildHeroTripCard(context, heroTrip, allExpenses.where((e) => e.tripId == heroTrip.id).toList()),
                      ] else ...[
                        _buildZeroTripHeroCard(context),
                      ],
                      const SizedBox(height: 20),

                      // 3. SMART QUICK ACTIONS
                      _buildQuickActionBar(context, heroTrip),
                      const SizedBox(height: 24),

                      // 4. OTHER JOURNEYS (If 2+ trips exist)
                      if (allTrips.length > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Other journeys', style: AppTypography.titleMedium),
                            TextButton(
                              onPressed: () => context.push('/create-trip'),
                              child: Text('+ New trip', style: AppTypography.caption.copyWith(color: AppColors.coral, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildOtherTripsCarousel(context, allTrips.where((t) => t.id != heroTrip?.id).toList()),
                        const SizedBox(height: 24),
                      ],

                      // 5. RECENT ACTIVITY / EXPENSES PREVIEW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent trip expenses', style: AppTypography.titleMedium),
                          if (allExpenses.isNotEmpty && heroTrip != null)
                            TextButton(
                              onPressed: () => context.push('/trip/${heroTrip.id}'),
                              child: Text('View all →', style: AppTypography.caption.copyWith(color: AppColors.coral, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (allExpenses.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Center(
                            child: Text(
                              'No expenses logged yet. Tap "Add expense" or "Scan bill" to split your first bill!',
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(color: AppColors.muted),
                            ),
                          ),
                        ),
                      ] else ...[
                        ...allExpenses.take(4).map((exp) => _buildExpenseItem(context, exp)),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Hero Card for Active Trip
  Widget _buildHeroTripCard(BuildContext context, LocalTrip trip, List<LocalExpense> tripExpenses) {
    final totalSpentMinor = tripExpenses.fold<int>(0, (sum, e) => sum + e.amountMinor);
    final totalSpentFormatted = '₹${(totalSpentMinor / 100).toStringAsFixed(0)}';

    return GestureDetector(
      onTap: () => context.push('/trip/${trip.id}'),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: AppColors.coral, size: 8),
                      const SizedBox(width: 6),
                      Text(
                        'Active Journey',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Code: ${trip.inviteCode}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Trip Name
            Text(
              trip.name,
              style: AppTypography.display.copyWith(
                color: AppColors.cream,
                fontSize: 22,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Date & Stats
            Text(
              _formatTripDates(trip.startDate, trip.endDate),
              style: AppTypography.caption.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),

            // Spending and Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Spent', style: AppTypography.caption.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text(
                      totalSpentFormatted,
                      style: AppTypography.titleLarge.copyWith(color: AppColors.cream, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Open Trip',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.coral),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Zero-Trip Onboarding Hero Card
  Widget _buildZeroTripHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Start your first group journey',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.cream),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Create a trip to split hotels, dining, and cabs with friends without doing any math.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/create-trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create Trip'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/join-trip'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cream,
                    side: BorderSide(color: AppColors.cream.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.qr_code_rounded, size: 18),
                  label: const Text('Join Trip'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Smart Quick Action Bar
  Widget _buildQuickActionBar(BuildContext context, LocalTrip? currentTrip) {
    return Row(
      children: [
        // 1. Scan Bill (Camera OCR)
        Expanded(
          child: _buildActionPill(
            icon: Icons.camera_alt_rounded,
            label: 'Scan Bill',
            color: AppColors.coral,
            onTap: () {
              if (currentTrip != null) {
                context.push('/expense/manual?tripId=${currentTrip.id}');
              } else {
                context.push('/create-trip');
              }
            },
          ),
        ),
        const SizedBox(width: 10),

        // 2. Add Expense
        Expanded(
          child: _buildActionPill(
            icon: Icons.add_rounded,
            label: 'Add Expense',
            color: AppColors.ink,
            onTap: () {
              if (currentTrip != null) {
                context.push('/expense/manual?tripId=${currentTrip.id}');
              } else {
                context.push('/create-trip');
              }
            },
          ),
        ),
        const SizedBox(width: 10),

        // 3. Join / Invite
        Expanded(
          child: _buildActionPill(
            icon: Icons.group_add_rounded,
            label: 'Join / Invite',
            color: AppColors.green,
            onTap: () => context.push('/join-trip'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Other Trips Carousel
  Widget _buildOtherTripsCarousel(BuildContext context, List<LocalTrip> otherTrips) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: otherTrips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final trip = otherTrips[index];
          return GestureDetector(
            onTap: () => context.push('/trip/${trip.id}'),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip.name,
                    style: AppTypography.titleMedium.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.baseCurrency,
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.coral),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.muted),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Expense List Item
  Widget _buildExpenseItem(BuildContext context, LocalExpense exp) {
    final amountFormatted = '₹${(exp.amountMinor / 100).toStringAsFixed(0)}';

    return GestureDetector(
      onTap: () => context.push('/expense/${exp.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.ink, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.title,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Split: ${exp.splitMethod}',
                    style: AppTypography.caption.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Text(
              amountFormatted,
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: BALANCES TAB
  // ---------------------------------------------------------------------------
  Widget _buildBalancesTab() {
    final db = ref.watch(databaseProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Balances', style: AppTypography.display.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text('See debt settlements and who owes whom.', style: AppTypography.caption.copyWith(color: AppColors.muted)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<LocalSettlement>>(
                stream: db.select(db.localSettlements).watch(),
                builder: (context, snapshot) {
                  final settlements = snapshot.data ?? [];
                  if (settlements.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.done_all_rounded, size: 48, color: AppColors.green),
                          const SizedBox(height: 12),
                          Text('You are all settled up!', style: AppTypography.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            'No pending debts or repayments right now.',
                            style: AppTypography.caption.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: settlements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = settlements[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.status, style: AppTypography.bodyMedium),
                            Text('₹${(s.amountMinor / 100).toStringAsFixed(0)}', style: AppTypography.titleMedium),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTripDates(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'Dates to be decided';
    if (start != null && end != null) {
      return '${start.day}/${start.month} – ${end.day}/${end.month}';
    }
    return 'Ongoing';
  }
}
