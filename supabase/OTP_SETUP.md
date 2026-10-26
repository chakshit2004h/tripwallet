# Signup email OTP

## Deployment status — 2026-10-12

Brevo SMTP authentication succeeded over TLS. Supabase accepted the SMTP configuration and confirmation template. A subsequent config comparison reported no declared changes.

- Sender: TripWallet <chakshitguleria2004@gmail.com>
- SMTP: smtp-relay.brevo.com, port 587
- Confirmation code: six digits, ten-minute expiry
- Resend cooldown: 60 seconds
- Successful verification creates the authenticated session.

Credentials are stored only in ignored `supabase/.env.local` (mode 0600) and the hosted Supabase settings. Never embed them in Flutter or commit them. Config uses SMTP_HOST, SMTP_USER, SMTP_PASS, SMTP_ADMIN_EMAIL, and SMTP_SENDER_NAME environment variables; load those variables before running Supabase config commands.

The earlier default-provider restriction was resolved by configuring custom SMTP. Live inbox delivery and end-to-end signup on the phone have not yet been verified. No Android device was connected during activation.

## App and checks

OTP is enabled by default; EMAIL_SIGNUP_OTP can override it for other projects. The release APK is `client/build/deliverables/TripWallet-1.2.0.apk`. It uses the existing development certificate for direct installation, not Play Store publication.

The existing 34-test suite passed during implementation. `flutter test test/signup_otp_test.dart` covers verification/session handling, resend request type, invalid-code error styling, cooldown, signup navigation, and registration form preservation. Mocked tests do not establish live email delivery.

To check delivery, create an account in the APK with an inbox you control, enter the latest emailed code, and confirm that the trips screen opens. Also check spam if the message is missing.

## Existing-account signup fix — 1.2.1

The reported address was already email-confirmed on 2026-10-10. Supabase does not send another signup confirmation for an already-confirmed user. Its obfuscated signup response can contain an empty identities list; the app now detects this response and displays a red sign-in/password-reset message instead of opening OTP verification. Existing accounts and their data were preserved.

Brevo TLS authentication and SMTP envelope checks succeeded. These checks do not establish live delivery to a new account. The APK for this fix is `client/build/deliverables/TripWallet-1.2.1.apk`.

Version 1.2.2 displays the existing-email error beside the email field and switches the main action to Sign in, carrying the entered email and next destination into login. The availability check occurs on signup submission. Seven focused tests passed.
