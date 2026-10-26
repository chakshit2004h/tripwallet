import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
class MembersListScreen extends ConsumerWidget {
  final String tripId;
  const MembersListScreen({super.key,required this.tripId});
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final data=ref.watch(ledgerProvider).asData?.value;
    final trip=data?.trips.where((t)=>t.id==tripId).firstOrNull;
    final members=data?.members.where((m)=>m.tripId==tripId).toList()??[];
    return Scaffold(appBar:AppBar(title:const Text('Your crew')),body:ContentWidth(child:ListView(padding:const EdgeInsets.all(24),children:[
      Text('${members.length} travelers',style:AppTypography.titleLarge),const SizedBox(height:20),
      ...members.map((m)=>Card(child:ListTile(leading:CircleAvatar(child:Text(m.displayName.characters.first)),title:Text(m.displayName),
        subtitle:Text(m.role=='creator'?'Trip creator':'Member'),trailing:Icon(m.paymentVpa?.isNotEmpty==true?Icons.account_balance_wallet_outlined:Icons.person_outline)))),
      const SizedBox(height:24),if(trip!=null&&trip.status=='active')ElevatedButton.icon(onPressed:()=>context.push('/invite?tripId=$tripId&inviteCode=${trip.inviteCode}'),icon:const Icon(Icons.person_add_alt),label:const Text('Invite friends')),
    ])));
  }
}
