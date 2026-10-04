import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/supabase_auth_service.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/domain/debt_simplifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/sync_status_banner.dart';
import '../../../core/widgets/trip_wallet_bottom_nav_bar.dart';
import '../../balances_settlement/presentation/settle_sheet.dart';
import '../../expenses/data/supabase_expenses_service.dart';
import '../../expenses/presentation/add_expense_sheet.dart';
import '../../itinerary/presentation/itinerary_tab_view.dart';
import '../../paywall/presentation/pass_active_screen.dart';
import '../../trips/data/supabase_trips_service.dart';
import 'trip_summary_sheet.dart';

class TripDashboardScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDashboardScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends ConsumerState<TripDashboardScreen> {
  int _activeTabIndex = 0; // 0: Expenses, 1: Balances, 2: Itinerary, 3: Pass
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTripData();
    });
  }

  Future<void> _syncTripData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final tripsService = ref.read(supabaseTripsServiceProvider);
      final expensesService = ref.read(supabaseExpensesServiceProvider);
      final db = ref.read(databaseProvider);

      // 1. Members
      final members = await tripsService.fetchTripMembers(widget.tripId);
      for (final m in members) {
        await db.into(db.localMembers).insertOnConflictUpdate(
              LocalMembersCompanion(
                id: drift.Value(m.id),
                tripId: drift.Value(m.tripId),
                displayName: drift.Value(m.displayName),
                role: drift.Value(m.role),
              ),
            );
      }

      // 2. Expenses
      final expenses = await expensesService.fetchExpenses(widget.tripId);
      for (final e in expenses) {
        await db.into(db.localExpenses).insertOnConflictUpdate(
              LocalExpensesCompanion(
                id: drift.Value(e.id),
                tripId: drift.Value(e.tripId),
                title: drift.Value(e.title),
                amountMinor: drift.Value(e.amountMinor),
                currency: drift.Value(e.currency),
                paidByMemberId: drift.Value(e.paidByUserId),
                splitMethod: drift.Value(e.splitMethod),
                taxMinor: drift.Value(e.taxMinor),
                serviceChargeMinor: drift.Value(e.serviceChargeMinor),
                createdAt: drift.Value(e.createdAt),
              ),
            );
      }

      // 3. Settlements
      final settlements = await expensesService.fetchSettlements(widget.tripId);
      for (final s in settlements) {
        await db.into(db.localSettlements).insertOnConflictUpdate(
              LocalSettlementsCompanion(
                id: drift.Value(s.id),
                tripId: drift.Value(s.tripId),
                fromMemberId: drift.Value(s.fromUserId),
                toMemberId: drift.Value(s.toUserId),
                amountMinor: drift.Value(s.amountMinor),
                currency: drift.Value(s.currency),
                method: drift.Value(s.method),
                status: drift.Value(s.status),
                createdAt: drift.Value(s.createdAt),
              ),
            );
      }
    } catch (e) {
      debugPrint('Trip data sync note: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  String _formatDates(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Active trip';
    const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    if (start.month == end.month) {
      return '${start.day}–${end.day} ${months[start.month - 1]}';
    }
    return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<LocalTrip?>(
      stream: (db.select(db.localTrips)..where((t) => t.id.equals(widget.tripId))).watchSingleOrNull(),
      builder: (context, tripSnapshot) {
        final trip = tripSnapshot.data;
        final tripTitle = trip?.name ?? 'Trip';
        final tripDates = _formatDates(trip?.startDate, trip?.endDate);

        return StreamBuilder<List<LocalMember>>(
          stream: (db.select(db.localMembers)..where((m) => m.tripId.equals(widget.tripId))).watch(),
          builder: (context, memberSnapshot) {
            final members = memberSnapshot.data ?? [];
            final memberCount = members.isNotEmpty ? members.length : 1;

            return Scaffold(
              backgroundColor: AppColors.card,
              appBar: AppBar(
                backgroundColor: AppColors.card,
                elevation: 0,
                title: InkWell(
                  onTap: () => context.push('/trips'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                tripTitle,
                                style: AppTypography.titleLarge.copyWith(fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.inkSoft),
                          ],
                        ),
                        InkWell(
                          onTap: () => context.push('/trip/${widget.tripId}/members'),
                          child: Text(
                            '$memberCount member${memberCount == 1 ? '' : 's'} · $tripDates',
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  // Refresh indicator
                  IconButton(
                    tooltip: 'Sync with cloud',
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral),
                          )
                        : const Icon(Icons.sync_rounded, size: 20),
                    onPressed: _syncTripData,
                  ),
                  // Summary Icon
                  IconButton(
                    tooltip: 'Trip Summary',
                    icon: const Icon(Icons.bar_chart_rounded, size: 22),
                    onPressed: () => TripSummarySheet.show(context, tripId: widget.tripId),
                  ),
                  // More options overflow menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 22),
                    tooltip: 'More options',
                    onSelected: (value) {
                      if (value == 'settings') {
                        context.push('/trip/${widget.tripId}/settings');
                      } else if (value == 'alerts') {
                        context.push('/alerts');
                      } else if (value == 'profile') {
                        context.push('/profile');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Trip Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'alerts',
                        child: Row(
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Activity & Alerts'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Profile & UPI'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  SyncStatusBanner(tripId: widget.tripId),
                  Expanded(
                    child: _buildActiveContent(members, tripTitle),
                  ),
                ],
              ),
              bottomNavigationBar: TripWalletBottomNavBar(
                currentIndex: _activeTabIndex,
                onTabSelected: (index) => setState(() => _activeTabIndex = index),
                onScanPressed: () => AddExpenseSheet.show(context, tripId: widget.tripId),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveContent(List<LocalMember> members, String tripName) {
    switch (_activeTabIndex) {
      case 0:
        return _buildExpensesTab(members);
      case 1:
        return _buildBalancesTab(members);
      case 2:
        return ItineraryTabView(tripId: widget.tripId);
      case 3:
      default:
        return PassActiveScreen(tripName: tripName);
    }
  }

  Widget _buildExpensesTab(List<LocalMember> members) {
    final db = ref.watch(databaseProvider);
    final auth = ref.watch(supabaseAuthServiceProvider);

    return StreamBuilder<List<LocalExpense>>(
      stream: (db.select(db.localExpenses)..where((tbl) => tbl.tripId.equals(widget.tripId))).watch(),
      builder: (context, snapshot) {
        final expenses = snapshot.data ?? [];
        final totalMinor = expenses.fold<int>(0, (sum, e) => sum + e.amountMinor);

        return StreamBuilder<List<LocalSettlement>>(
          stream: (db.select(db.localSettlements)..where((tbl) => tbl.tripId.equals(widget.tripId))).watch(),
          builder: (context, settlementSnapshot) {
            final settlements = settlementSnapshot.data ?? [];

            // Find current user's local member representation
            final currentUserId = auth.currentUser?.id;
            final youMember = members.firstWhere(
              (m) =>
                  (currentUserId != null && m.id == currentUserId) ||
                  m.displayName.toLowerCase() == 'you' ||
                  m.displayName.toLowerCase() == auth.currentDisplayName.toLowerCase(),
              orElse: () => members.isNotEmpty ? members.first : const LocalMember(id: 'me', tripId: '', displayName: 'You', role: 'member'),
            );
            final youMemberId = youMember.id;

            var youBalanceMinor = 0;
            if (expenses.isNotEmpty) {
              final memberCount = members.isNotEmpty ? members.length : 1;
              for (final e in expenses) {
                final share = e.amountMinor ~/ memberCount;
                if (e.paidByMemberId == youMemberId) {
                  youBalanceMinor += (e.amountMinor - share);
                } else {
                  youBalanceMinor -= share;
                }
              }
              for (final s in settlements) {
                if (s.status == 'confirmed') {
                  if (s.fromMemberId == youMemberId) youBalanceMinor += s.amountMinor;
                  if (s.toMemberId == youMemberId) youBalanceMinor -= s.amountMinor;
                }
              }
            }

            final totalSpentFormatted = '₹${(totalMinor / 100).toStringAsFixed(0)}';
            final youOwedFormatted = youBalanceMinor >= 0
                ? '₹${(youBalanceMinor / 100).toStringAsFixed(0)}'
                : '-₹${((-youBalanceMinor) / 100).toStringAsFixed(0)}';

            return RefreshIndicator(
              onRefresh: _syncTripData,
              color: AppColors.coral,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Top Tab Bar Pills (Expenses | Balances | Itinerary)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildTabPill('Expenses', 0),
                        const SizedBox(width: 8),
                        _buildTabPill('Balances', 1),
                        const SizedBox(width: 8),
                        _buildTabPill('Itinerary', 2),
                      ],
                    ),
                  ),

                  // Stat Cards Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total spent',
                            value: totalSpentFormatted,
                            valueColor: AppColors.inkText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            title: youBalanceMinor >= 0 ? "You're owed" : 'You owe',
                            value: youOwedFormatted,
                            valueColor: youBalanceMinor >= 0 ? AppColors.green : AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RECENT label
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'RECENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSoft,
                        letterSpacing: 0.05,
                      ),
                    ),
                  ),

                  // Expense Rows
                  if (expenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.inkSoft),
                            const SizedBox(height: 12),
                            Text('No expenses logged yet.', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('Tap + Scan bill below to log your first expense.', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  else
                    ...expenses.map((e) {
                      final payerMember = members.firstWhere(
                        (m) => m.id == e.paidByMemberId,
                        orElse: () => LocalMember(
                          id: e.paidByMemberId,
                          tripId: widget.tripId,
                          displayName: e.paidByMemberId == youMemberId ? 'You' : 'Member',
                          role: 'member',
                        ),
                      );

                      IconData icon = Icons.restaurant_rounded;
                      final titleLower = e.title.toLowerCase();
                      if (titleLower.contains('cab') || titleLower.contains('taxi') || titleLower.contains('uber')) {
                        icon = Icons.directions_car_rounded;
                      } else if (titleLower.contains('scooter') || titleLower.contains('bike') || titleLower.contains('fuel')) {
                        icon = Icons.two_wheeler_rounded;
                      } else if (titleLower.contains('hotel') || titleLower.contains('resort') || titleLower.contains('stay')) {
                        icon = Icons.hotel_rounded;
                      } else if (titleLower.contains('flight') || titleLower.contains('train')) {
                        icon = Icons.flight_takeoff_rounded;
                      }

                      return InkWell(
                        onTap: () => context.push('/expense/${e.id}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.paper,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(icon, color: AppColors.inkSoft, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('${payerMember.displayName} · split ${e.splitMethod}', style: AppTypography.caption),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${(e.amountMinor / 100).toStringAsFixed(0)}',
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBalancesTab(List<LocalMember> members) {
    final db = ref.watch(databaseProvider);
    final auth = ref.watch(supabaseAuthServiceProvider);

    return StreamBuilder<List<LocalExpense>>(
      stream: (db.select(db.localExpenses)..where((tbl) => tbl.tripId.equals(widget.tripId))).watch(),
      builder: (context, expSnapshot) {
        return StreamBuilder<List<LocalSettlement>>(
          stream: (db.select(db.localSettlements)..where((tbl) => tbl.tripId.equals(widget.tripId))).watch(),
          builder: (context, setSnapshot) {
            final expenses = expSnapshot.data ?? [];
            final settlements = setSnapshot.data ?? [];

            final currentUserId = auth.currentUser?.id;
            final youMember = members.firstWhere(
              (m) =>
                  (currentUserId != null && m.id == currentUserId) ||
                  m.displayName.toLowerCase() == 'you' ||
                  m.displayName.toLowerCase() == auth.currentDisplayName.toLowerCase(),
              orElse: () => members.isNotEmpty ? members.first : const LocalMember(id: 'me', tripId: '', displayName: 'You', role: 'member'),
            );
            final youMemberId = youMember.id;

            // Compute net balance per member dynamically
            final netBalances = <String, int>{};
            for (final m in members) {
              netBalances[m.id] = 0;
            }

            final memberCount = members.isNotEmpty ? members.length : 1;
            for (final e in expenses) {
              final share = e.amountMinor ~/ memberCount;
              for (final m in members) {
                if (m.id == e.paidByMemberId) {
                  netBalances[m.id] = (netBalances[m.id] ?? 0) + (e.amountMinor - share);
                } else {
                  netBalances[m.id] = (netBalances[m.id] ?? 0) - share;
                }
              }
            }

            for (final s in settlements) {
              if (s.status == 'confirmed') {
                netBalances[s.fromMemberId] = (netBalances[s.fromMemberId] ?? 0) + s.amountMinor;
                netBalances[s.toMemberId] = (netBalances[s.toMemberId] ?? 0) - s.amountMinor;
              }
            }

            final simplifiedDebts = simplifyDebts(netBalances);

            return RefreshIndicator(
              onRefresh: _syncTripData,
              color: AppColors.coral,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Top Tab Bar Pills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildTabPill('Expenses', 0),
                        const SizedBox(width: 8),
                        _buildTabPill('Balances', 1),
                        const SizedBox(width: 8),
                        _buildTabPill('Itinerary', 2),
                      ],
                    ),
                  ),

                  // Subheader: "Who owes who"
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Who owes who',
                      style: AppTypography.titleMedium.copyWith(fontSize: 14),
                    ),
                  ),

                  // Balance Rows
                  if (simplifiedDebts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.green),
                            const SizedBox(height: 12),
                            Text('All settled up! 🎉', style: AppTypography.titleMedium.copyWith(color: AppColors.green)),
                            const SizedBox(height: 4),
                            Text('No outstanding balances between group members.', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  else
                    ...simplifiedDebts.map((debt) {
                      final isYouOwer = debt.fromMemberId == youMemberId;
                      final isYouReceiver = debt.toMemberId == youMemberId;

                      final fromMember = members.firstWhere(
                        (m) => m.id == debt.fromMemberId,
                        orElse: () => LocalMember(id: debt.fromMemberId, tripId: widget.tripId, displayName: isYouOwer ? 'You' : 'Member', role: 'member'),
                      );
                      final toMember = members.firstWhere(
                        (m) => m.id == debt.toMemberId,
                        orElse: () => LocalMember(id: debt.toMemberId, tripId: widget.tripId, displayName: isYouReceiver ? 'You' : 'Member', role: 'member'),
                      );

                      final fromName = isYouOwer ? 'You' : fromMember.displayName;
                      final toName = isYouReceiver ? 'You' : toMember.displayName;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isYouOwer
                                    ? 'You owe $toName'
                                    : isYouReceiver
                                        ? "You're owed by $fromName"
                                        : '$fromName owes $toName',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isYouReceiver ? AppColors.green : AppColors.inkText,
                                ),
                              ),
                            ),
                            Text(
                              '₹${(debt.amountMinor / 100).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isYouReceiver ? AppColors.green : AppColors.inkText,
                              ),
                            ),
                            if (isYouOwer) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => SettleSheet.show(
                                  context,
                                  tripId: widget.tripId,
                                  fromMemberId: debt.fromMemberId,
                                  toMemberId: debt.toMemberId,
                                  payeeName: toName,
                                  payeeVpa: '${toName.toLowerCase().replaceAll(' ', '')}@okhdfcbank',
                                  amountMinor: debt.amountMinor,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.ink,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Settle',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caption),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(color: valueColor, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}
