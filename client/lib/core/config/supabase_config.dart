/// Configuration for Supabase backend.
/// Live project credentials for TripWallet.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pqbghlcaxkacawhhxbvw.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxYmdobGNheGthY2F3aGh4YnZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEwODcwNzcsImV4cCI6MjEwNjY2MzA3N30.yaqLs_7Tl_rtWk37ZD0XG9BB7rP3f_PN6O7gK36DF84',
  );

  static bool get isConfigured =>
      !url.contains('xyzcompany.supabase.co') &&
      !anonKey.contains('dummy_anon_key');
}
