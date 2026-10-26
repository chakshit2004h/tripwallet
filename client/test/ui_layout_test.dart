import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/db/database_provider.dart';
import 'package:tripwallet_client/core/theme/app_theme.dart';
import 'package:tripwallet_client/features/onboarding/presentation/splash_screen.dart';
import 'package:tripwallet_client/features/dashboard/presentation/main_dashboard_screen.dart';
import 'package:tripwallet_client/features/trip_dashboard/presentation/trip_dashboard_screen.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final name in ['Inter', 'SpaceGrotesk']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  for (final width in [360.0, 390.0]) {
    testWidgets('welcome actions remain reachable at $width', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const SplashScreen()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (width == 390) await preview(tester, 'welcome');
      await tester.scrollUntilVisible(
        find.text('Already a member? Sign in'),
        200,
      );
      expect(find.text('Get started'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final scale in [1.0, 1.5]) {
    testWidgets(
      'trip navigation and expense summary fit with text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await db
            .into(db.localTrips)
            .insert(
              LocalTripsCompanion.insert(
                id: 'trip',
                inviteCode: 'CODE',
                name: 'A weekend in the hills',
              ),
            );
        await db
            .into(db.localExpenses)
            .insert(
              LocalExpensesCompanion.insert(
                id: 'exp',
                tripId: 'trip',
                title: 'Dinner with the crew',
                amountMinor: 240000,
                currency: 'INR',
                paidByMemberId: 'm1',
              ),
            );
        addTearDown(db.close);
        await db
            .into(db.localMembers)
            .insert(
              LocalMembersCompanion.insert(
                id: 'm1',
                userId: const Value(''),
                tripId: 'trip',
                displayName: 'Alex',
              ),
            );
        await db
            .into(db.localMembers)
            .insert(
              LocalMembersCompanion.insert(
                id: 'm2',
                userId: const Value('friend'),
                tripId: 'trip',
                displayName: 'Sam',
              ),
            );
        await db
            .into(db.localExpenseSplits)
            .insert(
              LocalExpenseSplitsCompanion.insert(
                expenseId: 'exp',
                memberId: 'm1',
                amountMinor: 120000,
              ),
            );
        await db
            .into(db.localExpenseSplits)
            .insert(
              LocalExpenseSplitsCompanion.insert(
                expenseId: 'exp',
                memberId: 'm2',
                amountMinor: 120000,
              ),
            );
        final repo = TripRepository(db: db, userId: '');
        Widget app(Widget screen) => ProviderScope(
          overrides: [
            tripRepositoryProvider.overrideWithValue(repo),
            accountIdProvider.overrideWithValue(''),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: screen,
          ),
        );
        await tester.pumpWidget(app(const MainDashboardScreen()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('New trip'), findsOneWidget);
        if (scale == 1) await preview(tester, 'trips');
        await tester.tap(find.text('Past trips'));
        await tester.pumpAndSettle();
        expect(find.text('No past trips yet'), findsOneWidget);
        await tester.pumpWidget(app(const TripDashboardScreen(tripId: 'trip')));
        await tester.pumpAndSettle();
        expect(find.text('Group spending'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (scale == 1) await preview(tester, 'expenses');
        await tester.tap(find.text('Balances'));
        await tester.pumpAndSettle();
        expect(find.text('Who owes whom'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  }
}

Future<void> preview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('UI_PREVIEWS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).first,
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/ui-previews').create(recursive: true);
    await File(
      'build/ui-previews/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
