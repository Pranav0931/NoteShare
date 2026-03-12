/// Supabase project configuration.
///
/// How to set up:
/// 1. Create a project at https://supabase.com
/// 2. Go to Project Settings → API
/// 3. Copy your Project URL and anon/public key below
/// 4. Run supabase/schema.sql in the SQL Editor
/// 5. Create a storage bucket called "notes-files" (public)
class SupabaseConfig {
  static const String url = 'https://hbawgvzcicvywgjsjhwx.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhiYXdndnpjaWN2eXdnanNqaHd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzMzE1MTEsImV4cCI6MjA4ODkwNzUxMX0.vcx6U9NSDzIBAYliB1CTNnzbtmTvoilkd1Ji56oetbk';

  /// Returns true if real credentials have been set.
  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' && anonKey != 'YOUR_SUPABASE_ANON_KEY';
}
