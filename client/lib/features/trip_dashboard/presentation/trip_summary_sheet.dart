import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TripSummarySheet extends StatelessWidget {
  final String tripTitle;
  final String dateRange;

  const TripSummarySheet({
    super.key,
    this.tripTitle = 'Goa Weekend 2026',
    this.dateRange = '12–16 Oct 2026 · 5 members',
  });

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const TripSummarySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lineHeavy,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart_rounded, color: AppColors.coral, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tripTitle, style: AppTypography.titleLarge),
                    Text(dateRange, style: AppTypography.caption),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Metric Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL TRIP SPENDING', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹34,250',
                              style: AppTypography.display.copyWith(fontSize: 32, color: AppColors.coral),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'across 6 items',
                              style: AppTypography.caption.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'All settlements confirmed & balanced',
                              style: AppTypography.caption.copyWith(color: AppColors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Spend Distribution
                  Text('WHO PAID WHAT', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 10),

                  _buildMemberSpendBar(name: 'Rahul', paidAmount: '₹15,400', percentage: 0.45, color: AppColors.coral),
                  const SizedBox(height: 10),
                  _buildMemberSpendBar(name: 'You (Chakshit)', paidAmount: '₹10,250', percentage: 0.30, color: const Color(0xFF4EA8DE)),
                  const SizedBox(height: 10),
                  _buildMemberSpendBar(name: 'Priya', paidAmount: '₹5,100', percentage: 0.15, color: AppColors.green),
                  const SizedBox(height: 10),
                  _buildMemberSpendBar(name: 'Amit', paidAmount: '₹3,500', percentage: 0.10, color: AppColors.amber),
                  const SizedBox(height: 24),

                  // Top spender badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Rahul was the top spender, covering 45% of the trip!',
                            style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Export Section
                  Text('EXPORT & ARCHIVE', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Generated Goa_Trip_2026_Summary.pdf!', style: AppTypography.bodyMedium),
                                backgroundColor: AppColors.card,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: AppColors.coral),
                          label: const Text('Export PDF'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Exported Goa_Trip_Expenses.csv!', style: AppTypography.bodyMedium),
                                backgroundColor: AppColors.card,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.table_chart_rounded, size: 18, color: AppColors.green),
                          label: const Text('Export Excel CSV'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSpendBar({
    required String name,
    required String paidAmount,
    required double percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '$paidAmount (${(percentage * 100).toInt()}%)',
                style: AppTypography.caption.copyWith(color: AppColors.cream, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
