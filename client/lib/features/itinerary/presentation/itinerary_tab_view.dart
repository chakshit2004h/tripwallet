import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/widgets/ledger_widgets.dart';
import 'add_stop_sheet.dart';
class ItineraryTabView extends ConsumerStatefulWidget {
  final String tripId;
  const ItineraryTabView({super.key,required this.tripId});
  @override
  ConsumerState<ItineraryTabView> createState()=>_ItineraryTabViewState();
}
class _ItineraryTabViewState extends ConsumerState<ItineraryTabView> {
  int _day=0;
  int _extraDays=0;
  @override
  Widget build(BuildContext context){
    final data=ref.watch(ledgerProvider).asData?.value;
    final trip=data?.trips.where((t)=>t.id==widget.tripId).firstOrNull;
    final stops=data?.stops.where((s)=>s.tripId==widget.tripId).toList()??[];
    final scheduled=trip?.startDate!=null&&trip?.endDate!=null?trip!.endDate!.difference(trip.startDate!).inDays+1:1;
    final days=max(scheduled,stops.fold(1,(int n,s)=>max(n,s.dayIndex+1)))+_extraDays;
    return Column(children:[
      SizedBox(height:64,child:ListView.separated(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:24),
        itemCount:days+1,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(context,i){
          if(i==days)return IconButton(tooltip:'Add another day',onPressed:days>=366?null:()=>setState(()=>_extraDays++),icon:const Icon(Icons.add));
          final date=trip?.startDate?.add(Duration(days:i));
          return Center(child:ChoiceChip(label:Text('Day ${i+1}${date==null?'':' · ${DateFormat('d MMM').format(date)}'}'),selected:i==_day,onSelected:(_)=>setState(()=>_day=i)));
        })),
      Expanded(child:ListView(padding:const EdgeInsets.all(24),children:[
        if(!stops.any((s)=>s.dayIndex==_day))EmptyState(icon:Icons.explore_outlined,title:'Leave room for adventure.',message:'No plans for day ${_day+1} yet. Add a flight, a meal, or somewhere you want to go.'),
        ...stops.where((s)=>s.dayIndex==_day).map((s)=>Card(child:ListTile(leading:const Icon(Icons.place_outlined),
          title:Text(s.title),subtitle:Text('${s.time}${s.subtitle.isEmpty?'':' · ${s.subtitle}'}${s.bookingRef?.isNotEmpty==true?'\nBooking: ${s.bookingRef}':''}')))),
      ])),
      if(trip?.status=='active')Padding(padding:const EdgeInsets.fromLTRB(24,8,24,16),child:OutlinedButton.icon(onPressed:()=>AddStopSheet.show(context,initialDayIndex:_day,onAdd:(s)=>
        ref.read(tripRepositoryProvider).addStop(tripId:widget.tripId,dayIndex:s.dayIndex,time:s.time,title:s.title,subtitle:s.subtitle,type:s.type,bookingRef:s.bookingRef)),
        icon:const Icon(Icons.add),label:Text('Add to day ${_day+1}'))),
    ]);
  }
}
