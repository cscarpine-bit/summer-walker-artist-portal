import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        },
        emailRedirectTo: SupabaseConfig.redirectUrl,
      );
      
      // Create user profile in profiles table
      if (response.user != null) {
        try {
          await _supabase.from('profiles').insert({
            'id': response.user!.id,
            'full_name': fullName,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // Profile creation failed, but user was created
          print('Profile creation failed: $e');
        }
      }
      
      return response;
    } catch (e) {
      if (e.toString().contains('over_email_send_rate_limit')) {
        throw Exception('Please wait a moment before trying again. Check your email for verification.');
      }
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e.toString().contains('Email not confirmed')) {
        throw Exception('Please check your email and click the verification link before signing in.');
      }
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: SupabaseConfig.redirectUrl,
      );
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      await _supabase.from('profiles').update({
        'full_name': fullName,
        'bio': bio,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;
      
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Check if user needs email verification
  bool get needsEmailVerification {
    final user = currentUser;
    return user != null && user.emailConfirmedAt == null;
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: currentUser?.email ?? '',
        emailRedirectTo: SupabaseConfig.redirectUrl,
      );
    } catch (e) {
      throw Exception('Failed to resend verification email: $e');
    }
  }

  // Handle localhost redirect issue (temporary workaround)
  Future<void> handleLocalhostRedirect() async {
    try {
      // This is a temporary workaround until Supabase settings are updated
      // In a real app, you'd handle this differently
      print('⚠️ WARNING: Email verification is redirecting to localhost:3000');
      print('⚠️ Please update Supabase project settings to fix this permanently');
      print('⚠️ Go to: Authentication → URL Configuration');
      print('⚠️ Set Site URL to: https://cscarpine-bit.github.io/summer-walker-artist-portal/');
      print('⚠️ Add Redirect URL: https://cscarpine-bit.github.io/summer-walker-artist-portal/email_verification.html');
    } catch (e) {
      print('Error in localhost redirect handler: $e');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
