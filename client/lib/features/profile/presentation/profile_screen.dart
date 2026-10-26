import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/supabase_auth_service.dart';
import '../../../core/data/app_error.dart';
import '../../../core/data/export_ledger.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/payment/payment_launcher.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState()=>_ProfileScreenState();
}
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final _name=TextEditingController(text:ref.read(supabaseAuthServiceProvider).currentDisplayName);
  late final _vpa=TextEditingController(text:ref.read(supabaseAuthServiceProvider).currentPaymentVpa??'');
  bool _busy=false;
  String? _message;
  @override
  void initState(){super.initState();_load();}
  Future<void> _load()async{
    final p=await ref.read(supabaseAuthServiceProvider).fetchUserProfile();
    if(mounted&&p!=null){_name.text=p.displayName;_vpa.text=p.paymentVpa??'';}
  }
  @override
  void dispose(){_name.dispose();_vpa.dispose();super.dispose();}
  Future<void> _save()async{
    if(_name.text.trim().isEmpty||(_vpa.text.trim().isNotEmpty&&!PaymentLauncher.validVpa(_vpa.text.trim()))){setState(()=>_message='Enter your name and a valid UPI ID, or leave UPI blank.');return;}
    setState(()=>_busy=true);
    try{await ref.read(supabaseAuthServiceProvider).updateProfile(displayName:_name.text.trim(),paymentVpa:_vpa.text.trim());
      if(mounted)setState(()=>_message='Profile updated. Your crew can use your saved UPI ID.');
    }catch(e){if(mounted)setState(()=>_message=appError(e));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  Future<void> _delete()async{
    final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Delete your account?'),
      content:const Text('Your sign-in and profile will be permanently deleted. Shared financial records remain under “Deleted account” so your friends’ balances stay accurate. Trips with no other members are deleted. This cannot be undone.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Delete my account'))]));
    if(yes!=true||!mounted)return;
    setState(()=>_busy=true);
    try{
      final db=ref.read(databaseProvider);
      final client=ref.read(supabaseClientProvider)!;
      await client.rpc('delete_my_account');
      await db.transaction(()async{for(final table in db.allTables){await db.delete(table).go();}});
      await client.auth.signOut(scope:SignOutScope.local);
      if(mounted)context.go('/login');
    }catch(e){if(mounted)setState(()=>_message=appError(e));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  @override
  Widget build(BuildContext context){
    final auth=ref.watch(supabaseAuthServiceProvider);
    final data=ref.watch(ledgerProvider).asData?.value;
    return Scaffold(appBar:AppBar(title:const Text('Profile')),body:ContentWidth(child:ListView(padding:const EdgeInsets.all(24),children:[
      Text('Make yourself at home.',style:AppTypography.titleLarge),const SizedBox(height:8),Text(auth.currentUser?.email??'',style:AppTypography.bodyLarge),const SizedBox(height:28),
      TextField(controller:_name,maxLength:80,decoration:const InputDecoration(labelText:'Display name')),const SizedBox(height:16),
      TextField(controller:_vpa,autocorrect:false,decoration:const InputDecoration(labelText:'UPI ID',hintText:'yourname@bank')),const SizedBox(height:8),
      Text('Your trip members can see this payment address. Check it carefully before saving.',style:AppTypography.bodySmall),
      if(_message!=null)Padding(padding:const EdgeInsets.symmetric(vertical:16),child:Text(_message!)),
      const SizedBox(height:20),ElevatedButton(onPressed:_busy?null:_save,child:Text(_busy?'Please wait…':'Save profile')),
      const SizedBox(height:32),ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.ios_share),title:const Text('Export my expense records'),onTap:data==null?null:()async{
        try{await shareLedger(data);}catch(e){if(mounted)setState(()=>_message=appError(e));}}),
      ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.privacy_tip_outlined),title:const Text('Privacy & your data'),onTap:()=>context.push('/privacy')),
      ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.logout),title:const Text('Sign out'),onTap:_busy?null:()async{
        if(data?.pending.isNotEmpty==true){final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Changes are still on this device'),content:const Text('Sign in to the same account on this device to finish syncing them.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Stay')),TextButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Sign out'))]));if(yes!=true)return;}
        try{await auth.client?.auth.signOut(scope:SignOutScope.local);if(context.mounted)context.go('/login');}catch(e){if(mounted)setState(()=>_message=appError(e));}
      }),const SizedBox(height:24),TextButton(onPressed:_busy?null:_delete,child:Text('Delete my account',style:TextStyle(color:Theme.of(context).colorScheme.error))),
    ])));
  }
}
