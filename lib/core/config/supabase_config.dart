class SupabaseConfig {
  // Supabase project credentials
  static const String supabaseUrl = 'https://kzxyynbgebhsnfehccdo.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6eHl5bmJnZWJoc25mZWhjY2RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYxOTYxMjksImV4cCI6MjA3MTc3MjEyOX0.y29kqWI5FAV2bXwfqM5XxMG6eKQ80ceUlMQRG1Xj2y4';

  // Redirect URLs for authentication
  static const String redirectUrl =
      'https://cscarpine-bit.github.io/summer-walker-artist-portal/email_verification.html';

  // You can also use environment variables for production
  // static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
