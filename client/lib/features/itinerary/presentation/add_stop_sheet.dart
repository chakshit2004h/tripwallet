import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/itinerary_models.dart';

class AddStopSheet extends StatefulWidget {
  final int initialDayIndex;
  final ValueChanged<ItineraryStop> onAdd;

  const AddStopSheet({
    super.key,
    required this.initialDayIndex,
    required this.onAdd,
  });

  static Future<void> show(
    BuildContext context, {
    required int initialDayIndex,
    required ValueChanged<ItineraryStop> onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddStopSheet(
        initialDayIndex: initialDayIndex,
        onAdd: onAdd,
      ),
    );
  }

  @override
  State<AddStopSheet> createState() => _AddStopSheetState();
}

class _AddStopSheetState extends State<AddStopSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _timeController;
  late final TextEditingController _bookingRefController;

  late int _selectedDay;
  String _selectedType = 'food';

  final List<String> _types = ['activity', 'food', 'hotel', 'flight'];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDayIndex;
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _timeController = TextEditingController(text: '07:00 PM');
    _bookingRefController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _timeController.dispose();
    _bookingRefController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final stop = ItineraryStop(
      id: 'stop-${DateTime.now().millisecondsSinceEpoch}',
      dayIndex: _selectedDay,
      time: _timeController.text.trim().isEmpty ? '12:00 PM' : _timeController.text.trim(),
      title: title,
      subtitle: _subtitleController.text.trim().isEmpty ? 'Goa' : _subtitleController.text.trim(),
      type: _selectedType,
      bookingRef: _bookingRefController.text.trim().isEmpty ? null : _bookingRefController.text.trim(),
    );

    widget.onAdd(stop);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 24 + keyboardHeight,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Text('Add Itinerary Stop', style: AppTypography.titleLarge),
            const SizedBox(height: 4),
            Text('Schedule an activity, reservation or transport', style: AppTypography.caption),
            const SizedBox(height: 20),

            // Day Selector Chips
            Text('SELECT DAY', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDayChip('Day 1 (Oct 12)', 0),
                const SizedBox(width: 8),
                _buildDayChip('Day 2 (Oct 13)', 1),
                const SizedBox(width: 8),
                _buildDayChip('Day 3 (Oct 14)', 2),
              ],
            ),
            const SizedBox(height: 18),

            // Type selector
            Text('TYPE', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _types.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text('${_typeEmoji(type)} ${type[0].toUpperCase()}${type.substring(1)}'),
                  selected: isSelected,
                  selectedColor: AppColors.coral.withOpacity(0.2),
                  backgroundColor: AppColors.card,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.coral : AppColors.cream,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.coral : AppColors.line,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              autofocus: true,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
              decoration: const InputDecoration(
                labelText: 'Stop Title (e.g. Thalassa Dinner)',
                prefixIcon: Icon(Icons.place_outlined, color: AppColors.coral),
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle / Location
            TextField(
              controller: _subtitleController,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
              decoration: const InputDecoration(
                labelText: 'Location or Details (e.g. Vagator Beach)',
                prefixIcon: Icon(Icons.info_outline, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 12),

            // Time & Booking Ref row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeController,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
                    decoration: const InputDecoration(
                      labelText: 'Time (e.g. 08:00 PM)',
                      prefixIcon: Icon(Icons.access_time_rounded, color: AppColors.muted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _bookingRefController,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
                    decoration: const InputDecoration(
                      labelText: 'Ref (Optional)',
                      prefixIcon: Icon(Icons.confirmation_number_outlined, color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Add Stop to Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, int index) {
    final isSelected = _selectedDay == index;
    return InkWell(
      onTap: () => setState(() => _selectedDay = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.coral : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.ink : AppColors.cream,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
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
