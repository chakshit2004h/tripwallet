import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/features/onboarding/presentation/invite_share_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
void main(){
  testWidgets('invite contains scannable code and sharing action',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:InviteShareScreen(tripId:'trip',inviteCode:'A1B2C3D4')));
    expect(find.byType(QrImageView),findsOneWidget);
    expect(find.text('A1B2C3D4'),findsOneWidget);
    await tester.scrollUntilVisible(find.text('Share invite'),300,scrollable:find.byType(Scrollable).first);
    expect(find.text('Share invite'),findsOneWidget);
  });
}
