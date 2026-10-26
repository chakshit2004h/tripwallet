import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/data/app_error.dart';
import '../domain/itinerary_models.dart';
class AddStopSheet extends StatefulWidget {
  final int initialDayIndex;
  final FutureOr<void> Function(ItineraryStop) onAdd;
  const AddStopSheet({super.key,required this.initialDayIndex,required this.onAdd});
  static Future<void> show(BuildContext context,{required int initialDayIndex,required FutureOr<void> Function(ItineraryStop) onAdd})=>
    showModalBottomSheet(context:context,isScrollControlled:true,useSafeArea:true,builder:(_)=>AddStopSheet(initialDayIndex:initialDayIndex,onAdd:onAdd));
  @override
  State<AddStopSheet> createState()=>_AddStopSheetState();
}
class _AddStopSheetState extends State<AddStopSheet> {
  final _title=TextEditingController(),_location=TextEditingController(),_booking=TextEditingController();
  TimeOfDay _time=const TimeOfDay(hour:9,minute:0);
  String _type='activity';
  String? _error;
  bool _busy=false;
  @override
  void dispose(){_title.dispose();_location.dispose();_booking.dispose();super.dispose();}
  Future<void> _save()async{
    if(_title.text.trim().isEmpty){setState(()=>_error='Enter a stop title.');return;}
    setState(()=>_busy=true);
    try{await widget.onAdd(ItineraryStop(id:const Uuid().v4(),dayIndex:widget.initialDayIndex,
      time:'${_time.hour.toString().padLeft(2,'0')}:${_time.minute.toString().padLeft(2,'0')}',
      title:_title.text.trim(),subtitle:_location.text.trim(),type:_type,bookingRef:_booking.text.trim()));
      if(mounted)Navigator.pop(context);
    }catch(e){if(mounted)setState((){_busy=false;_error=appError(e);});}
  }
  @override
  Widget build(BuildContext context)=>SingleChildScrollView(padding:EdgeInsets.fromLTRB(24,24,24,24+MediaQuery.viewInsetsOf(context).bottom),child:Column(mainAxisSize:MainAxisSize.min,children:[
    Text('Add to day ${widget.initialDayIndex+1}',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:24),
    TextField(controller:_title,maxLength:120,decoration:const InputDecoration(labelText:'Title')),const SizedBox(height:16),
    TextField(controller:_location,decoration:const InputDecoration(labelText:'Location / details (optional)')),const SizedBox(height:16),
    DropdownButtonFormField<String>(initialValue:_type,decoration:const InputDecoration(labelText:'Type'),items:['activity','food','hotel','flight'].map((t)=>DropdownMenuItem(value:t,child:Text(t))).toList(),onChanged:(v)=>setState(()=>_type=v!)),
    const SizedBox(height:16),OutlinedButton.icon(onPressed:()async{final time=await showTimePicker(context:context,initialTime:_time);if(time!=null&&mounted)setState(()=>_time=time);},icon:const Icon(Icons.schedule),label:Text(_time.format(context))),
    const SizedBox(height:16),TextField(controller:_booking,decoration:const InputDecoration(labelText:'Booking reference (optional)')),
    if(_error!=null)Padding(padding:const EdgeInsets.all(12),child:Text(_error!)),const SizedBox(height:24),ElevatedButton(onPressed:_busy?null:_save,child:Text(_busy?'Saving…':'Add stop')),
  ]));
}
