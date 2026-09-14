-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Guest identities (device keypair, no password/email required)
CREATE TABLE IF NOT EXISTS guest_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id TEXT NOT NULL,
    public_key_ed25519 TEXT NOT NULL,
    linked_account_id UUID NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_guest_tokens_device ON guest_tokens(device_id);

-- Trips
CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invite_code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    base_currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    cover_image_url TEXT NULL,
    created_by UUID NOT NULL REFERENCES guest_tokens(id),
    crdt_snapshot BYTEA NULL,
    state_vector BYTEA NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_trips_invite_code ON trips(invite_code);

-- Trip Members
CREATE TABLE IF NOT EXISTS trip_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    guest_token_id UUID NOT NULL REFERENCES guest_tokens(id),
    display_name TEXT NOT NULL,
    avatar_url TEXT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'member', -- 'creator' | 'member'
    payment_vpa_encrypted TEXT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(trip_id, guest_token_id)
);
CREATE INDEX IF NOT EXISTS idx_trip_members_trip ON trip_members(trip_id);

-- Expenses
CREATE TABLE IF NOT EXISTS expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount_minor BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL,
    paid_by_member_id UUID NOT NULL REFERENCES trip_members(id),
    split_method VARCHAR(20) NOT NULL DEFAULT 'equal', -- 'equal', 'percentage', 'shares', 'exact', 'itemized'
    receipt_image_url TEXT NULL,
    tax_minor BIGINT NOT NULL DEFAULT 0,
    service_charge_minor BIGINT NOT NULL DEFAULT 0,
    created_by_member_id UUID NOT NULL REFERENCES trip_members(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);
CREATE INDEX IF NOT EXISTS idx_expenses_trip ON expenses(trip_id);

-- Line Items (from OCR receipt scan)
CREATE TABLE IF NOT EXISTS expense_line_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expense_id UUID NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    price_minor BIGINT NOT NULL,
    ocr_confidence REAL NOT NULL DEFAULT 1.0
);
CREATE INDEX IF NOT EXISTS idx_expense_line_items_exp ON expense_line_items(expense_id);

-- Item Claims (multi-member claiming per line item)
CREATE TABLE IF NOT EXISTS expense_item_claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    line_item_id UUID NOT NULL REFERENCES expense_line_items(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES trip_members(id) ON DELETE CASCADE,
    share_fraction NUMERIC(5, 4) NOT NULL DEFAULT 1.0,
    UNIQUE(line_item_id, member_id)
);

-- Materialized Expense Splits
CREATE TABLE IF NOT EXISTS expense_splits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expense_id UUID NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES trip_members(id) ON DELETE CASCADE,
    amount_minor BIGINT NOT NULL,
    UNIQUE(expense_id, member_id)
);
CREATE INDEX IF NOT EXISTS idx_expense_splits_exp ON expense_splits(expense_id);

-- Settlements
CREATE TABLE IF NOT EXISTS settlements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    from_member_id UUID NOT NULL REFERENCES trip_members(id),
    to_member_id UUID NOT NULL REFERENCES trip_members(id),
    amount_minor BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL,
    method VARCHAR(30) NOT NULL, -- 'upi', 'revolut', 'stripe', 'apple_cash'
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'confirmed', 'failed'
    external_ref TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ NULL
);
CREATE INDEX IF NOT EXISTS idx_settlements_trip ON settlements(trip_id);

-- Itinerary Items
CREATE TABLE IF NOT EXISTS itinerary_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    day_index INT NOT NULL DEFAULT 0,
    item_type VARCHAR(20) NOT NULL, -- 'flight', 'hotel', 'activity'
    title TEXT NOT NULL,
    start_time TIMESTAMPTZ NULL,
    attachment_url TEXT NULL,
    location_lat NUMERIC(9, 6) NULL,
    location_lng NUMERIC(9, 6) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_itinerary_trip ON itinerary_items(trip_id, day_index);

-- Subscriptions / Paywall Passes
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NULL REFERENCES trips(id),
    account_id UUID NULL,
    plan VARCHAR(20) NOT NULL, -- 'trip_pass', 'annual_pro'
    store VARCHAR(20) NOT NULL, -- 'app_store', 'play_store'
    store_transaction_id TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
