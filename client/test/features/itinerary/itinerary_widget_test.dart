import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/features/itinerary/presentation/itinerary_tab_view.dart';
import 'package:tripwallet_client/features/itinerary/presentation/add_stop_sheet.dart';
import 'package:tripwallet_client/features/itinerary/domain/itinerary_models.dart';

void main() {
  group('Itinerary Feature Widget Tests', () {
    testWidgets('ItineraryTabView displays day pills and default Goa stops', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItineraryTabView(tripId: 'demo-trip'),
          ),
        ),
      );

      // Verify Day pills
      expect(find.text('Day 1 · Oct 12'), findsOneWidget);
      expect(find.text('Day 2 · Oct 13'), findsOneWidget);
      expect(find.text('Day 3 · Oct 14'), findsOneWidget);

      // Verify Day 1 stops
      expect(find.text('IndiGo 6E-241'), findsOneWidget);
      expect(find.text('W Goa Check-in'), findsOneWidget);
      expect(find.text('Thalassa Sunset Dinner'), findsOneWidget);
      expect(find.text('REF: 6E-J9K2L'), findsOneWidget);
    });

    testWidgets('ItineraryTabView switches days and displays corresponding stops', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItineraryTabView(tripId: 'demo-trip'),
          ),
        ),
      );

      // Switch to Day 2
      await tester.tap(find.text('Day 2 · Oct 13'));
      await tester.pumpAndSettle();

      expect(find.text('Baga Water Sports'), findsOneWidget);
      expect(find.text('Blue Tokai Cafe'), findsOneWidget);
      expect(find.text("Leo's Pizzeria"), findsOneWidget);

      // Switch to Day 3
      await tester.tap(find.text('Day 3 · Oct 14'));
      await tester.pumpAndSettle();

      expect(find.text('Anjuna Flea Market'), findsOneWidget);
      expect(find.text('Curlies Beach Shack'), findsOneWidget);
      expect(find.text('Return Flight to Delhi'), findsOneWidget);
    });

    testWidgets('AddStopSheet inputs stop details and invokes onAdd callback', (tester) async {
      ItineraryStop? addedStop;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AddStopSheet.show(
                  context,
                  initialDayIndex: 1,
                  onAdd: (stop) => addedStop = stop,
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Add Itinerary Stop'), findsOneWidget);
      expect(find.text('Add Stop to Schedule'), findsOneWidget);

      // Enter title
      await tester.enterText(find.byType(TextField).first, 'Sunset Cruise');
      await tester.pump();

      // Submit
      await tester.tap(find.text('Add Stop to Schedule'));
      await tester.pumpAndSettle();

      expect(addedStop, isNotNull);
      expect(addedStop!.title, equals('Sunset Cruise'));
      expect(addedStop!.dayIndex, equals(1));
    });
  });
}
