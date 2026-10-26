import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/domain/debt_simplifier.dart';
import '../../../core/domain/money.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../../../core/widgets/sync_status_banner.dart';
import '../../balances_settlement/presentation/settle_sheet.dart';
import '../../expenses/presentation/add_expense_sheet.dart';
import '../../itinerary/presentation/itinerary_tab_view.dart';
import 'trip_summary_sheet.dart';

class TripDashboardScreen extends ConsumerStatefulWidget {
  final String tripId;
  const TripDashboardScreen({super.key, required this.tripId});
  @override
  ConsumerState<TripDashboardScreen> createState() =>
      _TripDashboardScreenState();
}

class _TripDashboardScreenState extends ConsumerState<TripDashboardScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final ledger = ref.watch(ledgerProvider);
    return ledger.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this trip',
          message: 'Try reopening the trip.',
        ),
      ),
      data: (data) {
        final trip = data.trips.where((t) => t.id == widget.tripId).firstOrNull;
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Column(
              children: [
                SyncStatusBanner(),
                EmptyState(
                  icon: Icons.luggage_outlined,
                  title: 'Trip not available',
                  message:
                      'Connect to refresh your trips, or check your invite with the trip creator.',
                ),
              ],
            ),
          );
        }
        final members = data.members.where((m) => m.tripId == trip.id).toList();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'All trips',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/trips'),
            ),
            title: Text(trip.name),
            actions: [
              IconButton(
                tooltip: 'Trip summary',
                icon: const Icon(Icons.bar_chart_rounded),
                onPressed: () =>
                    TripSummarySheet.show(context, tripId: trip.id),
              ),
              IconButton(
                tooltip: 'Trip settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/trip/${trip.id}/settings'),
              ),
            ],
          ),
          body: ContentWidth(
            child: Column(
              children: [
                SyncStatusBanner(tripId: trip.id),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tripDates(trip),
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.push('/trip/${trip.id}/members'),
                        icon: const Icon(Icons.group_outlined, size: 18),
                        label: Text('${members.length} crew'),
                      ),
                    ],
                  ),
                ),
                if (trip.status == 'archived')
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Archived trip · your records are kept here.'),
                  ),
                Expanded(
                  child: _tab == 2
                      ? ItineraryTabView(tripId: trip.id)
                      : RefreshIndicator(
                          onRefresh: () =>
                              ref.read(syncEngineProvider.notifier).sync(),
                          child: _tab == 0
                              ? _expenses(trip, data)
                              : _balances(trip, data, members),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: trip.status == 'active' && _tab != 2
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      AddExpenseSheet.show(context, tripId: trip.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add expense'),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.balance_outlined),
                label: 'Balances',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                label: 'Itinerary',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _expenses(LocalTrip trip, LedgerData data) {
    final expenses = data.expenses.where((e) => e.tripId == trip.id).toList();
    final total = expenses.fold(0, (int sum, e) => sum + e.amountMinor);
    final myId = data.myMemberId(trip.id, ref.watch(accountIdProvider) ?? '');
    int? balance;
    try {
      balance = data.balances(trip.id)[myId] ?? 0;
    } catch (_) {}
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.coral,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Group spending',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                formatMoney(total, trip.baseCurrency),
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        balance == null
                            ? 'Your balance'
                            : balance < 0
                            ? 'You owe'
                            : balance > 0
                            ? 'You’re owed'
                            : 'You’re all square',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        balance == null
                            ? 'Needs sync'
                            : formatMoney(balance.abs(), trip.baseCurrency),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.coral,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: Text('Expenses', style: AppTypography.titleLarge)),
            Text('${expenses.length} expenses', style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: 16),
        if (expenses.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Start with the first bill',
            message:
                'Add an expense or scan a receipt. Everyone’s share stays together here.',
          )
        else
          ...expenses.map((e) => ExpenseTile(expense: e, data: data)),
      ],
    );
  }

  Widget _balances(LocalTrip trip, LedgerData data, List<LocalMember> members) {
    Map<String, int> balances;
    try {
      balances = data.balances(trip.id);
    } catch (e) {
      return ListView(
        children: const [
          EmptyState(
            icon: Icons.sync_problem,
            title: 'Split details need syncing',
            message:
                'Connect and refresh to restore this trip’s exact member shares before settling.',
          ),
        ],
      );
    }
    final debts = simplifyDebts(balances);
    final myId = data.myMemberId(trip.id, ref.watch(accountIdProvider) ?? '');
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text('Who owes whom', style: AppTypography.display),
        const SizedBox(height: 8),
        Text(
          'Suggested transfers to settle the group with fewer payments.',
          style: AppTypography.bodyLarge,
        ),
        const SizedBox(height: 24),
        if (debts.isEmpty)
          EmptyState(
            icon: Icons.check_circle_outline,
            title: data.expenses.any((e) => e.tripId == trip.id)
                ? 'All settled up'
                : 'Nothing to settle yet',
            message: 'There are no outstanding balances in this trip.',
          ),
        ...debts.map((debt) {
          final payee = members
              .where((m) => m.id == debt.toMemberId)
              .firstOrNull;
          final own = debt.fromMemberId == myId;
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${own ? 'You' : data.memberName(debt.fromMemberId)} owe ${debt.toMemberId == myId ? 'you' : data.memberName(debt.toMemberId)}',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatMoney(debt.amountMinor, trip.baseCurrency),
                    style: AppTypography.titleLarge.copyWith(
                      color: own ? AppColors.coralDark : AppColors.green,
                    ),
                  ),
                  if (own && trip.status == 'active') ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => SettleSheet.show(
                        context,
                        tripId: trip.id,
                        tripName: trip.name,
                        fromMemberId: debt.fromMemberId,
                        toMemberId: debt.toMemberId,
                        payeeName: payee?.displayName ?? 'Member',
                        payeeVpa: payee?.paymentVpa ?? '',
                        amountMinor: debt.amountMinor,
                        currency: trip.baseCurrency,
                      ),
                      icon: const Icon(Icons.north_east, size: 18),
                      label: const Text('Settle this balance'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        if (data.settlements.any((s) => s.tripId == trip.id)) ...[
          const SizedBox(height: 20),
          Text('Recorded payments', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          ...data.settlements
              .where((s) => s.tripId == trip.id)
              .map(
                (s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.green,
                  ),
                  title: Text(
                    '${data.memberName(s.fromMemberId)} → ${data.memberName(s.toMemberId)}',
                  ),
                  subtitle: Text('Reported by payer · ${s.method}'),
                  trailing: Text(formatMoney(s.amountMinor, s.currency)),
                ),
              ),
        ],
      ],
    );
  }
}
