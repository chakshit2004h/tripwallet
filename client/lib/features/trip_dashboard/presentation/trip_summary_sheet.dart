import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/data/export_ledger.dart';
import '../../../core/domain/money.dart';
import '../../../core/theme/app_typography.dart';
class TripSummarySheet extends ConsumerWidget {
  final String tripId;
  const TripSummarySheet({super.key,required this.tripId});
  static Future<void> show(BuildContext context,{required String tripId})=>showModalBottomSheet(context:context,isScrollControlled:true,useSafeArea:true,builder:(_)=>TripSummarySheet(tripId:tripId));
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final data=ref.watch(ledgerProvider).asData?.value;
    final trip=data?.trips.where((t)=>t.id==tripId).firstOrNull;
    if(trip==null)return const Padding(padding:EdgeInsets.all(24),child:Text('Load your trip to see its summary.'));
    final totals=<String,int>{};
    for(final e in data!.expenses.where((e)=>e.tripId==tripId)){totals[e.category]=(totals[e.category]??0)+e.amountMinor;}
    final total=totals.values.fold(0,(a,b)=>a+b);
    return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Trip summary',style:AppTypography.titleLarge),const SizedBox(height:8),Text(trip.name,style:AppTypography.bodyLarge),const SizedBox(height:20),
      Text(formatMoney(total,trip.baseCurrency),style:AppTypography.display),const Text('Total shared expenses'),const SizedBox(height:24),
      if(totals.isEmpty)const Text('No expenses yet.'),
      ...totals.entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:18),child:Column(children:[
        Row(children:[Expanded(child:Text(e.key[0].toUpperCase()+e.key.substring(1))),Text(formatMoney(e.value,trip.baseCurrency))]),
        const SizedBox(height:8),LinearProgressIndicator(value:total==0?0:e.value/total,minHeight:6,borderRadius:BorderRadius.circular(4)),
      ]))),
      const SizedBox(height:16),OutlinedButton.icon(onPressed:()async{try{await shareLedger(data,tripId:tripId);}catch(_){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Could not share the export. Please try again.')));}},
        icon:const Icon(Icons.ios_share),label:const Text('Export expenses & shares (CSV)')),
    ]));
  }
}
