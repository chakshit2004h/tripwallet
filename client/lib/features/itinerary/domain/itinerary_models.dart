class ItineraryStop {
  final String id;
  final int dayIndex;
  final String time;
  final String title;
  final String subtitle;
  final String type; // 'flight', 'hotel', 'food', 'activity'
  final String? bookingRef;
  final String? notes;

  const ItineraryStop({
    required this.id,
    required this.dayIndex,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.type,
    this.bookingRef,
    this.notes,
  });

  ItineraryStop copyWith({
    String? id,
    int? dayIndex,
    String? time,
    String? title,
    String? subtitle,
    String? type,
    String? bookingRef,
    String? notes,
  }) {
    return ItineraryStop(
      id: id ?? this.id,
      dayIndex: dayIndex ?? this.dayIndex,
      time: time ?? this.time,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      bookingRef: bookingRef ?? this.bookingRef,
      notes: notes ?? this.notes,
    );
  }

}
