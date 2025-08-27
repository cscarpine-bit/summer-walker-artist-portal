import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Check if current user is an artist
  bool get isArtist => currentUser?.userMetadata?['is_artist'] == true;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
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
            'username': username,
            'email': email,
            'bio': null,
            'avatar_url': null,
            'is_artist': false,
            'artist_verified': false,
            'social_links': '{}',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('✅ Profile created successfully for new user: ${response.user!.id}');
        } catch (e) {
          // Profile creation failed, but user was created
          print('❌ Profile creation failed: $e');
          // Try to create profile later when they first access it
        }
      }

      return response;
    } catch (e) {
      if (e.toString().contains('over_email_send_rate_limit')) {
        throw Exception(
            'Please wait a moment before trying again. Check your email for verification.');
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
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Force a refresh of the auth state
      await _supabase.auth.refreshSession();

      // Ensure profile exists after successful sign in
      if (response.user != null) {
        // This will create a profile if it doesn't exist
        await _ensureProfileExists();
      }

      return response;
    } catch (e) {
      if (e.toString().contains('Email not confirmed')) {
        throw Exception(
            'Please check your email and click the verification link before signing in.');
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
    String? username,
    String? bio,
    String? avatarUrl,
    Map<String, String>? socialLinks,
  }) async {
    try {
      await _supabase.from('profiles').update({
        'full_name': fullName,
        'username': username,
        'bio': bio,
        'avatar_url': avatarUrl,
        'social_links': socialLinks,
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

      // First, try to get the existing profile
      try {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', currentUser!.id)
            .single();
        return response;
      } catch (e) {
        // Profile doesn't exist, create one automatically
        print('Profile not found, creating one automatically for user: ${currentUser!.id}');
        await _ensureProfileExists();
        
        // Now try to get the profile again
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', currentUser!.id)
            .single();
        return response;
      }
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Ensure user profile exists, create if missing
  Future<void> _ensureProfileExists() async {
    try {
      if (currentUser == null) return;

      // Check if profile already exists
      final existingProfile = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', currentUser!.id)
          .maybeSingle();

      if (existingProfile == null) {
        // Create profile with default values
        await _supabase.from('profiles').insert({
          'id': currentUser!.id,
          'full_name': currentUser!.userMetadata?['full_name'] ?? currentUser!.email?.split('@')[0] ?? 'User',
          'email': currentUser!.email ?? '',
          'username': currentUser!.userMetadata?['username'] ?? currentUser!.email?.split('@')[0] ?? 'user',
          'bio': null,
          'avatar_url': null,
          'is_artist': false,
          'artist_verified': false,
          'social_links': '{}',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ Created missing profile for user: ${currentUser!.id}');
      }
    } catch (e) {
      print('❌ Failed to ensure profile exists: $e');
      // Don't throw here, just log the error
    }
  }

  // Get artist stats
  Future<Map<String, dynamic>?> getArtistStats() async {
    try {
      if (currentUser == null || !isArtist) return null;

      final response = await _supabase
          .from('artist_stats')
          .select()
          .eq('artist_id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get artist stats: $e');
    }
  }

  // Update artist stats
  Future<void> updateArtistStats({
    int? totalFollowers,
    int? totalLikes,
    int? totalViews,
    double? totalRevenue,
  }) async {
    try {
      if (currentUser == null || !isArtist) {
        throw Exception('User is not an artist');
      }

      final updates = <String, dynamic>{
        'last_updated': DateTime.now().toIso8601String(),
      };

      if (totalFollowers != null) updates['total_followers'] = totalFollowers;
      if (totalLikes != null) updates['total_likes'] = totalLikes;
      if (totalViews != null) updates['total_views'] = totalViews;
      if (totalRevenue != null) updates['total_revenue'] = totalRevenue;

      await _supabase
          .from('artist_stats')
          .update(updates)
          .eq('artist_id', currentUser!.id);
    } catch (e) {
      throw Exception('Failed to update artist stats: $e');
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      return response == null; // Username is available if no result found
    } catch (e) {
      throw Exception('Failed to check username availability: $e');
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
      print(
          '⚠️ Please update Supabase project settings to fix this permanently');
      print('⚠️ Go to: Authentication → URL Configuration');
      print(
          '⚠️ Set Site URL to: https://cscarpine-bit.github.io/summer-walker-artist-portal/');
      print(
          '⚠️ Add Redirect URL: https://cscarpine-bit.github.io/summer-walker-artist-portal/email_verification.html');
    } catch (e) {
      print('Error in localhost redirect handler: $e');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
