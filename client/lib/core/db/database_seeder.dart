import 'package:drift/drift.dart' as drift;
import 'app_database.dart';

class DatabaseSeeder {
  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existingTrips = await db.select(db.localTrips).get();
    if (existingTrips.isNotEmpty) return;

    // 1. Seed Trips matching prototype Step 22 (Your trips)
    await db.into(db.localTrips).insert(
          LocalTripsCompanion.insert(
            id: 'demo-trip',
            name: 'Goa weekend',
            inviteCode: '9f2k4',
            startDate: drift.Value(DateTime(2026, 9, 12)),
            endDate: drift.Value(DateTime(2026, 9, 14)),
            baseCurrency: const drift.Value('INR'),
            status: const drift.Value('active'),
          ),
        );

    await db.into(db.localTrips).insert(
          LocalTripsCompanion.insert(
            id: 'trip-manali',
            name: 'Manali trek',
            inviteCode: 'MNL-7X2',
            startDate: drift.Value(DateTime(2026, 10, 2)),
            endDate: drift.Value(DateTime(2026, 10, 7)),
            baseCurrency: const drift.Value('INR'),
            status: const drift.Value('active'),
          ),
        );

    await db.into(db.localTrips).insert(
          LocalTripsCompanion.insert(
            id: 'trip-jaipur',
            name: 'Jaipur trip',
            inviteCode: 'JPR-4K9',
            startDate: drift.Value(DateTime(2026, 8, 1)),
            endDate: drift.Value(DateTime(2026, 8, 5)),
            baseCurrency: const drift.Value('INR'),
            status: const drift.Value('archived'),
          ),
        );

    // 2. Seed Members for 'demo-trip' (Goa weekend) matching Step 27
    await db.into(db.localMembers).insert(
          LocalMembersCompanion.insert(
            id: 'm_aisha',
            tripId: 'demo-trip',
            displayName: 'Aisha',
            role: const drift.Value('creator'),
            avatarUrl: const drift.Value('AI'),
            paymentVpa: const drift.Value('aisha@okhdfcbank'),
          ),
        );

    await db.into(db.localMembers).insert(
          LocalMembersCompanion.insert(
            id: 'm_rohan',
            tripId: 'demo-trip',
            displayName: 'Rohan',
            role: const drift.Value('member'),
            avatarUrl: const drift.Value('RO'),
            paymentVpa: const drift.Value('rohan@paytm'),
          ),
        );

    await db.into(db.localMembers).insert(
          LocalMembersCompanion.insert(
            id: 'm_chirag',
            tripId: 'demo-trip',
            displayName: 'Chirag',
            role: const drift.Value('member'),
            avatarUrl: const drift.Value('CH'),
            paymentVpa: const drift.Value('chirag@axis'),
          ),
        );

    await db.into(db.localMembers).insert(
          LocalMembersCompanion.insert(
            id: 'm_you',
            tripId: 'demo-trip',
            displayName: 'You',
            role: const drift.Value('organizer'),
            avatarUrl: const drift.Value('YO'),
            paymentVpa: const drift.Value('you@okhdfcbank'),
          ),
        );

    // 3. Seed Expenses for 'demo-trip' matching Steps 7 & 12
    await db.into(db.localExpenses).insert(
          LocalExpensesCompanion.insert(
            id: 'exp-1',
            tripId: 'demo-trip',
            title: 'Beach shack dinner',
            amountMinor: 480000, // ₹4,800
            currency: 'INR',
            paidByMemberId: 'm_aisha',
            splitMethod: const drift.Value('itemized'),
            taxMinor: const drift.Value(40000),
            serviceChargeMinor: const drift.Value(21000),
          ),
        );

    await db.into(db.localExpenses).insert(
          LocalExpensesCompanion.insert(
            id: 'exp-2',
            tripId: 'demo-trip',
            title: 'Airport cab',
            amountMinor: 110000, // ₹1,100
            currency: 'INR',
            paidByMemberId: 'm_rohan',
            splitMethod: const drift.Value('equal'),
          ),
        );

    await db.into(db.localExpenses).insert(
          LocalExpensesCompanion.insert(
            id: 'exp-3',
            tripId: 'demo-trip',
            title: 'Scooter rental',
            amountMinor: 120000, // ₹1,200
            currency: 'INR',
            paidByMemberId: 'm_you',
            splitMethod: const drift.Value('equal'),
          ),
        );

    // 4. Seed Itinerary Stops matching Step 17
    await db.into(db.localItineraryStops).insert(
          LocalItineraryStopsCompanion.insert(
            id: 'stop-1',
            tripId: 'demo-trip',
            dayIndex: 0,
            time: '9:40 AM',
            title: 'Flight to Goa',
            subtitle: 'Indigo 6E-204 · Terminal 3',
            type: 'flight',
            bookingRef: const drift.Value('6E-204'),
          ),
        );

    await db.into(db.localItineraryStops).insert(
          LocalItineraryStopsCompanion.insert(
            id: 'stop-2',
            tripId: 'demo-trip',
            dayIndex: 0,
            time: '1:00 PM',
            title: 'Check-in — Seaview Resort',
            subtitle: 'Vagator Beach · 2 rooms booked',
            type: 'hotel',
            bookingRef: const drift.Value('SV-892'),
          ),
        );

    // 5. Seed Alerts matching Step 23
    await db.into(db.localAlerts).insert(
          LocalAlertsCompanion.insert(
            id: 'alert-1',
            tripId: 'demo-trip',
            title: 'Chirag settled ₹1,450 with you',
            timeAgo: '10 min ago',
            iconType: 'wallet',
            isCoral: const drift.Value(true),
          ),
        );

    await db.into(db.localAlerts).insert(
          LocalAlertsCompanion.insert(
            id: 'alert-2',
            tripId: 'demo-trip',
            title: 'Aisha added "Beach shack dinner" · ₹4,800',
            timeAgo: '2 hours ago',
            iconType: 'receipt',
          ),
        );

    await db.into(db.localAlerts).insert(
          LocalAlertsCompanion.insert(
            id: 'alert-3',
            tripId: 'demo-trip',
            title: 'Rohan joined Manali trek',
            timeAgo: 'Yesterday',
            iconType: 'user',
          ),
        );
  }
}
