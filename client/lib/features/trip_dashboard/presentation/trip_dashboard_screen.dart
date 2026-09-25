import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/sync_status_banner.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/domain/debt_simplifier.dart';
import '../../expenses/presentation/add_expense_sheet.dart';
import '../../balances_settlement/presentation/settle_sheet.dart';
import '../../itinerary/presentation/itinerary_tab_view.dart';
import '../../paywall/presentation/paywall_modal.dart';
import 'trip_summary_sheet.dart';

class TripDashboardScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDashboardScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends ConsumerState<TripDashboardScreen> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goa Trip 2026', style: AppTypography.titleMedium),
            Text('12–16 Oct · 5 members', style: AppTypography.caption),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulate Offline Expense',
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.into(db.outboundSyncQueue).insert(
                    OutboundSyncQueueCompanion.insert(
                      tripId: widget.tripId,
                      crdtUpdate: Uint8List.fromList([1, 2, 3, 4]),
                    ),
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Simulated offline mutation added to SQLite queue!',
                      style: AppTypography.bodyMedium,
                    ),
                    backgroundColor: AppColors.card,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 20, color: AppColors.coral),
          ),
          IconButton(
            tooltip: 'Trip Summary & Analytics',
            onPressed: () => TripSummarySheet.show(context),
            icon: const Icon(Icons.bar_chart_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'TripWallet Pro',
            onPressed: () => PaywallModal.show(context),
            icon: const Icon(Icons.workspace_premium_rounded, size: 20, color: AppColors.amber),
          ),
          IconButton(
            tooltip: 'Invite Crew',
            onPressed: () => context.push('/invite'),
            icon: const Icon(Icons.share_outlined, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          SyncStatusBanner(tripId: widget.tripId),
          // Stat Cards Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total spent',
                    value: '₹34,250',
                    valueColor: AppColors.cream,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    title: 'Your balance',
                    value: '+₹1,840',
                    valueColor: AppColors.green,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar Pills (Expenses / Balances / Itinerary)
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

          const Divider(height: 1),

          // Tab Content
          Expanded(
            child: _buildActiveTabContent(),
          ),
        ],
      ),
      floatingActionButton: _activeTabIndex == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => AddExpenseSheet.show(context, tripId: widget.tripId),
              backgroundColor: AppColors.coral,
              foregroundColor: AppColors.cream,
              icon: const Icon(Icons.add_rounded),
              label: Text('Add expense', style: AppTypography.button),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caption),
          const SizedBox(height: 4),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cream : AppColors.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.cream : AppColors.line,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.ink : AppColors.creamSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 0:
        final db = ref.watch(databaseProvider);
        return StreamBuilder<List<LocalExpense>>(
          stream: (db.select(db.localExpenses)..where((tbl) => tbl.tripId.equals(widget.tripId))).watch(),
          builder: (context, snapshot) {
            final localExpenses = snapshot.data ?? [];
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...localExpenses.map((e) => _buildExpenseRow(
                      title: e.title,
                      subtitle: 'Itemized split · Paid by ${e.paidByMemberId == 'm1' ? 'You' : 'Member'}',
                      amount: '₹${(e.amountMinor / 100).toStringAsFixed(2)}',
                      icon: Icons.receipt_long_rounded,
                      isNew: true,
                    )),
                _buildExpenseRow(
                  title: 'Thalassa Sunset Dinner',
                  subtitle: 'Paid by Rahul · 4 people',
                  amount: '₹6,400',
                  icon: Icons.restaurant_rounded,
                ),
                _buildExpenseRow(
                  title: 'Airport Taxi',
                  subtitle: 'Paid by You · Split equally',
                  amount: '₹1,800',
                  icon: Icons.local_taxi_rounded,
                ),
                _buildExpenseRow(
                  title: 'Villa Grocery Run',
                  subtitle: 'Paid by Priya · 5 people',
                  amount: '₹3,250',
                  icon: Icons.shopping_basket_rounded,
                ),
              ],
            );
          },
        );
      case 1:
        final db = ref.watch(databaseProvider);
        return StreamBuilder<List<LocalSettlement>>(
          stream: (db.select(db.localSettlements)..where((tbl) => tbl.tripId.equals(widget.tripId))).watch(),
          builder: (context, snapshot) {
            final settlements = snapshot.data ?? [];

            // Calculate settlements impact on debts
            // Default trip seed balances:
            // You (m1) owe Amit (m4) ₹850
            // Priya (m3) owes You (m1) ₹1,200
            // Rahul (m2) owes Amit (m4) ₹600
            final netBalances = <String, int>{
              'm1': -85000 + 120000,
              'm2': -60000,
              'm3': -120000,
              'm4': 85000 + 60000,
            };

            // Apply confirmed settlements from SQLite
            for (final s in settlements) {
              if (s.status == 'confirmed') {
                netBalances[s.fromMemberId] = (netBalances[s.fromMemberId] ?? 0) + s.amountMinor;
                netBalances[s.toMemberId] = (netBalances[s.toMemberId] ?? 0) - s.amountMinor;
              }
            }

            final simplifiedDebts = simplifyDebts(netBalances);
            final userBalance = netBalances['m1'] ?? 0;

            final memberNames = {
              'm1': 'You',
              'm2': 'Rahul',
              'm3': 'Priya',
              'm4': 'Amit',
            };

            final memberAvatars = {
              'm1': 'Y',
              'm2': 'R',
              'm3': 'P',
              'm4': 'A',
            };

            final memberColors = {
              'm1': AppColors.coral,
              'm2': AppColors.teal,
              'm3': AppColors.yellow,
              'm4': AppColors.green,
            };

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Net standing header card
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (userBalance >= 0 ? AppColors.green : AppColors.coral).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          userBalance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          color: userBalance >= 0 ? AppColors.green : AppColors.coral,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Net Standing', style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text(
                              userBalance > 0
                                  ? 'You are owed ₹${(userBalance / 100).toStringAsFixed(0)} overall'
                                  : userBalance < 0
                                      ? 'You owe ₹${((-userBalance) / 100).toStringAsFixed(0)} overall'
                                      : 'All settled up! 🎉',
                              style: AppTypography.titleMedium.copyWith(
                                color: userBalance > 0
                                    ? AppColors.green
                                    : userBalance < 0
                                        ? AppColors.coral
                                        : AppColors.cream,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Debts
                Row(
                  children: [
                    Text('SIMPLIFIED GROUP DEBTS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const Spacer(),
                    Text('Min-cash flow', style: AppTypography.caption.copyWith(color: AppColors.green, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),

                if (simplifiedDebts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 36),
                        const SizedBox(height: 8),
                        Text('Everyone is completely settled!', style: AppTypography.titleMedium),
                        const SizedBox(height: 4),
                        Text('Zero debts remaining for this trip.', style: AppTypography.caption),
                      ],
                    ),
                  )
                else
                  ...simplifiedDebts.map((debt) {
                    final fromName = memberNames[debt.fromMemberId] ?? debt.fromMemberId;
                    final toName = memberNames[debt.toMemberId] ?? debt.toMemberId;
                    final isUserDebtor = debt.fromMemberId == 'm1';
                    final isUserCreditor = debt.toMemberId == 'm1';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isUserDebtor ? AppColors.coral.withOpacity(0.5) : AppColors.line,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: (memberColors[debt.fromMemberId] ?? AppColors.coral).withOpacity(0.2),
                            child: Text(
                              memberAvatars[debt.fromMemberId] ?? '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: memberColors[debt.fromMemberId] ?? AppColors.coral,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: AppTypography.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: isUserDebtor ? 'You owe ' : '$fromName owes ',
                                        style: TextStyle(fontWeight: isUserDebtor ? FontWeight.bold : FontWeight.normal),
                                      ),
                                      TextSpan(
                                        text: isUserCreditor ? 'You' : toName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${(debt.amountMinor / 100).toStringAsFixed(2)}',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: isUserDebtor ? AppColors.coral : AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUserDebtor)
                            ElevatedButton(
                              onPressed: () {
                                SettleSheet.show(
                                  context,
                                  tripId: widget.tripId,
                                  fromMemberId: 'm1',
                                  toMemberId: debt.toMemberId,
                                  payeeName: toName,
                                  payeeVpa: debt.toMemberId == 'm4' ? 'amit@okaxis' : '${toName.toLowerCase()}@upi',
                                  amountMinor: debt.amountMinor,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.coral,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Settle', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          else if (isUserCreditor)
                            OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Payment reminder copied for $fromName: "Hey $fromName, please settle ₹${(debt.amountMinor / 100).toStringAsFixed(0)} for Goa trip!"'),
                                    backgroundColor: AppColors.paper,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.line),
                                foregroundColor: AppColors.cream,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Remind'),
                            ),
                        ],
                      ),
                    );
                  }),

                // Past Settlements Log
                if (settlements.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('SETTLEMENT HISTORY', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  ...settlements.map((s) {
                    final from = memberNames[s.fromMemberId] ?? s.fromMemberId;
                    final to = memberNames[s.toMemberId] ?? s.toMemberId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$from paid $to', style: AppTypography.bodyMedium),
                                Text('via ${s.method.toUpperCase()}', style: AppTypography.caption.copyWith(fontSize: 10)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SETTLED',
                              style: AppTypography.caption.copyWith(color: AppColors.green, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text('₹${(s.amountMinor / 100).toStringAsFixed(2)}', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        );
      default:
        return ItineraryTabView(tripId: widget.tripId);
    }
  }

  Widget _buildExpenseRow({
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    bool isNew = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isNew ? AppColors.green.withOpacity(0.15) : AppColors.paper,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isNew ? AppColors.green : AppColors.creamSoft,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NEW',
                          style: AppTypography.caption.copyWith(
                            fontSize: 9,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          Text(amount, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
