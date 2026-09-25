import 'package:url_launcher/url_launcher.dart';

class PaymentLauncher {
  /// Generates a standardized UPI Intent URI for Google Pay, PhonePe, Paytm, etc.
  static String buildUpiUri({
    required String payeeVpa,
    required String payeeName,
    required int amountMinor,
    String? note,
  }) {
    final amountMajor = (amountMinor / 100).toStringAsFixed(2);
    final cleanNote = Uri.encodeComponent(note ?? 'TripWallet Settlement');
    final cleanName = Uri.encodeComponent(payeeName);
    return 'upi://pay?pa=$payeeVpa&pn=$cleanName&am=$amountMajor&cu=INR&tn=$cleanNote';
  }

  /// Generates a Revolut.me payment link.
  static String buildRevolutUri({
    required String username,
    required int amountMinor,
    String currency = 'EUR',
  }) {
    final amountMajor = (amountMinor / 100).toStringAsFixed(2);
    return 'https://revolut.me/$username?amount=$amountMajor&currency=$currency';
  }

  /// Attempts to launch the payment intent URL natively.
  /// Returns false if no handler is installed (e.g. on Linux desktop/emulator).
  static Future<bool> launchPayment(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
