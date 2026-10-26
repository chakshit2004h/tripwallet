import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

String appError(Object error) {
  if (error is FormatException) return error.message;
  if (error is StateError) return error.message;
  if (error is SocketException ||
      error is TimeoutException ||
      error is ClientException ||
      error is AuthRetryableFetchException) {
    return 'Can’t reach TripWallet. Check your internet connection or try switching between Wi-Fi and mobile data, then retry.';
  }
  if (error is AuthException) {
    if (error.code == 'otp_expired') {
      return 'That code is incorrect or has expired. Check your latest email or request a new code.';
    }
    if (error.code == 'over_email_send_rate_limit' ||
        error.code == 'over_request_rate_limit') {
      return 'Too many attempts. Please wait a little before trying again.';
    }
    return error.message;
  }
  if (error is PostgrestException) {
    if (error.code == 'P0001') return error.message;
    if (error.code == 'PGRST202' || error.code == '42P01') {
      return 'The server needs the latest TripWallet database update. Please try again after it is deployed.';
    }
    if (error.code == '42501') {
      return 'You do not have permission to make this change.';
    }
  }
  return 'Could not complete this action. Please try again. Your saved changes are safe.';
}
