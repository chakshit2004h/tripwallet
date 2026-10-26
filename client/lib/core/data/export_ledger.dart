import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../domain/money.dart';
import 'trip_repository.dart';
String _cell(String value) {
  final safe=RegExp(r'^[=+\-@\t\r]').hasMatch(value)?"'$value":value;
  return '"${safe.replaceAll('"','""')}"';
}
String ledgerCsv(LedgerData data,{String? tripId}) {
  final rows=<List<String>>[['Trip','Expense','Currency','Amount','Paid by','Date','Split method']];
  for(final e in data.expenses.where((e)=>tripId==null||e.tripId==tripId)){
    rows.add([data.trips.where((t)=>t.id==e.tripId).map((t)=>t.name).firstOrNull??'',e.title,e.currency,
      decimalAmount(e.amountMinor,e.currency),data.memberName(e.paidByMemberId),e.createdAt.toIso8601String(),e.splitMethod]);
  }
  rows.add([]);rows.add(['Expense','Participant','Currency','Share']);
  for(final e in data.expenses.where((e)=>tripId==null||e.tripId==tripId)){
    for(final s in data.splits.where((s)=>s.expenseId==e.id)){
      rows.add([e.title,data.memberName(s.memberId),e.currency,decimalAmount(s.amountMinor,e.currency)]);
    }
  }
  rows.add([]);rows.add(['Trip','From','To','Currency','Payment','Method','Date']);
  for(final s in data.settlements.where((s)=>tripId==null||s.tripId==tripId)){
    rows.add([data.trips.where((t)=>t.id==s.tripId).map((t)=>t.name).firstOrNull??'',data.memberName(s.fromMemberId),
      data.memberName(s.toMemberId),s.currency,decimalAmount(s.amountMinor,s.currency),s.method,s.createdAt.toIso8601String()]);
  }
  return rows.map((r)=>r.map(_cell).join(',')).join('\r\n');
}
Future<void> shareLedger(LedgerData data,{String? tripId})async{
  await SharePlus.instance.share(ShareParams(files:[XFile.fromData(utf8.encode(ledgerCsv(data,tripId:tripId)),mimeType:'text/csv')],fileNameOverrides:['tripwallet-expenses.csv']));
}
