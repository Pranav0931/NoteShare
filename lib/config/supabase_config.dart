/// Supabase project configuration.
///
/// How to set up:
/// 1. Create a project at https://supabase.com
/// 2. Go to Project Settings → API
/// 3. Pass your Project URL and anon/public key with --dart-define
/// 4. Run supabase/schema.sql in the SQL Editor
/// 5. Create a storage bucket called "notes-files" (public)
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Returns true if real credentials have been set.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
