# TripWallet

The active mobile app is in [`client/`](client/README.md). It uses Flutter, Supabase Auth/PostgreSQL, and a per-account SQLite cache with queued offline edits. The database changes live in [`supabase/migrations/`](supabase/migrations/). The Rust workspace in `backend/` and the older architecture notes document earlier prototypes; they are not the mobile app's active API.

The current app implements sign-in, trip invitations, shared expenses, receipt scanning and review, exact member splits, balances, payer-confirmed settlements, itinerary, export, and account deletion. Read [`client/README.md`](client/README.md) for setup and verification. The configured hosted Supabase project has the checked-in migrations applied. Authenticated device flows still need hands-on testing. Publishing and release signing are deferred until after testing.
