import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/app_error.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/domain/money.dart';

class SettlementConfirmDialog extends ConsumerStatefulWidget {
  final String tripId,fromMemberId,toMemberId,payeeName,method,currency;
  final int amountMinor;
  const SettlementConfirmDialog({super.key,required this.tripId,required this.fromMemberId,required this.toMemberId,required this.payeeName,
    required this.amountMinor,required this.method,this.currency='INR'});
  static Future<bool?> show(BuildContext context,{required String tripId,required String fromMemberId,required String toMemberId,
    required String payeeName,required int amountMinor,required String method,String currency='INR'})=>showDialog<bool>(context:context,barrierDismissible:false,
      builder:(_)=>SettlementConfirmDialog(tripId:tripId,fromMemberId:fromMemberId,toMemberId:toMemberId,payeeName:payeeName,amountMinor:amountMinor,method:method,currency:currency));
  @override
  ConsumerState<SettlementConfirmDialog> createState()=>_SettlementConfirmDialogState();
}
class _SettlementConfirmDialogState extends ConsumerState<SettlementConfirmDialog> {
  bool _busy=false;
  String? _error;
  Future<void> _save()async{
    if(_busy)return;
    setState(()=>_busy=true);
    try{
      await ref.read(tripRepositoryProvider).settle(tripId:widget.tripId,fromMemberId:widget.fromMemberId,toMemberId:widget.toMemberId,amountMinor:widget.amountMinor,method:widget.method);
      if(mounted)Navigator.of(context).pop(true);
    }catch(e){if(mounted)setState((){_busy=false;_error=appError(e);});}
  }
  @override
  Widget build(BuildContext context)=>AlertDialog(title:const Text('Record this payment?'),
    content:Text(_error??'Confirm that you paid ${formatMoney(widget.amountMinor,widget.currency)} to ${widget.payeeName}. This updates the shared balance and is recorded as reported by you.'),
    actions:[TextButton(onPressed:_busy?null:()=>Navigator.of(context).pop(false),child:const Text('Not yet')),
      TextButton(onPressed:_busy?null:_save,child:Text(_busy?'Saving…':'Yes, record payment'))]);
}
