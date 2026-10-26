\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email) VALUES
 ('11111111-1111-4111-8111-111111111111','alice@example.test'),
 ('22222222-2222-4222-8222-222222222222','bob@example.test'),
 ('33333333-3333-4333-8333-333333333333','outsider@example.test');

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SELECT (public.create_trip('Security test','INR')->>'id') AS trip_id \gset
SELECT invite_code AS invite_code FROM public.trips WHERE id=:'trip_id' \gset
SELECT set_config('test.trip',:'trip_id',true);
DO $$ BEGIN
 IF (SELECT count(*) FROM public.trips) <> 1 THEN RAISE EXCEPTION 'Creator cannot read trip'; END IF;
 IF (SELECT count(*) FROM public.profiles) <> 1 THEN RAISE EXCEPTION 'Profile RLS leaks users'; END IF;
 BEGIN
   INSERT INTO public.expenses(trip_id,title,amount_minor,currency,paid_by_user_id,created_by_user_id)
   VALUES(current_setting('test.trip')::uuid,'Bypass',100,'INR',auth.uid(),auth.uid());
   RAISE EXCEPTION 'Direct expense insert succeeded';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;

SELECT set_config('request.jwt.claim.sub','33333333-3333-4333-8333-333333333333',true);
DO $$ DECLARE denied boolean := false; BEGIN
 IF (SELECT count(*) FROM public.trips) <> 0 THEN RAISE EXCEPTION 'Trip RLS leaked'; END IF;
 BEGIN PERFORM public.trip_snapshot(current_setting('test.trip')::uuid);
 EXCEPTION WHEN OTHERS THEN denied := true; END;
 IF NOT denied THEN RAISE EXCEPTION 'Snapshot leaked'; END IF;
END $$;

SELECT set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
SELECT public.resolve_invite(:'invite_code',true);
DO $$ BEGIN
 IF (SELECT count(*) FROM public.trip_members) <> 2 THEN RAISE EXCEPTION 'Join failed'; END IF;
END $$;

SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SELECT set_config('test.expense','44444444-4444-4444-8444-444444444444',true);
SELECT set_config('test.command','55555555-5555-4555-8555-555555555555',true);
DO $$ DECLARE c jsonb; denied boolean := false; BEGIN
 c := jsonb_build_object('kind','expense','id',current_setting('test.expense'),
 'command_id',current_setting('test.command'),'trip_id',current_setting('test.trip'),
 'title','Dinner','amount_minor',101,'currency','INR','paid_by_user_id',auth.uid(),
 'split_method','exact','category','food','splits',jsonb_build_array(
 jsonb_build_object('user_id',auth.uid(),'amount_minor',50),
 jsonb_build_object('user_id','22222222-2222-4222-8222-222222222222','amount_minor',50)));
 BEGIN PERFORM public.apply_command(c);
 EXCEPTION WHEN OTHERS THEN denied := true; END;
 IF NOT denied THEN RAISE EXCEPTION 'Unbalanced expense accepted'; END IF;
 c := jsonb_set(c,'{splits,1,amount_minor}','51'::jsonb);
 PERFORM public.apply_command(c);
 PERFORM public.apply_command(c);
 IF (SELECT count(*) FROM public.expenses WHERE trip_id=current_setting('test.trip')::uuid) <> 1
 THEN RAISE EXCEPTION 'Retry duplicated expense'; END IF;
END $$;

SELECT set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
DO $$ DECLARE c jsonb; denied boolean := false; BEGIN
 c := jsonb_build_object('kind','settlement','id','66666666-6666-4666-8666-666666666666',
 'command_id','77777777-7777-4777-8777-777777777777','trip_id',current_setting('test.trip'),
 'from_user_id',auth.uid(),'to_user_id','11111111-1111-4111-8111-111111111111',
 'amount_minor',52,'currency','INR','method','cash');
 BEGIN PERFORM public.apply_command(c);
 EXCEPTION WHEN OTHERS THEN denied := true; END;
 IF NOT denied THEN RAISE EXCEPTION 'Overpayment accepted'; END IF;
 c := jsonb_set(c,'{amount_minor}','51'::jsonb);
 PERFORM public.apply_command(c);
 IF (SELECT count(*) FROM public.settlements WHERE trip_id=current_setting('test.trip')::uuid) <> 1
 THEN RAISE EXCEPTION 'Valid settlement failed'; END IF;
END $$;
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SELECT public.delete_my_account();
RESET ROLE;
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM auth.users WHERE id='11111111-1111-4111-8111-111111111111')
 THEN RAISE EXCEPTION 'Deleted account still authenticates'; END IF;
 IF (SELECT count(*) FROM public.expenses WHERE trip_id=current_setting('test.trip')::uuid) <> 1
 THEN RAISE EXCEPTION 'Shared expense was lost on account deletion'; END IF;
 IF (SELECT created_by FROM public.trips WHERE id=current_setting('test.trip')::uuid)
   <> '22222222-2222-4222-8222-222222222222'::uuid
 THEN RAISE EXCEPTION 'Trip creator was not transferred'; END IF;
END $$;
ROLLBACK;
