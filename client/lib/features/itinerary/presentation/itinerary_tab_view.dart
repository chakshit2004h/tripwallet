import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/itinerary_models.dart';
import 'add_stop_sheet.dart';

class ItineraryTabView extends StatefulWidget {
  final String tripId;

  const ItineraryTabView({super.key, required this.tripId});

  @override
  State<ItineraryTabView> createState() => _ItineraryTabViewState();
}

class _ItineraryTabViewState extends State<ItineraryTabView> {
  int _selectedDay = 0;
  late List<ItineraryStop> _stops;

  final List<String> _dayLabels = [
    'Day 1 · Oct 12',
    'Day 2 · Oct 13',
    'Day 3 · Oct 14',
  ];

  @override
  void initState() {
    super.initState();
    _stops = ItineraryStop.defaultGoaStops();
  }

  void _handleAddStop() {
    AddStopSheet.show(
      context,
      initialDayIndex: _selectedDay,
      onAdd: (newStop) {
        setState(() {
          _stops.add(newStop);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${newStop.title}" to schedule', style: AppTypography.bodyMedium),
            backgroundColor: AppColors.card,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayStops = _stops.where((s) => s.dayIndex == _selectedDay).toList();

    return Column(
      children: [
        // Day selector pills
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(_dayLabels.length, (index) {
              final isSelected = _selectedDay == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedDay = index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.coral : AppColors.paper,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.coral : AppColors.line,
                      ),
                    ),
                    child: Text(
                      _dayLabels[index],
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? AppColors.ink : AppColors.cream,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Subheader banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${dayStops.length} stops planned',
                style: AppTypography.caption.copyWith(color: AppColors.muted),
              ),
              TextButton.icon(
                onPressed: _handleAddStop,
                icon: const Icon(Icons.add, size: 16, color: AppColors.coral),
                label: Text(
                  'Add Stop',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Stops Timeline List
        Expanded(
          child: dayStops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_available_rounded, size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text('No stops for this day yet', style: AppTypography.bodyLarge),
                      const SizedBox(height: 6),
                      Text('Tap "+ Add Stop" to plan meals, sights or flights', style: AppTypography.caption),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: dayStops.length,
                  itemBuilder: (context, index) {
                    final stop = dayStops[index];
                    final isFirst = index == 0;
                    final isLast = index == dayStops.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline indicator
                          SizedBox(
                            width: 24,
                            child: Column(
                              children: [
                                Container(
                                  width: 2,
                                  height: 8,
                                  color: isFirst ? Colors.transparent : AppColors.lineHeavy,
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _typeColor(stop.type),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.ink, width: 2),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isLast ? Colors.transparent : AppColors.lineHeavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Stop Card
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.card,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          stop.time,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.coral,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_typeEmoji(stop.type)),
                                      const Spacer(),
                                      if (stop.bookingRef != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.ink,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.line),
                                          ),
                                          child: Text(
                                            'REF: ${stop.bookingRef}',
                                            style: AppTypography.caption.copyWith(
                                              fontSize: 9,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    stop.title,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.cream,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    stop.subtitle,
                                    style: AppTypography.caption.copyWith(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'flight':
        return AppColors.coral;
      case 'hotel':
        return const Color(0xFF9B5DE5);
      case 'food':
        return AppColors.amber;
      case 'activity':
      default:
        return AppColors.green;
    }
  }

  String _typeEmoji(String type) {
    switch (type) {
      case 'flight':
        return '✈️';
      case 'hotel':
        return '🏨';
      case 'food':
        return '🍽️';
      case 'activity':
      default:
        return '🏄';
    }
  }
}
