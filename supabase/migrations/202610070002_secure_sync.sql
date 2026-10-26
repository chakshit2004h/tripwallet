-- Apply after the base schema, including on existing installations.
BEGIN;
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;
GRANT USAGE ON SCHEMA private TO authenticated;

CREATE TABLE IF NOT EXISTS public.expense_splits (
  expense_id uuid NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  amount_minor bigint NOT NULL CHECK (amount_minor >= 0),
  PRIMARY KEY (expense_id, user_id)
);
CREATE TABLE IF NOT EXISTS private.invite_attempts (
  user_id uuid PRIMARY KEY,
  window_start timestamptz NOT NULL DEFAULT now(),
  attempts integer NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS private.applied_commands (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL,
  payload jsonb NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION private.is_member(p_trip uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
 SELECT EXISTS (SELECT 1 FROM public.trip_members
 WHERE trip_id = p_trip AND user_id = (SELECT auth.uid()));
$$;
CREATE OR REPLACE FUNCTION private.is_creator(p_trip uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
 SELECT EXISTS (SELECT 1 FROM public.trips
 WHERE id = p_trip AND created_by = (SELECT auth.uid()));
$$;
REVOKE ALL ON FUNCTION private.is_member(uuid), private.is_creator(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.is_member(uuid), private.is_creator(uuid) TO authenticated;

-- Remove the recursive and overly broad prototype policies, including old names.
DO $$ DECLARE r record; BEGIN
 FOR r IN SELECT schemaname, tablename, policyname FROM pg_policies
 WHERE schemaname = 'public' AND tablename IN
 ('profiles','trips','trip_members','expenses','expense_line_items',
 'expense_item_claims','expense_splits','settlements','itinerary_stops','alerts') LOOP
   EXECUTE format('DROP POLICY %I ON %I.%I',r.policyname,r.schemaname,r.tablename);
 END LOOP;
END $$;
DO $$ DECLARE t text; BEGIN
 FOREACH t IN ARRAY ARRAY['profiles','trips','trip_members','expenses',
 'expense_line_items','expense_item_claims','expense_splits','settlements','itinerary_stops','alerts'] LOOP
   EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',t);
   EXECUTE format('REVOKE ALL ON public.%I FROM anon, authenticated',t);
   EXECUTE format('GRANT SELECT ON public.%I TO authenticated',t);
 END LOOP;
END $$;
GRANT UPDATE(display_name, payment_vpa, avatar_url, updated_at) ON public.profiles TO authenticated;
CREATE POLICY own_profile_read ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY own_profile_update ON public.profiles FOR UPDATE TO authenticated
 USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY member_trips ON public.trips FOR SELECT TO authenticated USING (private.is_member(id));
CREATE POLICY member_roster ON public.trip_members FOR SELECT TO authenticated USING (private.is_member(trip_id));
CREATE POLICY member_expenses ON public.expenses FOR SELECT TO authenticated USING (private.is_member(trip_id));
CREATE POLICY member_settlements ON public.settlements FOR SELECT TO authenticated USING (private.is_member(trip_id));
CREATE POLICY member_itinerary ON public.itinerary_stops FOR SELECT TO authenticated USING (private.is_member(trip_id));
CREATE POLICY member_alerts ON public.alerts FOR SELECT TO authenticated USING (private.is_member(trip_id));
CREATE POLICY member_lines ON public.expense_line_items FOR SELECT TO authenticated USING
 (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_id AND private.is_member(e.trip_id)));
CREATE POLICY member_claims ON public.expense_item_claims FOR SELECT TO authenticated USING
 (EXISTS (SELECT 1 FROM public.expense_line_items l JOIN public.expenses e ON e.id=l.expense_id
 WHERE l.id = line_item_id AND private.is_member(e.trip_id)));
CREATE POLICY member_splits ON public.expense_splits FOR SELECT TO authenticated USING
 (EXISTS (SELECT 1 FROM public.expenses e WHERE e.id = expense_id AND private.is_member(e.trip_id)));

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 INSERT INTO public.profiles(id,email,display_name,payment_vpa)
 VALUES (new.id,coalesce(new.email,''),
 left(coalesce(nullif(trim(new.raw_user_meta_data->>'display_name'),''),'Traveler'),80),
 nullif(trim(new.raw_user_meta_data->>'payment_vpa'),''));
 RETURN new;
END $$;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION private.sync_profile()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 IF length(trim(new.display_name)) NOT BETWEEN 1 AND 80 THEN
   RAISE EXCEPTION 'Display name must be between 1 and 80 characters'; END IF;
 IF new.payment_vpa IS NOT NULL AND new.payment_vpa <> '' AND
   new.payment_vpa !~ '^[A-Za-z0-9._-]{2,256}@[A-Za-z0-9.-]{2,64}$' THEN
   RAISE EXCEPTION 'Enter a valid UPI ID'; END IF;
 UPDATE public.trip_members SET display_name=new.display_name,
 payment_vpa=nullif(new.payment_vpa,''),avatar_url=new.avatar_url WHERE user_id=new.id;
 RETURN new;
END $$;
DROP TRIGGER IF EXISTS profile_updated ON public.profiles;
CREATE TRIGGER profile_updated AFTER UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION private.sync_profile();

CREATE OR REPLACE FUNCTION public.create_trip(p_name text, p_currency text DEFAULT 'INR',
 p_start date DEFAULT NULL, p_end date DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE t public.trips; u uuid := auth.uid(); p public.profiles;
BEGIN
 IF u IS NULL THEN RAISE EXCEPTION 'Sign in to create a trip'; END IF;
 IF length(trim(p_name)) NOT BETWEEN 1 AND 80 OR p_currency NOT IN ('INR','USD','EUR','GBP','JPY')
 OR p_end < p_start THEN RAISE EXCEPTION 'Invalid trip details'; END IF;
 SELECT * INTO STRICT p FROM public.profiles WHERE id=u;
 INSERT INTO public.trips(name,invite_code,base_currency,start_date,end_date,created_by)
 VALUES(trim(p_name),upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)),p_currency,p_start,p_end,u)
 RETURNING * INTO t;
 INSERT INTO public.trip_members(trip_id,user_id,display_name,role,payment_vpa)
 VALUES(t.id,u,p.display_name,'creator',p.payment_vpa);
 RETURN to_jsonb(t);
END $$;

CREATE OR REPLACE FUNCTION public.resolve_invite(p_code text, p_join boolean DEFAULT false)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE t public.trips; p public.profiles; n integer; u uuid := auth.uid();
BEGIN
 IF u IS NULL THEN RAISE EXCEPTION 'Sign in to join a trip'; END IF;
 INSERT INTO private.invite_attempts(user_id,attempts) VALUES(u,1)
 ON CONFLICT(user_id) DO UPDATE SET
 attempts=CASE WHEN private.invite_attempts.window_start < now()-interval '1 minute' THEN 1
 ELSE private.invite_attempts.attempts+1 END,
 window_start=CASE WHEN private.invite_attempts.window_start < now()-interval '1 minute' THEN now()
 ELSE private.invite_attempts.window_start END RETURNING attempts INTO n;
 -- Return an error value so the attempt counter commits on failed lookups.
 IF n > 20 THEN RETURN jsonb_build_object('error','Too many attempts. Try again in a minute.'); END IF;
 SELECT * INTO t FROM public.trips WHERE invite_code=upper(trim(p_code)) AND status='active';
 IF t.id IS NULL THEN RETURN jsonb_build_object('error','No active trip matches this code.'); END IF;
 IF p_join THEN
   SELECT * INTO STRICT p FROM public.profiles WHERE id=u;
   INSERT INTO public.trip_members(trip_id,user_id,display_name,payment_vpa)
   VALUES(t.id,u,p.display_name,p.payment_vpa) ON CONFLICT(trip_id,user_id) DO NOTHING;
 END IF;
 RETURN jsonb_build_object('id',t.id,'name',t.name,'invite_code',t.invite_code,
 'base_currency',t.base_currency,'start_date',t.start_date,'end_date',t.end_date,
 'status',t.status,'created_by',t.created_by);
END $$;

-- One transaction per immutable command. Duplicate HTTP retries never duplicate money.
CREATE OR REPLACE FUNCTION public.apply_command(p_command jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
 u uuid := auth.uid(); tid uuid := (p_command->>'trip_id')::uuid;
 cid uuid := (p_command->>'command_id')::uuid; eid uuid := (p_command->>'id')::uuid;
 kind text := p_command->>'kind'; prior private.applied_commands;
 t public.trips; e public.expenses; member uuid; part jsonb; item jsonb; claimant jsonb;
 total bigint; paid uuid; amount bigint; subtotal bigint; lineid uuid;
 payer_balance bigint; payee_balance bigint;
BEGIN
 IF u IS NULL OR cid IS NULL OR eid IS NULL OR tid IS NULL THEN RAISE EXCEPTION 'Invalid command'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended(cid::text,0));
 SELECT * INTO prior FROM private.applied_commands WHERE id=cid;
 IF prior.id IS NOT NULL THEN
   IF prior.user_id <> u OR prior.payload <> p_command THEN RAISE EXCEPTION 'Command ID already used'; END IF;
   RETURN;
 END IF;
 SELECT * INTO t FROM public.trips WHERE id=tid FOR UPDATE;
 IF t.id IS NULL OR NOT private.is_member(tid) THEN RAISE EXCEPTION 'Trip access denied'; END IF;
 IF t.status <> 'active' THEN RAISE EXCEPTION 'This trip is archived'; END IF;
 IF kind='expense' THEN
   amount := (p_command->>'amount_minor')::bigint; paid := (p_command->>'paid_by_user_id')::uuid;
   IF amount IS NULL OR amount <= 0 OR amount > 100000000000
   OR length(trim(p_command->>'title')) NOT BETWEEN 1 AND 120
   OR (p_command->>'currency') IS DISTINCT FROM t.base_currency
   OR NOT EXISTS(SELECT 1 FROM public.trip_members WHERE trip_id=tid AND user_id=paid)
   OR coalesce(p_command->>'split_method','') NOT IN ('equal','exact','percentage','itemized')
   OR coalesce(p_command->>'category','') NOT IN ('food','stay','transport','activity','shopping','other')
   THEN RAISE EXCEPTION 'Invalid expense'; END IF;
   IF jsonb_typeof(p_command->'splits') IS DISTINCT FROM 'array' OR jsonb_array_length(p_command->'splits')=0
   THEN RAISE EXCEPTION 'Expense splits are required'; END IF;
   total := 0;
   FOR part IN SELECT value FROM jsonb_array_elements(p_command->'splits') LOOP
     member := (part->>'user_id')::uuid;
     IF member IS NULL OR (part->>'amount_minor') IS NULL OR (part->>'amount_minor')::bigint < 0
     OR NOT EXISTS(SELECT 1 FROM public.trip_members WHERE trip_id=tid AND user_id=member)
     THEN RAISE EXCEPTION 'Invalid split participant'; END IF;
     total := total + (part->>'amount_minor')::bigint;
   END LOOP;
   IF total <> amount THEN RAISE EXCEPTION 'Splits must add up to the expense total'; END IF;
   IF coalesce((p_command->>'tax_minor')::bigint,0) < 0 OR coalesce((p_command->>'service_charge_minor')::bigint,0) < 0
   THEN RAISE EXCEPTION 'Charges cannot be negative'; END IF;
   INSERT INTO public.expenses(id,trip_id,title,amount_minor,currency,paid_by_user_id,
   split_method,category,tax_minor,service_charge_minor,created_by_user_id)
   VALUES(eid,tid,trim(p_command->>'title'),amount,t.base_currency,paid,p_command->>'split_method',
   p_command->>'category',coalesce((p_command->>'tax_minor')::bigint,0),
   coalesce((p_command->>'service_charge_minor')::bigint,0),u);
   FOR part IN SELECT value FROM jsonb_array_elements(p_command->'splits') LOOP
     INSERT INTO public.expense_splits VALUES(eid,(part->>'user_id')::uuid,(part->>'amount_minor')::bigint);
   END LOOP;
   subtotal := 0;
   FOR item IN SELECT value FROM jsonb_array_elements(coalesce(p_command->'items','[]'::jsonb)) LOOP
     lineid := (item->>'id')::uuid;
     IF (item->>'price_minor')::bigint <= 0 OR length(trim(item->>'label')) NOT BETWEEN 1 AND 200
     THEN RAISE EXCEPTION 'Invalid receipt item'; END IF;
     subtotal := subtotal + (item->>'price_minor')::bigint;
     INSERT INTO public.expense_line_items(id,expense_id,label,price_minor,ocr_confidence)
     VALUES(lineid,eid,item->>'label',(item->>'price_minor')::bigint,coalesce((item->>'confidence')::real,1));
     IF jsonb_array_length(item->'claimed_by_user_ids')=0 THEN RAISE EXCEPTION 'Claim every item'; END IF;
     FOR claimant IN SELECT value FROM jsonb_array_elements(item->'claimed_by_user_ids') LOOP
       member := (claimant #>> '{}')::uuid;
       IF NOT EXISTS(SELECT 1 FROM public.trip_members WHERE trip_id=tid AND user_id=member)
       THEN RAISE EXCEPTION 'Invalid item claimant'; END IF;
       INSERT INTO public.expense_item_claims(line_item_id,user_id,share_fraction)
       VALUES(lineid,member,1.0/jsonb_array_length(item->'claimed_by_user_ids'));
     END LOOP;
   END LOOP;
   IF p_command->>'split_method'='itemized' AND subtotal + coalesce((p_command->>'tax_minor')::bigint,0)
     + coalesce((p_command->>'service_charge_minor')::bigint,0) <> amount
   THEN RAISE EXCEPTION 'Receipt items and charges must add up to the total'; END IF;
 ELSIF kind='settlement' THEN
   amount := (p_command->>'amount_minor')::bigint;
   member := (p_command->>'to_user_id')::uuid;
   IF (p_command->>'from_user_id')::uuid IS DISTINCT FROM u OR member IS NULL OR member=u
     OR amount IS NULL OR amount <= 0 OR amount > 100000000000
     OR p_command->>'currency' IS DISTINCT FROM t.base_currency
     OR coalesce(p_command->>'method','') NOT IN ('upi','cash','bank')
   OR NOT EXISTS(SELECT 1 FROM public.trip_members WHERE trip_id=tid AND user_id=member)
   THEN RAISE EXCEPTION 'Invalid settlement'; END IF;
   SELECT coalesce(sum(delta),0) INTO payer_balance FROM (
     SELECT amount_minor AS delta FROM public.expenses WHERE trip_id=tid AND paid_by_user_id=u
     UNION ALL SELECT -s.amount_minor FROM public.expense_splits s JOIN public.expenses ex ON ex.id=s.expense_id
       WHERE ex.trip_id=tid AND s.user_id=u
     UNION ALL SELECT amount_minor FROM public.settlements WHERE trip_id=tid AND from_user_id=u AND status='confirmed'
     UNION ALL SELECT -amount_minor FROM public.settlements WHERE trip_id=tid AND to_user_id=u AND status='confirmed'
   ) amounts;
   SELECT coalesce(sum(delta),0) INTO payee_balance FROM (
     SELECT amount_minor AS delta FROM public.expenses WHERE trip_id=tid AND paid_by_user_id=member
     UNION ALL SELECT -s.amount_minor FROM public.expense_splits s JOIN public.expenses ex ON ex.id=s.expense_id
       WHERE ex.trip_id=tid AND s.user_id=member
     UNION ALL SELECT amount_minor FROM public.settlements WHERE trip_id=tid AND from_user_id=member AND status='confirmed'
     UNION ALL SELECT -amount_minor FROM public.settlements WHERE trip_id=tid AND to_user_id=member AND status='confirmed'
   ) amounts;
   IF payer_balance >= 0 OR payee_balance <= 0 OR amount > least(-payer_balance,payee_balance)
   THEN RAISE EXCEPTION 'Payment exceeds the outstanding balance'; END IF;
   INSERT INTO public.settlements(id,trip_id,from_user_id,to_user_id,amount_minor,currency,method)
   VALUES(eid,tid,u,member,amount,t.base_currency,p_command->>'method');
 ELSIF kind='itinerary' THEN
   IF length(trim(p_command->>'title')) NOT BETWEEN 1 AND 120
   OR (p_command->>'day_index')::integer NOT BETWEEN 0 AND 365
   OR coalesce(p_command->>'time','') !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'
   OR coalesce(p_command->>'type','') NOT IN ('flight','hotel','food','activity')
   THEN RAISE EXCEPTION 'Invalid itinerary stop'; END IF;
   INSERT INTO public.itinerary_stops(id,trip_id,day_index,time,title,subtitle,type,booking_ref)
   VALUES(eid,tid,(p_command->>'day_index')::integer,p_command->>'time',trim(p_command->>'title'),
   coalesce(p_command->>'subtitle',''),p_command->>'type',p_command->>'booking_ref');
 ELSIF kind='delete_expense' THEN
   SELECT * INTO e FROM public.expenses WHERE id=eid AND trip_id=tid;
   IF e.id IS NOT NULL AND e.created_by_user_id <> u AND NOT private.is_creator(tid)
   THEN RAISE EXCEPTION 'Only the author or trip creator can delete an expense'; END IF;
   DELETE FROM public.expenses WHERE id=eid AND trip_id=tid;
 ELSIF kind='delete_itinerary' THEN
   DELETE FROM public.itinerary_stops WHERE id=eid AND trip_id=tid;
 ELSE RAISE EXCEPTION 'Unsupported command';
 END IF;
 INSERT INTO private.applied_commands(id,user_id,payload) VALUES(cid,u,p_command);
END $$;

CREATE OR REPLACE FUNCTION public.trip_snapshot(p_trip uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 IF NOT private.is_member(p_trip) THEN RAISE EXCEPTION 'Trip access denied'; END IF;
 RETURN jsonb_build_object(
 'trip',(SELECT to_jsonb(t) FROM public.trips t WHERE id=p_trip),
 'members',coalesce((SELECT jsonb_agg(m) FROM public.trip_members m WHERE trip_id=p_trip),'[]'),
 'expenses',coalesce((SELECT jsonb_agg(e) FROM public.expenses e WHERE trip_id=p_trip),'[]'),
 'splits',coalesce((SELECT jsonb_agg(s) FROM public.expense_splits s JOIN public.expenses e ON e.id=s.expense_id WHERE e.trip_id=p_trip),'[]'),
 'items',coalesce((SELECT jsonb_agg(l) FROM public.expense_line_items l JOIN public.expenses e ON e.id=l.expense_id WHERE e.trip_id=p_trip),'[]'),
 'claims',coalesce((SELECT jsonb_agg(c) FROM public.expense_item_claims c JOIN public.expense_line_items l ON l.id=c.line_item_id JOIN public.expenses e ON e.id=l.expense_id WHERE e.trip_id=p_trip),'[]'),
 'settlements',coalesce((SELECT jsonb_agg(s) FROM public.settlements s WHERE trip_id=p_trip),'[]'),
 'itinerary',coalesce((SELECT jsonb_agg(s) FROM public.itinerary_stops s WHERE trip_id=p_trip),'[]'));
END $$;

CREATE OR REPLACE FUNCTION public.manage_trip(p_trip uuid, p_action text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 IF NOT private.is_creator(p_trip) THEN RAISE EXCEPTION 'Only the trip creator can do this'; END IF;
 IF p_action='archive' THEN UPDATE public.trips SET status='archived',updated_at=now() WHERE id=p_trip;
 ELSIF p_action='restore' THEN UPDATE public.trips SET status='active',updated_at=now() WHERE id=p_trip;
 ELSIF p_action='delete' THEN DELETE FROM public.trips WHERE id=p_trip;
 ELSE RAISE EXCEPTION 'Invalid action'; END IF;
END $$;

REVOKE ALL ON FUNCTION public.create_trip(text,text,date,date), public.resolve_invite(text,boolean),
 public.apply_command(jsonb), public.trip_snapshot(uuid), public.manage_trip(uuid,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_trip(text,text,date,date), public.resolve_invite(text,boolean),
 public.apply_command(jsonb), public.trip_snapshot(uuid), public.manage_trip(uuid,text) TO authenticated;

-- Re-running a deployment must not fail on publication membership.
DO $$ DECLARE t text; BEGIN
 IF EXISTS(SELECT 1 FROM pg_publication WHERE pubname='supabase_realtime') THEN
 FOREACH t IN ARRAY ARRAY['trips','trip_members','expenses','expense_splits','settlements','itinerary_stops'] LOOP
   IF NOT EXISTS(SELECT 1 FROM pg_publication_tables WHERE pubname='supabase_realtime' AND schemaname='public' AND tablename=t) THEN
     EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I',t);
   END IF;
 END LOOP;
 END IF;
END $$;
COMMIT;
