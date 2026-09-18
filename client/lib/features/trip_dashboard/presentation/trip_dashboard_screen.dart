import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/sync_status_banner.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../expenses/presentation/add_expense_sheet.dart';

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
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 20),
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
      floatingActionButton: FloatingActionButton.extended(
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
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.paper,
                    child: Text('A', style: TextStyle(color: AppColors.cream)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amit owes you', style: AppTypography.bodyMedium),
                        Text('₹850', style: AppTypography.titleMedium.copyWith(color: AppColors.green)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paper,
                      foregroundColor: AppColors.cream,
                      minimumSize: const Size(80, 36),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    child: const Text('Remind'),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Center(
          child: Text('Itinerary (Phase 5)', style: AppTypography.bodyLarge),
        );
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
