import 'package:flutter/material.dart';
import '../../../core/widgets/ledger_widgets.dart';
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Privacy & your data')),body:const ContentWidth(child:SingleChildScrollView(padding:EdgeInsets.all(24),child:SelectableText(
    'Your TripWallet data\n\n'
    'Your email is used to sign in. Your name, optional UPI ID, trip details, expenses, shares, payments and itinerary are stored with Supabase and cached on this device. Trip members can see their shared trip records and each other’s names and payment addresses.\n\n'
    'Receipt photos are processed on your device using text recognition. TripWallet syncs the reviewed expense items, not the original photo. Camera and photo access are only used when you choose to scan a receipt.\n\n'
    'TripWallet opens an external UPI app to pay. It does not hold money, access your bank account, or verify payment success. Recorded payments are confirmed by the person reporting them.\n\n'
    'You can export expenses and shares from Profile or a trip summary. You can delete your account from Profile. Your sign-in and profile are removed, and shared financial records remain under “Deleted account” to preserve other members’ balances. Trips with no other members are deleted; ownership of shared trips moves to another member.\n\n'
    'Signing out keeps your account’s cached records on this device so you can finish syncing after signing back in. Clearing app storage removes that local copy, including changes not yet synced. Account deletion clears the active account’s local records.',
    style:TextStyle(fontSize:16,height:1.6)))));
}
