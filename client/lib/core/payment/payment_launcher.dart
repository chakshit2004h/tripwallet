import 'package:flutter/services.dart';
import '../domain/money.dart';

enum UpiApp {
  googlePay('Google Pay', 'com.google.android.apps.nbu.paisa.user'),
  phonePe('PhonePe', 'com.phonepe.app'),
  paytm('Paytm', 'net.one97.paytm'),
  other('Other UPI app', null);

  const UpiApp(this.label, this.packageName);
  final String label;
  final String? packageName;
}

class PaymentLauncher {
  static const _channel = MethodChannel('tripwallet/payments');

  // Checks the address format only; bank ownership is checked in the UPI app.
  static bool validVpa(String value) =>
      RegExp(r'^[A-Za-z0-9._-]{2,256}@[A-Za-z0-9.-]{2,64}$').hasMatch(value);

  static String buildUpiUri({
    required String payeeVpa,
    required String payeeName,
    required int amountMinor,
    String? note,
  }) {
    if (!validVpa(payeeVpa) || amountMinor <= 0) {
      throw const FormatException(
        'A valid payment address and amount are required.',
      );
    }
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': payeeVpa,
        'pn': payeeName,
        'am': decimalAmount(amountMinor, 'INR'),
        'cu': 'INR',
        'tn': note ?? 'TripWallet settlement',
      },
    ).toString();
  }

  /// Reports only whether Android opened an app, never payment success.
  static Future<bool> launchPayment(String uri, {required UpiApp app}) async {
    try {
      return await _channel.invokeMethod<bool>('openUpi', {
            'uri': uri,
            'package': app.packageName,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
