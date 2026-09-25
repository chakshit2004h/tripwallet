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

  static List<ItineraryStop> defaultGoaStops() {
    return const [
      // Day 1
      ItineraryStop(
        id: 'stop-1',
        dayIndex: 0,
        time: '10:30 AM',
        title: 'IndiGo 6E-241',
        subtitle: 'DEL ➔ GOI · Flight',
        type: 'flight',
        bookingRef: '6E-J9K2L',
      ),
      ItineraryStop(
        id: 'stop-2',
        dayIndex: 0,
        time: '02:00 PM',
        title: 'W Goa Check-in',
        subtitle: 'Vagator Beach · Hotel & Resort',
        type: 'hotel',
        bookingRef: 'WG-8842',
      ),
      ItineraryStop(
        id: 'stop-3',
        dayIndex: 0,
        time: '08:00 PM',
        title: 'Thalassa Sunset Dinner',
        subtitle: 'Small Vagator · Greek Tavern',
        type: 'food',
      ),

      // Day 2
      ItineraryStop(
        id: 'stop-4',
        dayIndex: 1,
        time: '11:00 AM',
        title: 'Baga Water Sports',
        subtitle: 'Parasailing & Jet Ski · Activity',
        type: 'activity',
      ),
      ItineraryStop(
        id: 'stop-5',
        dayIndex: 1,
        time: '04:00 PM',
        title: 'Blue Tokai Cafe',
        subtitle: 'Assagao · Specialty Coffee',
        type: 'food',
      ),
      ItineraryStop(
        id: 'stop-6',
        dayIndex: 1,
        time: '09:00 PM',
        title: "Leo's Pizzeria",
        subtitle: 'Panjim · Artisan Sourdough Pizza',
        type: 'food',
      ),

      // Day 3
      ItineraryStop(
        id: 'stop-7',
        dayIndex: 2,
        time: '12:00 PM',
        title: 'Anjuna Flea Market',
        subtitle: 'Souvenirs & Live Music · Activity',
        type: 'activity',
      ),
      ItineraryStop(
        id: 'stop-8',
        dayIndex: 2,
        time: '04:30 PM',
        title: 'Curlies Beach Shack',
        subtitle: 'Anjuna Beach · Sunset Cocktails',
        type: 'food',
      ),
      ItineraryStop(
        id: 'stop-9',
        dayIndex: 2,
        time: '07:30 PM',
        title: 'Return Flight to Delhi',
        subtitle: 'GOI ➔ DEL · Flight',
        type: 'flight',
        bookingRef: '6E-X4P1',
      ),
    ];
  }
}
