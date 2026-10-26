import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:tripwallet_client/core/auth/supabase_auth_service.dart';
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/db/database_provider.dart';
import 'package:tripwallet_client/core/theme/app_theme.dart';
import 'package:tripwallet_client/features/dashboard/presentation/main_dashboard_screen.dart';
import 'package:tripwallet_client/features/trip_dashboard/presentation/trip_dashboard_screen.dart';
import 'package:tripwallet_client/features/expenses/presentation/manual_expense_screen.dart';
import 'package:tripwallet_client/features/alerts/presentation/alerts_screen.dart';

void main() {
 testWidgets('export store screenshots', (tester) async {
  tester.view.physicalSize = const Size(540, 960);
  tester.view.devicePixelRatio = 1;
  for (final f in ['Inter','SpaceGrotesk','MaterialIcons']) {
   await (FontLoader(f)..addFont(rootBundle.load(f == 'MaterialIcons' ? 'fonts/MaterialIcons-Regular.otf' : 'assets/fonts/$f.ttf'))).load();
  }
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final repo = TripRepository(db: db, userId: 'p1');
  final date = DateTime(2026,10,12,12);
  final trips = [for(final pair in [('goa','Goa with the crew'),('hills','A weekend in Manali')])
   LocalTrip(id:pair.$1,inviteCode:'SAMPLE',createdBy:'p1',name:pair.$2,baseCurrency:'INR',status:'active',updatedAt:date)];
  final members = [for (final t in trips) for(final p in [('p1','Aarav'),('p2','Meera'),('p3','Kabir')])
   LocalMember(id:'${t.id}-${p.$1}',tripId:t.id,userId:p.$1,displayName:p.$2,role:'member')];
  final expenses = [for(final e in [('e1','goa','Dinner by the beach',240000,'p2'),('e2','goa','Our seaside stay',900000,'p2'),('e3','goa','Airport taxi',120000,'p1'),('e4','hills','Mountain café',180000,'p3')])
   LocalExpense(id:e.$1,tripId:e.$2,title:e.$3,amountMinor:e.$4,currency:'INR',paidByMemberId:'${e.$2}-${e.$5}',createdBy:e.$5,category:'other',splitMethod:'equal',taxMinor:0,serviceChargeMinor:0,createdAt:date)];
  final splits = [for(final e in expenses) for(final p in ['p1','p2','p3']) LocalExpenseSplit(expenseId:e.id,memberId:'${e.tripId}-$p',amountMinor:e.amountMinor~/3)];
  final data = LedgerData(trips,members,expenses,splits,[],[],[]);
  final cases = [
   ('01-trips','Less tracking.\nMore travelling.','All your group trips, together.',const MainDashboardScreen()),
   ('02-expenses','Every expense.\nOne shared view.','Keep the whole crew in the loop.',const TripDashboardScreen(tripId:'goa')),
   ('03-splits','Your share,\nsorted.','Split equally or enter exact shares.',const ManualExpenseScreen(tripId:'goa')),
   ('04-balances','Know who\nowes whom.','Clear balances for every trip.',const TripDashboardScreen(tripId:'goa')),
   ('05-activity','Every trip has\nits own story.','See your activity organised by trip.',const AlertsScreen()),
  ];
  for(final c in cases) {
   final key = GlobalKey();
   await tester.pumpWidget(ProviderScope(key:ValueKey(c.$1),overrides:[
    ledgerProvider.overrideWith((_)=>Stream.value(data)),
    tripRepositoryProvider.overrideWithValue(repo),
    accountIdProvider.overrideWithValue('p1'),
    supabaseClientProvider.overrideWithValue(null),
   ],child:MaterialApp(debugShowCheckedModeBanner:false,theme:AppTheme.lightTheme,
    home:RepaintBoundary(key:key,child:Scaffold(backgroundColor:const Color(0xff123d38),body:Stack(children:[
     Positioned(right:-140,top:110,child:Container(width:370,height:370,decoration:const BoxDecoration(shape:BoxShape.circle,color:Color(0xff20564e)))),
     const Positioned(left:36,top:28,child:Text('TRIPWALLET',style:TextStyle(fontFamily:'SpaceGrotesk',fontSize:15,fontWeight:FontWeight.w700,letterSpacing:3,color:Color(0xffd2ef8b)))),
     Positioned(left:36,top:65,right:28,child:Text(c.$2,style:const TextStyle(fontFamily:'SpaceGrotesk',fontSize:43,height:1.03,fontWeight:FontWeight.w700,letterSpacing:-1.5,color:Colors.white))),
     Positioned(left:36,top:165,child:Text(c.$3,style:const TextStyle(fontFamily:'Inter',fontSize:16,color:Color(0xffd6e4dc)))),
     Positioned(left:48,top:215,width:444,height:717,child:Container(padding:const EdgeInsets.all(7),decoration:BoxDecoration(color:const Color(0xff092823),borderRadius:BorderRadius.circular(30),border:Border.all(color:const Color(0xff528274)),boxShadow:const[BoxShadow(color:Color(0x55000000),blurRadius:22,offset:Offset(0,10))]),child:ClipRRect(borderRadius:BorderRadius.circular(23),child:FittedBox(fit:BoxFit.contain,child:SizedBox(width:390,height:640,child:MediaQuery(data:const MediaQueryData(size:Size(390,640)),child:Navigator(onGenerateRoute:(_)=>MaterialPageRoute(builder:(_)=>c.$4)))))))),
    ]))))));
   await tester.pumpAndSettle();
   if(c.$1=='04-balances') {await tester.tap(find.text('Balances'));await tester.pumpAndSettle();}
   if(c.$1=='03-splits') {
    await tester.enterText(find.byType(TextField).first,'Dinner by the beach');
    await tester.enterText(find.byKey(const ValueKey('expense-amount')),'2400');
    await tester.ensureVisible(find.text('Exact'));await tester.tap(find.text('Exact'));await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('share-goa-p1')));
    await tester.enterText(find.byKey(const ValueKey('share-goa-p1')),'1000');
    FocusManager.instance.primaryFocus?.unfocus();await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first,const Offset(0,-160));await tester.pumpAndSettle();
   }
   expect(tester.takeException(),isNull);
   final boundary=key.currentContext!.findRenderObject() as RenderRepaintBoundary;
   await tester.runAsync(() async {
    final image=await boundary.toImage(pixelRatio:2);
    final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
    await File('store-listing/screenshots/${c.$1}.png').writeAsBytes(bytes!.buffer.asUint8List());image.dispose();
   });
  }
  await tester.pumpWidget(const SizedBox());await tester.pumpAndSettle();await db.close();
 });
}
