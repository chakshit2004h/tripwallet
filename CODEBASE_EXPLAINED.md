# TripWallet — Codebase & Architecture Cheat Sheet

> **Quick Summary**: TripWallet is an offline-first, accountless group expense app. 
> - **Backend**: Rust (Axum API + CRDT sync engine + financial math).
> - **Frontend**: Flutter (iOS/Android/Web + local Drift SQLite database).

---

## 1. The Real-World Flow (How It Works)

```
[User taps "Claim Dish" offline]
       │
       ▼
1. Saved to Phone's Local SQLite (Drift)  ──► Instant UI update (no loading spinner)
       │
       ▼
2. Appended to Outbound Sync Queue         ──► Queued in phone storage
       │
       ▼ (Phone gets internet)
3. POST /v1/trips/{id}/sync                ──► Sends only binary delta bytes to Rust server
       │
       ▼
4. Rust Merges via CRDT (yrs)              ──► Deterministic conflict-free merge
       │
       ▼
5. WebSocket Broadcast (Redis)             ──► All friends' phones update in real time
       │
       ▼
6. User taps "Settle Up"                   ──► Generates UPI / Revolut deep link
       │
       ▼
7. OS opens GPay / Revolut                 ──► TripWallet never touches or custodies money!
```

---

## 2. File-by-File Quick Reference

### 🦀 Backend (`backend/`)

#### Workspace Root
- [`backend/Cargo.toml`](Cargo.toml): Workspace manifest configuring dependencies (`tokio`, `axum`, `sqlx`, `yrs`, `serde`).

#### 1. Domain Logic (`backend/crates/domain/src/`) — *Pure Math & Rules*
- [`models/money.rs`](crates/domain/src/models/money.rs): Stores amounts as `MinorUnits(i64)` (paise/cents). Prevents floating-point errors.
- [`models/trip.rs`](crates/domain/src/models/trip.rs): Structs for `Trip`, `TripMember`, and roles (`Creator`, `Member`).
- [`models/expense.rs`](crates/domain/src/models/expense.rs): Structs for `Expense`, `ExpenseLineItem`, `ItemClaim`, and `SplitMethod`.
- [`debt_simplifier.rs`](crates/domain/src/debt_simplifier.rs): **Greedy Cash Flow Algorithm**. Turns a messy web of circular debts (A owes B, B owes C) into the minimum number of direct payments.
- [`proration.rs`](crates/domain/src/proration.rs): **Bill Math**. When friends claim different dishes on a receipt, this splits tax & tips proportionally down to the exact cent, giving any leftover 1-cent rounding difference to the payer.

#### 2. Offline Sync Engine (`backend/crates/crdt-core/src/`) — *Conflict Resolution*
- [`doc.rs`](crates/crdt-core/src/doc.rs): Wraps `yrs::Doc`. Calculates state vector diffs so two people can edit the same trip offline and merge seamlessly when back online.

#### 3. Payment Links (`backend/crates/payments/src/`) — *Non-Custodial*
- [`upi.rs`](crates/payments/src/upi.rs): Formats `upi://pay?pa=...&am=...&cu=INR` links to launch Google Pay, PhonePe, or Paytm.
- [`revolut.rs`](crates/payments/src/revolut.rs): Formats `https://revolut.me/{user}?amount=...` links for Europe/UK.

#### 4. Database & Storage (`backend/crates/persistence/`) — *Postgres*
- [`migrations/20260914000001_initial_schema.sql`](crates/persistence/migrations/20260914000001_initial_schema.sql): PostgreSQL tables (`trips`, `trip_members`, `guest_tokens`, `expenses`, `expense_splits`, `settlements`).
- [`src/db.rs`](crates/persistence/src/db.rs): Creates the database connection pool and runs migrations.

#### 5. HTTP Server (`backend/crates/api/src/`) — *API Entry*
- [`main.rs`](crates/api/src/main.rs): Starts the Axum web server and sets up logging.
- [`state.rs`](crates/api/src/state.rs): Holds shared application state (database pool).
- [`routes/health.rs`](crates/api/src/routes/health.rs): `GET /health` and `GET /ready` endpoints.

---

### 📱 Frontend Client (`client/`)

#### 1. Design System (`client/lib/core/theme/`) — *Visual Identity*
- [`app_colors.dart`](lib/core/theme/app_colors.dart): Colors matching the prototype: Ink (`#12100E`), Paper (`#282420`), Coral (`#FF5C35`), Cream (`#F4EFE4`).
- [`app_typography.dart`](lib/core/theme/app_typography.dart): Space Grotesk font hierarchy.
- [`app_theme.dart`](lib/core/theme/app_theme.dart): App-wide dark theme configuration.

#### 2. Local Database & Offline Queue (`client/lib/core/db/`) — *Offline Core*
- [`app_database.dart`](lib/core/db/app_database.dart): Drift SQLite tables on the phone. Includes `OutboundSyncQueue` which holds offline actions until reconnection.
- [`database_provider.dart`](lib/core/db/database_provider.dart): Riverpod provider to inject the database anywhere in the UI.

#### 3. Routing & Screens (`client/lib/`)
- [`core/router/app_router.dart`](lib/core/router/app_router.dart): GoRouter routes (`/`, `/landing`, `/trip/:id`).
- [`features/onboarding/presentation/splash_screen.dart`](lib/features/onboarding/presentation/splash_screen.dart): 1.5-second splash with wordmark branding.
- [`features/onboarding/presentation/landing_screen.dart`](lib/features/onboarding/presentation/landing_screen.dart): "Create a trip" or "Join via link/QR".
- [`features/trip_dashboard/presentation/trip_dashboard_screen.dart`](lib/features/trip_dashboard/presentation/trip_dashboard_screen.dart): Main trip screen with stats, tabs (Expenses / Balances / Itinerary), and floating "+ Add expense" button.
- [`app.dart`](lib/app.dart): Root MaterialApp widget.
- [`main.dart`](lib/main.dart): App entry point wrapped with Riverpod `ProviderScope`.

---

### 🐳 Infrastructure & Config (Root)
- [`docker-compose.yml`](../docker-compose.yml): Local services: PostgreSQL 16 (port 5432), Redis 7 (port 6379), MinIO S3 (ports 9000/9001).
- [`SESSION.md`](../SESSION.md): Contains the session ID to resume this conversation anytime.

---

## 3. How to Run & Test (Copy-Paste Commands)

```bash
# 1. Test Backend (runs 8 tests including proptest math verification)
cd /home/chakshit-2004/tripwallet/backend
cargo test --workspace

# 2. Test Frontend (runs SQLite database & widget tests)
cd /home/chakshit-2004/tripwallet/client
flutter test

# 3. Analyze Frontend Code (verifies 0 lint errors)
cd /home/chakshit-2004/tripwallet/client
flutter analyze
```
