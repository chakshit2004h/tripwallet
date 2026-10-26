# TripWallet app

TripWallet is a Flutter app for shared trip expenses, itemized receipts, balances, settlements, and travel plans. The app uses Supabase Auth and PostgreSQL for shared data, with a per-account SQLite cache and a durable offline command queue on each device.

## Run the app

1. Install the Flutter SDK and an Android SDK with the licenses accepted.
2. For a new Supabase project, apply `../supabase/migrations/*.sql` **in filename order**. The configured TripWallet project was migrated on 2026-10-08. The old root `supabase_schema.sql` is deprecated. Migration 1 creates tables, migration 2 secures access and adds atomic sync RPCs, and migration 3 implements account deletion.
3. For a new project, enable email sign-in and allow `tripwallet://auth-callback` as an Auth redirect URL. The configured TripWallet project already has email sign-in, email confirmation, the redirect allowlist, and the matching Site URL set.
4. Run `flutter pub get` and `flutter run` from this directory. The checked-in public project URL and anon key in `lib/core/config/supabase_config.dart` can be overridden using `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`. Never pass a service-role key to the app.

The configured hosted project has all three migrations recorded. A new or overridden Supabase project still needs them before creating or joining trips.

## Verify changes

Run `flutter analyze` and `flutter test`. The tests cover exact money splitting, receipt parsing, widget flows, and local command retry. To verify PostgreSQL authorization and command validation, create a local PostgreSQL database, run `supabase/tests/bootstrap.sql` followed by the migrations, then run `supabase/tests/security.sql` with `psql -v ON_ERROR_STOP=1`. The bootstrap script is only a local Supabase Auth stub; do not run it on Supabase.

For an Android test package, run `flutter build apk --debug`. Release signing, store listing, hosted privacy and account-deletion URLs, and device testing are separate release tasks. The Android release build must use a private upload key before making an App Bundle.

## Data and payments

Receipt capture uses bundled PaddleOCR PP-OCRv6 tiny on Android (Android 8.0+) and on-device ML Kit on iOS. The app extracts likely line items but always shows an editable review before saving; photos are not uploaded. Equal, exact, percentage, and itemized shares are saved as integer minor units. The server verifies that expense splits add up and rejects a settlement larger than the current outstanding balance. UPI opens an installed payment app using the payee's saved UPI ID; TripWallet records a settlement only after the payer confirms the payment. It cannot verify the result of an external payment app.

Offline expense and itinerary edits appear locally and queue for retry. Trip creation and joining need a connection. Sync status shows queued changes and failures. Account deletion keeps shared financial history under an anonymized member name so other members' balances remain accurate.

## UI refresh (1.1.0)

The refreshed app uses a forest and lime palette, an illustrated welcome screen, direct create/join actions, trip cards with member and spending summaries, and a prominent expense/balance overview. Shared controls, sheets, and expense rows use the same spacing and typography. UI tests cover narrow welcome layouts and trip navigation at 150% text size.

Run `flutter test --dart-define=UI_PREVIEWS=true test/ui_layout_test.dart` to generate welcome, trips, and expense screen previews in `build/ui-previews/`.

The delivered `build/deliverables/TripWallet-1.1.0.apk` is a release-mode APK for direct installation, signed with this workstation’s existing Android development certificate so it can update earlier locally signed builds. It is not signed for Play Store publication. Release minification rules exclude warnings only for the receipt plugin’s optional language recognizers; receipt scanning continues to use its bundled Latin recognizer. Camera, UPI handoff, and authenticated multi-device sync still require hands-on device verification.

## Signup email OTP (1.2.0)

Signup OTP is enabled by default. On 2026-10-12, Brevo SMTP and the six-digit confirmation email template were applied to the hosted project. Codes expire after ten minutes. Verification and resend are performed by Supabase; codes are never checked locally. Successful verification signs the user in. See [`../supabase/OTP_SETUP.md`](../supabase/OTP_SETUP.md) for configuration and verification status.

The direct-install APK is `build/deliverables/TripWallet-1.2.5.apk`, signed with the existing Android development certificate. Live inbox delivery and phone signup still need verification.

Version 1.2.1 detects Supabase’s obfuscated response for an already-confirmed signup email and directs the user to sign in instead of asking for a code that was not sent.

Version 1.2.2 adds an inline existing-email error on signup submission and a direct Sign in action that preserves the email and intended destination. Seven focused OTP tests passed.

## Automatic remainder sharing (1.2.3)

In Add expense → Exact, entered amounts stay fixed and the remaining amount is shared equally among selected members marked Auto. Clearing an entered amount returns it to automatic calculation. Changing the bill amount or selected members recalculates the split. Zero is a valid fixed share. Shares exceeding the total, or fully entered shares that do not match the total, block saving. Calculations and saved amounts use integer minor units, with stable rounding so every cent or paisa is accounted for.

## Join by QR code (1.2.4)

Join a trip now offers Scan QR code alongside the existing code/link field. The camera reads the `tripwallet://join?code=...` QR codes shown on Invite friends, closes the scanner, and joins via the existing authenticated invite RPC. Duplicate detections are ignored. Unrelated QR links are rejected. Camera denial provides retry/manual-entry guidance; cancellation preserves the typed invite. Manual codes keep the existing preview-then-join flow. Scanning runs on the device with bundled ML Kit on Android; joining still requires a working backend connection.

Five focused tests cover QR parsing, duplicate scans and camera cleanup, invalid QR content, manual-entry fallback, denied permission, and a failed join request.

## Activity grouped by trip (1.2.5)

For multiple trips, Activity shows separate named sections with an update count and newest-first expenses/payments inside each section. Trips without activity have their own empty state. Single-trip accounts keep the original flat activity feed. This uses existing trip IDs on stored expenses and settlements; no database migration is required.

## Android PaddleOCR receipt scanning (1.2.6)

Android receipt photos are read locally using PP-OCRv6 tiny detection and recognition
models, ONNX Runtime, and OpenCV. Both models and their character dictionaries are
bundled in the app; scanning needs no API key, model download, or network request.
iOS retains ML Kit. The QR scanner is separate from receipt text recognition.

The native bridge applies EXIF orientation, bounds image size, runs one scan at a
time off the UI thread, and releases model sessions after each scan. Detected text
boxes are reconstructed into rows before receipt parsing. Users still review item
prices, taxes, and charges before choosing who shares each item. Discounts need
manual review; changing OCR does not make the receipt parser infallible.

The vendored SDK source, license, and pinned upstream revision are in
`android/ppocr-sdk/`. Model origins and SHA-256 hashes are in
`android/ppocr-sdk/models.lock.json`; run `python3 tool/verify_receipt_models.py` to
verify bundled files. Android's minimum SDK is now 26.

Run `flutter test test/receipt_text_recognizer_test.dart test/receipt_scanning_test.dart`
for the Dart bridge and parsing tests. With an Android emulator/device connected,
run `./gradlew :ppocr-sdk:connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.paddle.ocr.ReceiptSmokeTest`
from `android/` to test the real models on a generated receipt and blank image.

Validation on 2026-10-13: 13 focused Flutter tests and targeted Dart analysis passed.
The real-model `ReceiptSmokeTest` passed on a connected OnePlus GM1911 and an Android
15 x86_64 emulator, checking a generated receipt and a blank image. This verifies
model execution, not accuracy on arbitrary photographed receipts. Both universal
and ARM64 debug APKs built successfully. The ARM64 test build is
`build/deliverables/TripWallet-1.2.6-PaddleOCR-arm64-debug.apk` (base build number 13;
Flutter assigns version code 2013 to the ARM64 split). It was installed successfully
as an update on the connected OnePlus; existing app data was retained.

## Receipt columns, tax visibility and former members (1.2.7)

Receipt rows with quantity/rate/tax columns now separate the description from those
values. Review displays the scanned quantity, unit price and tax percentage as
reference metadata; line totals remain editable. Review, item sharing and split
confirmation display the subtotal, tax breakdown, round-off and complete bill total.
A detected printed-total mismatch blocks continuing until corrected.

Positive round-off lines are stored as explicitly named adjustment line items for
compatibility with the existing backend. They are excluded from the tax weighting
and shared equally among the people claiming regular items. The backend therefore
still receives line items plus tax/service equal to the saved expense total.
Negative round-off/discount extraction is not automatic; review a resulting total
mismatch and correct the bill before saving.

The backend currently anonymizes deleted members with the reserved display name
`Deleted account`. These members remain in history and balances, but receipt and
manual expense pickers exclude them, and the local repository rejects new expense
shares involving them. No historical membership or expense rows are deleted.

Verified with actual photo OCR on the OnePlus GM1911: items 955.00, CGST 85.95,
SGST 85.95, round-off 0.10, grand total 1127.00 INR. The regression fixture keeps
only OCR text/coordinates for the table; the photograph and personal header data
are not bundled. 21 focused tests passed across the receipt, sharing and sync tests,
including saved tax/round-off and deleted-participant rejection. The ARM64 debug
build is `build/deliverables/TripWallet-1.2.7-ReceiptFix-arm64-debug.apk` (2014).

## Online settlement card (1.2.8)

Settle a balance using Cash or Online. INR online settlements accept the recipient's
UPI ID and offer Google Pay, PhonePe, Paytm, or the Android UPI chooser. Review the
recipient, trip and amount before opening an external app. Manually entered IDs
apply only to this payment; they do not overwrite a member's profile.

No paid API, bank-name lookup, payment SDK, PIN collection or Autopay mandate is
used. Address validation checks syntax only. The Android channel restricts the
URI shape and named packages; opening or returning from a payment app never
records a settlement. Users explicitly confirm a payment in the existing dialog,
and the repository retains its payer/membership checks. The record is user-reported,
not bank-verified. Copy-ID and copy-amount actions support manual payments if an
app is unavailable or rejects personal-account intents. Non-INR payments are
recorded manually after paying externally.

Validation: focused payment tests and Flutter analysis. Live transfers through
the three named payment apps remain unverified; none was installed on the test
phone. APK: `build/deliverables/TripWallet-1.2.8.apk` (2015, ARM64, direct-install
development certificate). Visual sample: `build/deliverables/payment-preview.png`.
