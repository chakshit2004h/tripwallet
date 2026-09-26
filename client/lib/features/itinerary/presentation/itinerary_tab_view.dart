import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import 'add_stop_sheet.dart';

class ItineraryTabView extends ConsumerStatefulWidget {
  final String tripId;

  const ItineraryTabView({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryTabView> createState() => _ItineraryTabViewState();
}

class _ItineraryTabViewState extends ConsumerState<ItineraryTabView> {
  int _selectedDay = 0;

  final List<String> _dayLabels = ['Day 1', 'Day 2', 'Day 3'];

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<LocalItineraryStop>>(
      stream: (db.select(db.localItineraryStops)..where((tbl) => tbl.tripId.equals(widget.tripId))).watch(),
      builder: (context, snapshot) {
        final allStops = snapshot.data ?? [];
        final dayStops = allStops.where((s) => s.dayIndex == _selectedDay).toList();

        return Column(
          children: [
            // Day selector tabs matching Step 17
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: List.generate(_dayLabels.length, (index) {
                  final isSelected = _selectedDay == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDay = index),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.ink : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected ? AppColors.ink : AppColors.line,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _dayLabels[index],
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Stop rows matching Step 17
            Expanded(
              child: dayStops.isEmpty
                  ? Center(
                      child: Text('No stops for Day ${_selectedDay + 1} yet', style: AppTypography.bodySmall),
                    )
                  : ListView.builder(
                      itemCount: dayStops.length,
                      itemBuilder: (context, index) {
                        final stop = dayStops[index];
                        IconData icon = Icons.flight_takeoff_rounded;
                        if (stop.type == 'hotel') {
                          icon = Icons.hotel_rounded;
                        } else if (stop.type == 'food') {
                          icon = Icons.restaurant_rounded;
                        } else if (stop.type == 'activity') {
                          icon = Icons.surfing_rounded;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: AppColors.line, width: 0.5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(icon, size: 18, color: AppColors.inkSoft),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.title,
                                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${stop.time} · ${stop.subtitle}',
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // "+ Add to day X" ghost button matching Step 17
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    AddStopSheet.show(
                      context,
                      initialDayIndex: _selectedDay,
                      onAdd: (newStop) async {
                        await db.into(db.localItineraryStops).insert(
                              LocalItineraryStopsCompanion.insert(
                                id: newStop.id,
                                tripId: widget.tripId,
                                dayIndex: newStop.dayIndex,
                                time: newStop.time,
                                title: newStop.title,
                                subtitle: newStop.subtitle,
                                type: newStop.type,
                              ),
                            );
                      },
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add to day ${_selectedDay + 1}'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
