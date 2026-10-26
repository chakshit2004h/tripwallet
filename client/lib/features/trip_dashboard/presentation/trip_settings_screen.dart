import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/data/app_error.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../../trips/data/supabase_trips_service.dart';
class TripSettingsScreen extends ConsumerStatefulWidget {
  final String tripId;
  const TripSettingsScreen({super.key,required this.tripId});
  @override
  ConsumerState<TripSettingsScreen> createState()=>_TripSettingsScreenState();
}
class _TripSettingsScreenState extends ConsumerState<TripSettingsScreen> {
  bool _busy=false;
  String? _error;
  Future<void> _manage(String action)async{
    final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:Text('${action[0].toUpperCase()+action.substring(1)} trip?'),
      content:Text(action=='delete'?'All members will lose this trip, its expenses and plans. This cannot be undone.':'This changes the trip for everyone. Archived trips remain available to view.'),actions:[
        TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Continue'))]));
    if(yes!=true||!mounted)return;
    setState(()=>_busy=true);
    try{
      final repo=ref.read(tripRepositoryProvider);
      await repo.sync();
      if((await repo.read()).pending.any((q)=>q.tripId==widget.tripId))throw StateError('Sync pending changes before managing this trip.');
      await ref.read(supabaseTripsServiceProvider).manageTrip(widget.tripId,action);
      if(action=='delete'){await repo.removeTrip(widget.tripId);}else{await repo.sync();}
      if(mounted)context.go('/trips');
    }catch(e){if(mounted)setState(()=>_error=appError(e));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  @override
  Widget build(BuildContext context){
    final data=ref.watch(ledgerProvider).asData?.value;
    final trip=data?.trips.where((t)=>t.id==widget.tripId).firstOrNull;
    return Scaffold(appBar:AppBar(title:const Text('Trip settings')),body:ContentWidth(child:ListView(padding:const EdgeInsets.all(24),children:[
      if(trip!=null)...[Text(trip.name,style:AppTypography.display),const SizedBox(height:24),
        ListTile(title:const Text('Currency'),trailing:Text(trip.baseCurrency)),ListTile(title:const Text('Dates'),subtitle:Text(tripDates(trip))),
        ListTile(title:const Text('Status'),trailing:Text(trip.status)),
        ListTile(title:const Text('Members'),trailing:const Icon(Icons.chevron_right),onTap:()=>context.push('/trip/${trip.id}/members')),
        if(trip.createdBy==ref.watch(accountIdProvider))...[
          const SizedBox(height:32),OutlinedButton(onPressed:_busy?null:()=>_manage(trip.status=='active'?'archive':'restore'),child:Text(trip.status=='active'?'Archive trip':'Restore trip')),
          const SizedBox(height:12),TextButton(onPressed:_busy?null:()=>_manage('delete'),child:Text('Delete trip permanently',style:TextStyle(color:Theme.of(context).colorScheme.error))),
        ]else const Padding(padding:EdgeInsets.only(top:24),child:Text('Only the trip creator can archive or delete this trip.')),
      ],if(_error!=null)Text(_error!),if(_busy)const Center(child:CircularProgressIndicator()),
    ])));
  }
}
