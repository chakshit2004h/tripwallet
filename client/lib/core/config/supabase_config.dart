/// Configuration for Supabase backend.
/// Replace these values with your actual project URL and Anon Key from your Supabase dashboard (Settings -> API).
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key',
  );

  static bool get isConfigured =>
      !url.contains('xyzcompany.supabase.co') &&
      !anonKey.contains('dummy_anon_key');
}
