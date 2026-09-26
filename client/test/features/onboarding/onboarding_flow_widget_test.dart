import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/db/database_provider.dart';
import 'package:drift/native.dart';
import 'package:tripwallet_client/features/onboarding/presentation/welcome_screen.dart';
import 'package:tripwallet_client/features/onboarding/presentation/create_trip_screen.dart';
import 'package:tripwallet_client/features/onboarding/presentation/invite_share_screen.dart';
import 'package:tripwallet_client/features/onboarding/presentation/join_trip_screen.dart';

void main() {
  group('Onboarding & Identity Widget Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('WelcomeScreen renders value propositions and Get Started button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.textContaining('Scan the bill'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.textContaining('Split trip expenses by line item'), findsOneWidget);
    });

    testWidgets('CreateTripScreen renders input fields and currency options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: CreateTripScreen(),
          ),
        ),
      );

      expect(find.text('New trip'), findsOneWidget);
      expect(find.text('INR  ₹'), findsOneWidget);
      expect(find.text('Create trip'), findsOneWidget);
    });

    testWidgets('InviteShareScreen renders QR matrix, code and WhatsApp CTA', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InviteShareScreen(inviteCode: 'GOA-8X92'),
        ),
      );

      expect(find.text('Invite your crew'), findsOneWidget);
      expect(find.textContaining('tripwallet.app/j/GOA-8X92'), findsOneWidget);
      expect(find.text('Share to WhatsApp'), findsOneWidget);
      expect(find.text('Open trip dashboard'), findsOneWidget);
    });

    testWidgets('JoinTripScreen renders name field, avatars and join action', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: JoinTripScreen(),
          ),
        ),
      );

      expect(find.text("Goa weekend"), findsOneWidget);
      expect(find.text('Your name'), findsOneWidget);
      expect(find.text('Pick an avatar'), findsOneWidget);
      expect(find.text('CH'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Join trip'), findsOneWidget);

      // Enter custom name
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.pump();
      expect(find.text('Alex'), findsOneWidget);
    });
  });
}

