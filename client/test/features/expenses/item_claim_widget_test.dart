import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_models.dart';
import 'package:tripwallet_client/features/expenses/presentation/item_claim_screen.dart';

void main() {
  testWidgets('all receipt items must be claimed before review', (tester) async {
    final receipt=ReceiptData(tripId:'trip',title:'Cafe',payerMemberId:'alice',items:[
      ReceiptItem(label:'Coffee',priceMinor:30000),ReceiptItem(label:'Sandwich',priceMinor:50000)]);
    const members=[MemberProfile(id:'alice',name:'Alice',initial:'A',color:Colors.orange),
      MemberProfile(id:'bob',name:'Bob',initial:'B',color:Colors.green)];
    await tester.pumpWidget(MaterialApp(home:ItemClaimScreen(receipt:receipt,members:members)));
    expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton,'Review split')).onPressed,isNull);
    await tester.tap(find.text('Select everyone for all items'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton,'Review split')).onPressed,isNotNull);
    final shares=receiptAllocations(receipt,'alice',members);
    expect(shares['alice']!.totalMinor+shares['bob']!.totalMinor,receipt.totalMinor);
  });
}
