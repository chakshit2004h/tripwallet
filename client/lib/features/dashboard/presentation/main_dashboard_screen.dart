import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/supabase_auth_service.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/db/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../../../core/widgets/journey_art.dart';
import '../../../core/widgets/sync_status_banner.dart';
import '../../alerts/presentation/alerts_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class MainDashboardScreen extends ConsumerStatefulWidget {
  const MainDashboardScreen({super.key});
  @override
  ConsumerState<MainDashboardScreen> createState() =>
      _MainDashboardScreenState();
}

class _MainDashboardScreenState extends ConsumerState<MainDashboardScreen> {
  int _tab = 0;
  bool _archived = false;
  @override
  Widget build(BuildContext context) {
    ref.watch(syncEngineProvider);
    final ledger = ref.watch(ledgerProvider);
    return Scaffold(
      body: SafeArea(
        child: _tab == 1
            ? const AlertsScreen()
            : _tab == 2
            ? const ProfileScreen()
            : Column(
                children: [
                  const SyncStatusBanner(),
                  Expanded(
                    child: ledger.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => const EmptyState(
                        icon: Icons.error_outline,
                        title: 'Could not load your trips',
                        message: 'Close and reopen the app to try again.',
                      ),
                      data: (data) => ContentWidth(
                        child: RefreshIndicator(
                          onRefresh: () =>
                              ref.read(syncEngineProvider.notifier).sync(),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'LET’S GO SOMEWHERE',
                                          style: AppTypography.caption.copyWith(
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Your trips',
                                          style: AppTypography.display,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    tooltip: 'Your profile',
                                    onPressed: () => setState(() => _tab = 2),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.ink,
                                      foregroundColor: AppColors.coral,
                                      minimumSize: const Size(48, 48),
                                    ),
                                    icon: Text(
                                      _initial(
                                        ref
                                            .watch(supabaseAuthServiceProvider)
                                            .currentDisplayName,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColors.coral,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (data.trips.isEmpty) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: const JourneyArt(height: 150),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Every great trip starts here.',
                                  style: AppTypography.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Invite your people. Track what you spend. Enjoy the journey.',
                                  style: AppTypography.bodyLarge,
                                ),
                                const SizedBox(height: 22),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          context.push('/create-trip'),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 20,
                                      ),
                                      label: const Text('New trip'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          context.push('/join-trip'),
                                      icon: const Icon(
                                        Icons.group_add_outlined,
                                        size: 20,
                                      ),
                                      label: const Text('Join trip'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              SegmentedButton<bool>(
                                showSelectedIcon: false,
                                segments: [
                                  ButtonSegment(
                                    value: false,
                                    label: Text(
                                      'Active (${data.trips.where((t) => t.status != 'archived').length})',
                                    ),
                                  ),
                                  const ButtonSegment(
                                    value: true,
                                    label: Text('Past trips'),
                                  ),
                                ],
                                selected: {_archived},
                                onSelectionChanged: (v) =>
                                    setState(() => _archived = v.first),
                              ),
                              const SizedBox(height: 20),
                              if (data.trips
                                  .where(
                                    (t) =>
                                        (t.status == 'archived') == _archived,
                                  )
                                  .isEmpty)
                                EmptyState(
                                  icon: Icons.luggage_outlined,
                                  title: _archived
                                      ? 'No past trips yet'
                                      : 'Your first adventure awaits',
                                  message: _archived
                                      ? 'Archived trips stay here with their expenses and balances.'
                                      : 'Create a trip or join your friends using their invite code.',
                                )
                              else
                                ...data.trips
                                    .where(
                                      (t) =>
                                          (t.status == 'archived') == _archived,
                                    )
                                    .map((t) => _tripCard(t, data)),
                              if (data.expenses.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text(
                                  'Recent expenses',
                                  style: AppTypography.titleLarge,
                                ),
                                const SizedBox(height: 14),
                                ...data.expenses
                                    .take(5)
                                    .map(
                                      (e) =>
                                          ExpenseTile(expense: e, data: data),
                                    ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _initial(String name) =>
      name.trim().isEmpty ? 'T' : name.trim().characters.first.toUpperCase();

  Widget _tripCard(LocalTrip trip, LedgerData data) {
    final members = data.members.where((m) => m.tripId == trip.id).toList();
    final total = data.expenses
        .where((e) => e.tripId == trip.id)
        .fold(0, (int sum, e) => sum + e.amountMinor);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/trip/${trip.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  const JourneyArt(height: 100),
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trip.status == 'archived'
                            ? 'PAST TRIP'
                            : 'LET’S EXPLORE',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(trip.name, style: AppTypography.titleLarge),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.inkSoft,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          tripDates(trip),
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      ...members
                          .take(3)
                          .map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.coralTint,
                                child: Text(
                                  _initial(m.displayName),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${members.length} ${members.length == 1 ? 'person' : 'people'}',
                          style: AppTypography.caption,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GROUP SPENDING',
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              letterSpacing: .8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatMoney(total, trip.baseCurrency),
                            style: AppTypography.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
