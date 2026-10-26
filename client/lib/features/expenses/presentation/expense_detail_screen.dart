import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/data/app_error.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/domain/money.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;
  const ExpenseDetailScreen({super.key,required this.expenseId});
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final data=ref.watch(ledgerProvider).asData?.value;
    final expense=data?.expenses.where((e)=>e.id==expenseId).firstOrNull;
    if(expense==null)return Scaffold(appBar:AppBar(),body:const EmptyState(icon:Icons.receipt_long_outlined,title:'Expense not available',message:'It may have been deleted. Refresh your trip to check.'));
    final trip=data!.trips.firstWhere((t)=>t.id==expense.tripId);
    final user=ref.watch(accountIdProvider);
    final canDelete=trip.status=='active'&&(expense.createdBy==user||trip.createdBy==user);
    final db=ref.watch(databaseProvider);
    return Scaffold(appBar:AppBar(title:const Text('Expense details')),body:ContentWidth(child:ListView(padding:const EdgeInsets.all(24),children:[
      Text(expense.title,style:AppTypography.display),const SizedBox(height:12),Text(formatMoney(expense.amountMinor,expense.currency),style:AppTypography.display),
      const SizedBox(height:8),Text('Paid by ${data.memberName(expense.paidByMemberId)} · ${DateFormat('d MMM y').format(expense.createdAt)}',style:AppTypography.bodyLarge),
      const SizedBox(height:24),Text('The split',style:AppTypography.titleLarge),
      ...data.splits.where((s)=>s.expenseId==expenseId).map((s)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(data.memberName(s.memberId)),trailing:Text(formatMoney(s.amountMinor,expense.currency)))),
      StreamBuilder(stream:(db.select(db.localLineItems)..where((l)=>l.expenseId.equals(expenseId))).watch(),builder:(context,snapshot)=>Column(children:[
        if(snapshot.hasData&&snapshot.data!.isNotEmpty)...[const Divider(),...snapshot.data!.map((l)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(l.label),trailing:Text(formatMoney(l.priceMinor,expense.currency)))),
          ListTile(contentPadding:EdgeInsets.zero,title:const Text('Tax & service'),trailing:Text(formatMoney(expense.taxMinor+expense.serviceChargeMinor,expense.currency)))],
      ])),
      if(canDelete)...[const SizedBox(height:32),OutlinedButton.icon(icon:const Icon(Icons.delete_outline),label:const Text('Delete expense'),onPressed:()async{
        final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Delete this expense?'),content:const Text('This removes the expense and its shares from everyone’s balance.'),actions:[
          TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Keep expense')),TextButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Delete'))]));
        if(yes!=true)return;
        try{await ref.read(tripRepositoryProvider).deleteExpense(expense);if(context.mounted)context.pop();}
        catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(appError(e))));}
      })],
    ])));
  }
}
