-- ==============================================================================
-- TripWallet Production Schema for Supabase PostgreSQL
-- ==============================================================================

-- 1. Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. User Profiles (Extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    display_name TEXT NOT NULL,
    avatar_url TEXT NULL,
    payment_vpa TEXT NULL, -- Default UPI ID (e.g. user@okhdfcbank)
    default_currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger to automatically create a public.profiles row whenever a new user signs up in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name, payment_vpa, avatar_url)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)),
        new.raw_user_meta_data->>'payment_vpa',
        new.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. Trips Table
CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    invite_code VARCHAR(8) UNIQUE NOT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    base_currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    cover_image_url TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, archived
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_trips_invite_code ON public.trips(invite_code);
CREATE INDEX IF NOT EXISTS idx_trips_created_by ON public.trips(created_by);

-- 4. Trip Members
CREATE TABLE IF NOT EXISTS public.trip_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    avatar_url TEXT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'member', -- creator, member
    payment_vpa TEXT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(trip_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_trip_members_trip ON public.trip_members(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_members_user ON public.trip_members(user_id);

-- 5. Expenses
CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount_minor BIGINT NOT NULL,
    category VARCHAR(30) NOT NULL DEFAULT 'food', -- food, stay, transport, activity, shopping, other
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    paid_by_user_id UUID NOT NULL REFERENCES auth.users(id),
    split_method VARCHAR(20) NOT NULL DEFAULT 'equal', -- equal, itemized, custom
    tax_minor BIGINT NOT NULL DEFAULT 0,
    service_charge_minor BIGINT NOT NULL DEFAULT 0,
    receipt_image_url TEXT NULL,
    created_by_user_id UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expenses_trip ON public.expenses(trip_id);

-- 6. Expense Line Items (From OCR receipt breakdown)
CREATE TABLE IF NOT EXISTS public.expense_line_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    price_minor BIGINT NOT NULL,
    ocr_confidence REAL NOT NULL DEFAULT 1.0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_line_items_expense ON public.expense_line_items(expense_id);

-- 7. Expense Item Claims (Multi-member claiming per line item)
CREATE TABLE IF NOT EXISTS public.expense_item_claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    line_item_id UUID NOT NULL REFERENCES public.expense_line_items(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    share_fraction NUMERIC(5, 4) NOT NULL DEFAULT 1.0,
    UNIQUE(line_item_id, user_id)
);

-- 8. Settlements (Debt settlements between trip members)
CREATE TABLE IF NOT EXISTS public.settlements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    from_user_id UUID NOT NULL REFERENCES auth.users(id),
    to_user_id UUID NOT NULL REFERENCES auth.users(id),
    amount_minor BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    payment_reference TEXT NULL,
    method VARCHAR(30) NOT NULL DEFAULT 'upi', -- upi, cash, card
    status VARCHAR(20) NOT NULL DEFAULT 'confirmed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_settlements_trip ON public.settlements(trip_id);

-- 9. Itinerary Stops
CREATE TABLE IF NOT EXISTS public.itinerary_stops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    day_index INT NOT NULL DEFAULT 0,
    time TEXT NOT NULL,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    type VARCHAR(30) NOT NULL DEFAULT 'flight', -- flight, hotel, food, activity
    booking_ref TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_itinerary_trip ON public.itinerary_stops(trip_id);

-- 10. Activity Alerts
CREATE TABLE IF NOT EXISTS public.alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    time_ago TEXT NOT NULL DEFAULT 'just now',
    icon_type VARCHAR(20) NOT NULL DEFAULT 'receipt',
    is_coral BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_trip ON public.alerts(trip_id);

