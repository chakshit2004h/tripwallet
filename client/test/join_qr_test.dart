import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tripwallet_client/core/auth/supabase_auth_service.dart';
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/features/onboarding/domain/invite_code.dart';
import 'package:tripwallet_client/features/onboarding/presentation/join_trip_screen.dart';
import 'package:tripwallet_client/features/trips/data/supabase_trips_service.dart';

class FakeCamera extends MobileScannerPlatform {
  bool denied = false;
  int stops = 0;
  int starts = 0;
  int disposals = 0;
  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();
  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();
  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();
  @override
  Widget buildCameraView() => const ColoredBox(color: Colors.black);
  @override
  Future<MobileScannerViewAttributes> start(StartOptions options) async {
    starts++;
    if (denied) {
      throw const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      );
    }
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(640, 480),
    );
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

class FakeTrips extends SupabaseTripsService {
  FakeTrips() : super(auth: SupabaseAuthService());
  int previews = 0;
  int joins = 0;
  bool fail = false;
  String? lastCode;
  final trip = SupabaseTrip(
    id: 'trip',
    name: 'Beach crew',
    inviteCode: 'ABC12345',
    baseCurrency: 'INR',
    status: 'active',
    createdBy: 'owner',
  );
  @override
  Future<SupabaseTrip?> fetchTripByInviteCode(String code) async {
    previews++;
    return trip;
  }

  @override
  Future<SupabaseTrip> joinTripByInviteCode(String code) async {
    joins++;
    lastCode = code;
    if (fail) {
      throw const FormatException('This invite is no longer available.');
    }
    return trip;
  }
}

class FakeSync extends TripRepository {
  FakeSync(AppDatabase db) : super(db: db, userId: 'user');
  @override
  Future<void> sync() async {}
}

void main() {
  late FakeCamera camera;
  late MobileScannerPlatform previous;
  setUp(() {
    previous = MobileScannerPlatform.instance;
    camera = FakeCamera();
    MobileScannerPlatform.instance = camera;
  });
  tearDown(() => MobileScannerPlatform.instance = previous);

  test('QR parser accepts TripWallet invites and rejects unrelated URLs', () {
    expect(
      inviteCodeFromInput('tripwallet://join?code=abc12345', scanned: true),
      'ABC12345',
    );
    expect(inviteCodeFromInput(' ABC123 ', scanned: true), 'ABC123');
    expect(
      inviteCodeFromInput(
        'https://other.example/?code=ABC12345',
        scanned: true,
      ),
      isNull,
    );
    expect(
      inviteCodeFromInput(
        'tripwallet://auth-callback?code=ABC12345',
        scanned: true,
      ),
      isNull,
    );
    expect(
      inviteCodeFromInput('tripwallet://join?code=bad%ZZ', scanned: true),
      isNull,
    );
    expect(inviteCodeFromInput('too-long-code', scanned: true), isNull);
  });

  Future<void> mount(WidgetTester tester, FakeTrips service) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final router = GoRouter(
      initialLocation: '/join',
      routes: [
        GoRoute(path: '/join', builder: (_, __) => const JoinTripScreen()),
        GoRoute(
          path: '/trip/:id',
          builder: (_, __) => const Scaffold(body: Text('Joined trip')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseTripsServiceProvider.overrideWithValue(service),
          tripRepositoryProvider.overrideWithValue(FakeSync(db)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  void detect(WidgetTester tester, String value, {bool twice = false}) {
    final callback = tester
        .widget<MobileScanner>(find.byType(MobileScanner))
        .onDetect!;
    final capture = BarcodeCapture(
      barcodes: [Barcode(format: BarcodeFormat.qrCode, rawValue: value)],
    );
    callback(capture);
    if (twice) callback(capture);
  }

  testWidgets(
    'valid scan joins once and closes the camera; invalid QR stays open',
    (tester) async {
      final service = FakeTrips();
      await mount(tester, service);
      await tester.tap(find.text('Scan QR code'));
      await tester.pumpAndSettle();
      expect(camera.starts, greaterThan(0));
      detect(tester, 'https://unrelated.example');
      await tester.pump();
      expect(
        find.textContaining('This isn’t a TripWallet invite'),
        findsOneWidget,
      );
      expect(service.joins, 0);
      detect(tester, 'tripwallet://join?code=abc12345', twice: true);
      await tester.pumpAndSettle();
      expect(service.joins, 1);
      expect(service.lastCode, 'ABC12345');
      expect(find.text('Joined trip'), findsOneWidget);
      await tester.pump();
      expect(find.byType(MobileScanner), findsNothing);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(camera.stops + camera.disposals, greaterThan(0));
    },
  );

  testWidgets(
    'camera cancellation keeps manual code entry and preview working',
    (tester) async {
      final service = FakeTrips();
      await mount(tester, service);
      await tester.enterText(find.byType(TextField), 'ABC12345');
      await tester.tap(find.text('Scan QR code'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enter code instead'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'ABC12345',
      );
      expect(service.joins, 0);
      await tester.tap(find.text('Find trip'));
      await tester.pumpAndSettle();
      expect(service.previews, 1);
      expect(service.joins, 0);
      await tester.tap(find.text('Join Beach crew'));
      await tester.pumpAndSettle();
      expect(service.joins, 1);
    },
  );

  testWidgets('denied camera access explains how to use manual entry', (
    tester,
  ) async {
    camera.denied = true;
    await mount(tester, FakeTrips());
    await tester.tap(find.text('Scan QR code'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Camera access is off'), findsOneWidget);
    await tester.tap(find.text('Enter code instead'));
    await tester.pumpAndSettle();
    expect(find.text('Find trip'), findsOneWidget);
  });

  testWidgets(
    'failed scanned invite keeps the code and displays the server error',
    (tester) async {
      final service = FakeTrips()..fail = true;
      await mount(tester, service);
      await tester.tap(find.text('Scan QR code'));
      await tester.pumpAndSettle();
      detect(tester, 'tripwallet://join?code=ABC12345');
      await tester.pumpAndSettle();
      expect(find.text('This invite is no longer available.'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'ABC12345',
      );
      expect(find.text('Joined trip'), findsNothing);
    },
  );
}
