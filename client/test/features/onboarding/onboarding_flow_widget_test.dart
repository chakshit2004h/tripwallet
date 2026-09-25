import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/features/onboarding/presentation/welcome_screen.dart';
import 'package:tripwallet_client/features/onboarding/presentation/create_trip_screen.dart';
import 'package:tripwallet_client/features/onboarding/presentation/invite_share_screen.dart';
import 'package:tripwallet_client/features/onboarding/presentation/join_trip_screen.dart';

void main() {
  group('Onboarding & Identity Widget Tests', () {
    testWidgets('WelcomeScreen renders value propositions and Get Started button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.textContaining('Scan the bill'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Claim'), findsOneWidget);
      expect(find.text('Settle'), findsOneWidget);
    });

    testWidgets('CreateTripScreen renders input fields and currency options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateTripScreen(),
        ),
      );

      expect(find.text('New Trip'), findsOneWidget);
      expect(find.text('Goa Weekend 2026'), findsOneWidget);
      expect(find.text('12 Oct – 16 Oct'), findsOneWidget);
      expect(find.text('INR (₹)'), findsOneWidget);
      expect(find.text('USD (\$)'), findsOneWidget);
      expect(find.text('Create Trip & Invite Crew'), findsOneWidget);
    });

    testWidgets('InviteShareScreen renders QR matrix, code and WhatsApp CTA', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InviteShareScreen(inviteCode: 'GOA-8X92'),
        ),
      );

      expect(find.text('Invite your crew'), findsOneWidget);
      expect(find.text('GOA-8X92'), findsOneWidget);
      expect(find.textContaining('tripwallet.app/j/GOA-8X92'), findsOneWidget);
      expect(find.text('Share to WhatsApp'), findsOneWidget);
      expect(find.text('Open Trip Dashboard →'), findsOneWidget);
    });

    testWidgets('JoinTripScreen renders name field, emoji avatars and join action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: JoinTripScreen(),
        ),
      );

      expect(find.text("Pick your guest identity"), findsOneWidget);
      expect(find.text('Chakshit'), findsWidgets);
      expect(find.text('Enter Trip Dashboard'), findsOneWidget);

      // Tap different emoji
      await tester.tap(find.text('🍕'));
      await tester.pump();

      // Enter custom name
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.pump();
      expect(find.text('Alex'), findsWidgets);
    });
  });
}
