# TripWallet production upload

## Signing

- Permanent application ID: `com.tripwallet.app`.
- Private RSA upload key: `~/.local/share/tripwallet-signing/upload-keystore.jks`.
- Local passwords/configuration: `client/android/key.properties` (Git ignored, owner access only).
- Backup archive: `~/.local/share/tripwallet-signing/TripWallet-upload-key-backup.zip`. This contains passwords: copy into encrypted offline storage; never upload it to Git, chat, or your website. The current copy is on the same computer and does not protect against disk loss.
- Public certificate: `~/.local/share/tripwallet-signing/upload-certificate.pem`.
- Release builds require the private signing configuration; no debug-signing fallback.
- Build from `client`: `flutter build appbundle --release --no-pub --build-name=1.2.9 --build-number=2016`. Increase the build number for every later Play upload.
- In Play Console, create TripWallet, enable Play App Signing (Google-generated app signing key), and upload the AAB to Internal testing first. Console access and enrollment are not done by this local build.
- The Google Play build will have a different signing identity from the previous directly installed debug APK. Do not uninstall the old APK until its local changes are synced or exported.

## Step 4: public pages to prepare

Create a public privacy page and a separate account-deletion page on free hosting (a paid domain is unnecessary). They must open without signing in.

Privacy content must identify TripWallet and its developer/support contact, describe email/authentication, names, optional UPI IDs, trips, participants, expenses, shares, settlements and itinerary. Explain Supabase synchronization and device caching; shared trip members can view shared records. Receipt recognition currently runs locally; original receipt photos are not uploaded by the reviewed code. Camera is also used for QR joining. Email verification uses an email service. External UPI apps process payments; TripWallet does not independently verify success. State retention/deletion and any actual service logging or backup retention after checking the providers. Do not invent a retention duration.

The deletion page must prominently offer a way to request deletion outside the app: for example, a monitored support email with instructions to send a request from the registered address. Include TripWallet in the page title, explain identity confirmation without requesting passwords or OTPs, state an achievable processing timeframe, and describe retained shared records. A privacy page alone does not replace this request page.

Current deletion implementation: Profile invokes `delete_my_account`; owned solo trips are deleted; shared trip ownership transfers; shared participant name becomes Deleted account and avatar/UPI are cleared; shared financial records retain participant identifiers; auth user is deleted. This is not a claim that all shared record content is anonymized. Existing expense notes or other shared text may still contain personal details. Verify deletion end to end before publishing these statements as policy.

You need to choose/confirm: public support email, developer name matching the store listing, realistic deletion turnaround, provider backup/log retention, and hosting account. Publish both URLs, then enter the privacy URL and deletion URL into Play Console App content/Data safety as appropriate.

## Remaining real-device / backend gates

- Actual new-user OTP delivery, login and password reset.
- Account deletion, retained records and revoked access using test accounts.
- Two-account trip creation/join by code and QR, expenses, balances and sync.
- Receipt recognition on Play-installed builds.
- Real UPI app handoff and cancellation; never treat opening an app as payment confirmation.
- Backend access-control tests against an isolated test database and unrelated trips.
- Play pre-launch report and a 16 KB device/emulator runtime test.

A signed bundle and automated tests do not establish that these live flows passed.

## Local verification — 14 October 2026

- Artifact: `client/build/deliverables/TripWallet-1.2.9-play.aab`, version 1.2.9 / 2016.
- Bundle size: 159.7 MB (upload size, not per-device download).
- 65 Flutter tests passed; Flutter analyze: no issues.
- Official bundletool 1.18.3 validation passed.
- jarsigner: jar verified (self-signed upload certificate; JDK also reports ZIP streaming/order warnings). Play upload validation remains required.
- 13 native libraries per ABI: arm64-v8a, armeabi-v7a, x86_64. All ARM64/x86_64 ELF LOAD segments aligned to at least 16 KB; bundle declares PAGE_ALIGNMENT_16K. Actual 16 KB runtime testing pending.
- Min SDK 26; target SDK 36.
- Merged permissions: INTERNET, ACCESS_NETWORK_STATE, CAMERA, and app-specific protected DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION.
- Upload key/configuration excluded from Git. Private backup created locally; off-device backup still required.
- Build warning: the local ppocr-sdk uses legacy Kotlin Gradle integration; current build succeeds, future Flutter migration is needed.
- SHA-256: `c8da2f8c91e1985ffa1390b2dd84251b8707907de447bb6be49fde57c4464134`.
- Bundletool successfully generated device APKs. Estimated compressed downloads: ARM64 41.87–41.90 MB; ARMv7 38.08–38.10 MB; x86_64 57.60–57.63 MB. Google Play may differ. Generated ARM64 split passes zipalign -P 16.
