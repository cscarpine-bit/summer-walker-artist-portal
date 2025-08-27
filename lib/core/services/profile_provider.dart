import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _artistStats;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get userProfile => _userProfile;
  Map<String, dynamic>? get artistStats => _artistStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isArtist => _authService.isArtist;

  // Load user profile
  Future<void> loadUserProfile() async {
    if (!_authService.isAuthenticated) return;

    _setLoading(true);
    _clearError();

    try {
      _userProfile = await _authService.getUserProfile();

      // If user is an artist, also load artist stats
      if (isArtist) {
        _artistStats = await _authService.getArtistStats();
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    Map<String, String>? socialLinks,
  }) async {
    if (!_authService.isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(
        fullName: fullName,
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
        socialLinks: socialLinks,
      );

      // Reload profile to get updated data
      await loadUserProfile();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update artist stats
  Future<bool> updateArtistStats({
    int? totalFollowers,
    int? totalLikes,
    int? totalViews,
    double? totalRevenue,
  }) async {
    if (!_authService.isAuthenticated || !isArtist) return false;

    _setLoading(true);
    _clearError();

    try {
      await _authService.updateArtistStats(
        totalFollowers: totalFollowers,
        totalLikes: totalLikes,
        totalViews: totalViews,
        totalRevenue: totalRevenue,
      );

      // Reload artist stats
      _artistStats = await _authService.getArtistStats();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check username availability
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      return await _authService.isUsernameAvailable(username);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Refresh profile data
  Future<void> refresh() async {
    await loadUserProfile();
  }

  // Clear profile data (useful for logout)
  void clearProfile() {
    _userProfile = null;
    _artistStats = null;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Get user's display name
  String get displayName {
    if (_userProfile != null) {
      return _userProfile!['username'] ??
          _userProfile!['full_name'] ??
          'Unknown User';
    }
    return 'Unknown User';
  }

  // Get user's avatar URL
  String? get avatarUrl {
    return _userProfile?['avatar_url'];
  }

  // Get user's bio
  String? get bio {
    return _userProfile?['bio'];
  }

  // Get social links
  Map<String, dynamic>? get socialLinks {
    return _userProfile?['social_links'];
  }

  // Get formatted follower count
  String get formattedFollowers {
    if (_artistStats == null) return '0';
    final count = _artistStats!['total_followers'] ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  // Get formatted like count
  String get formattedLikes {
    if (_artistStats == null) return '0';
    final count = _artistStats!['total_likes'] ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  // Get formatted view count
  String get formattedViews {
    if (_artistStats == null) return '0';
    final count = _artistStats!['total_views'] ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  // Get formatted revenue
  String get formattedRevenue {
    if (_artistStats == null) return '\$0';
    final revenue = _artistStats!['total_revenue'] ?? 0.0;
    if (revenue >= 1000000) {
      return '\$${(revenue / 1000000).toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return '\$${(revenue / 1000).toStringAsFixed(1)}K';
    }
    return '\$${revenue.toStringAsFixed(0)}';
  }
}
