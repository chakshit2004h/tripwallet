BEGIN;
-- Shared financial history keeps anonymous participant IDs after account deletion.
ALTER TABLE public.trip_members DROP CONSTRAINT IF EXISTS trip_members_user_id_fkey;
ALTER TABLE public.expenses DROP CONSTRAINT IF EXISTS expenses_paid_by_user_id_fkey;
ALTER TABLE public.expenses DROP CONSTRAINT IF EXISTS expenses_created_by_user_id_fkey;
ALTER TABLE public.expense_item_claims DROP CONSTRAINT IF EXISTS expense_item_claims_user_id_fkey;
ALTER TABLE public.settlements DROP CONSTRAINT IF EXISTS settlements_from_user_id_fkey;
ALTER TABLE public.settlements DROP CONSTRAINT IF EXISTS settlements_to_user_id_fkey;

CREATE OR REPLACE FUNCTION private.is_member(p_trip uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
 SELECT EXISTS (SELECT 1 FROM public.trip_members m JOIN auth.users u ON u.id=m.user_id
 WHERE m.trip_id=p_trip AND u.id=(SELECT auth.uid()));
$$;

CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE u uuid := auth.uid(); t record; successor uuid;
BEGIN
 IF u IS NULL OR NOT EXISTS(SELECT 1 FROM auth.users WHERE id=u) THEN RAISE EXCEPTION 'Sign in to delete your account'; END IF;
 FOR t IN SELECT id FROM public.trips WHERE created_by=u FOR UPDATE LOOP
   SELECT m.user_id INTO successor FROM public.trip_members m JOIN auth.users a ON a.id=m.user_id
     WHERE m.trip_id=t.id AND m.user_id<>u ORDER BY m.joined_at,m.id LIMIT 1;
   IF successor IS NULL THEN DELETE FROM public.trips WHERE id=t.id;
   ELSE
     UPDATE public.trips SET created_by=successor WHERE id=t.id;
     UPDATE public.trip_members SET role='creator' WHERE trip_id=t.id AND user_id=successor;
   END IF;
 END LOOP;
 UPDATE public.trip_members SET display_name='Deleted account',avatar_url=NULL,payment_vpa=NULL,role='member' WHERE user_id=u;
 DELETE FROM private.applied_commands WHERE user_id=u;
 DELETE FROM private.invite_attempts WHERE user_id=u;
 DELETE FROM auth.users WHERE id=u;
END $$;
REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;
COMMIT;
