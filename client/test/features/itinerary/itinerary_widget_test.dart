import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/db/database_provider.dart';
import 'package:tripwallet_client/features/itinerary/presentation/itinerary_tab_view.dart';
import 'package:tripwallet_client/features/itinerary/presentation/add_stop_sheet.dart';
import 'package:tripwallet_client/features/itinerary/domain/itinerary_models.dart';

void main() {
  group('Itinerary Feature Widget Tests', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      // Insert Day 1 and Day 2 stops
      await database.into(database.localItineraryStops).insert(
        LocalItineraryStopsCompanion.insert(
          id: 'stop_1',
          tripId: 'demo-trip',
          dayIndex: 0,
          time: '06:15',
          title: 'IndiGo 6E-241',
          subtitle: '06:15 BOM → 07:30 GOI',
          type: 'flight',
        ),
      );
      await database.into(database.localItineraryStops).insert(
        LocalItineraryStopsCompanion.insert(
          id: 'stop_2',
          tripId: 'demo-trip',
          dayIndex: 1,
          time: '14:00',
          title: 'Baga Water Sports',
          subtitle: 'Jet ski & parasailing',
          type: 'activity',
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('ItineraryTabView displays day pills and default stops', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ItineraryTabView(tripId: 'demo-trip'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Day pills
      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Day 2'), findsOneWidget);
      expect(find.text('Day 3'), findsOneWidget);

      // Verify Day 1 stops
      expect(find.text('IndiGo 6E-241'), findsOneWidget);
      expect(find.textContaining('06:15 BOM → 07:30 GOI'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('ItineraryTabView switches days and displays corresponding stops', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ItineraryTabView(tripId: 'demo-trip'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Day 2
      await tester.tap(find.text('Day 2'));
      await tester.pumpAndSettle();

      expect(find.text('Baga Water Sports'), findsOneWidget);
      expect(find.textContaining('Jet ski & parasailing'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
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
