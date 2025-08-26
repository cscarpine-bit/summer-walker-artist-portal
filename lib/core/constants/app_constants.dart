class AppConstants {
  // App Info
  static const String appName = 'Summer Walker';
  static const String appVersion = '1.0.0';
  
  // Padding & Spacing
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  // Border Radius
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache Settings
  static const Duration cacheTimeout = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
