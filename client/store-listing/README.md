# TripWallet — Play Store phone screenshots

Five 1080 × 1920 portrait PNGs, RGB (no alpha), ordered 01–05.
Upload the PNG files in screenshots/ to the phone screenshots section of Play Console.

1. Trips — Less tracking. More travelling.
2. Expenses — Every expense. One shared view.
3. Splitting — Your share, sorted.
4. Balances — Know who owes whom.
5. Activity — Every trip has its own story.

Screens are rendered from the existing TripWallet Flutter widgets with isolated, fictional
trip/member/expense fixtures. No production data, account changes, network requests, or
payment claims are used. The splitting image shows the form scrolled to its real split controls.

Official screenshot guidance checked:
https://support.google.com/googleplay/android-developer/answer/9866151

Regenerate from client/: flutter test --no-pub store-listing/render_screenshots_test.dart
The renderer outputs opaque RGBA PNGs; convert them to RGB before uploading.
