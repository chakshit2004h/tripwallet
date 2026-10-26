import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/features/trip_dashboard/presentation/trip_summary_sheet.dart';
void main(){
  testWidgets('summary reflects actual expense categories and total',(tester)async{
    final db=AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.localTrips).insert(LocalTripsCompanion.insert(id:'trip',inviteCode:'CODE',name:'Seaside'));
    await db.into(db.localExpenses).insert(LocalExpensesCompanion.insert(id:'exp',tripId:'trip',title:'Lunch',amountMinor:120050,currency:'INR',paidByMemberId:'m1'));
    final repo=TripRepository(db:db,userId:'user');
    await tester.pumpWidget(ProviderScope(overrides:[tripRepositoryProvider.overrideWithValue(repo)],child:const MaterialApp(home:Scaffold(body:TripSummarySheet(tripId:'trip')))));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('₹1200.50'),findsNWidgets(2));
    expect(find.text('Other'),findsOneWidget);
    expect(find.text('Export expenses & shares (CSV)'),findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
