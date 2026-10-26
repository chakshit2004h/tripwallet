/// Parse an invite without opening any URL supplied by a QR code.
String? inviteCodeFromInput(String input, {bool scanned = false}) {
  final value = input.trim();
  final codePattern = RegExp(r'^[A-Z0-9]{6,8}$');
  if (codePattern.hasMatch(value.toUpperCase())) return value.toUpperCase();
  try {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (scanned &&
        (uri.scheme != 'tripwallet' ||
            uri.host != 'join' ||
            (uri.path.isNotEmpty && uri.path != '/'))) {
      return null;
    }
    final code =
        (uri.queryParameters['code'] ?? uri.pathSegments.lastOrNull ?? '')
            .trim()
            .toUpperCase();
    return codePattern.hasMatch(code) ? code : null;
  } on FormatException {
    return null;
  }
}
