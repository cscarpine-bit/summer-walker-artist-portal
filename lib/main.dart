import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/pages/login_page.dart';

import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'core/services/profile_provider.dart';
import 'features/profile/presentation/pages/profile_edit_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Supabase: $e');
    // Continue with app initialization even if Supabase fails
    // This will allow the app to show an error state
  }

  runApp(const SummerWalkerApp());
}

class SummerWalkerApp extends StatelessWidget {
  const SummerWalkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Summer Walker',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Handle connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Handle errors
        if (snapshot.hasError) {
          print('❌ Auth stream error: ${snapshot.error}');
          return const LoginPage(); // Fallback to login on error
        }

        final authState = snapshot.data;

        // Handle null auth state
        if (authState == null) {
          print('⚠️ Auth state is null, showing login page');
          return const LoginPage();
        }

        final user = authState.session?.user;

        if (user != null) {
          // User is signed in
          if (user.emailConfirmedAt != null) {
            // Email is confirmed, show main app
            print('✅ User authenticated: ${user.email}');
            return const MainScreen();
          } else {
            // Email not confirmed, show verification message
            print('⚠️ User email not confirmed: ${user.email}');
            return const EmailVerificationScreen();
          }
        }

        // No user, show login
        print('ℹ️ No user authenticated, showing login page');
        return const LoginPage();
      },
    );
  }
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor.withOpacity(0.3),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email verification icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Check Your Email',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'We\'ve sent a verification link to:',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    Supabase.instance.client.auth.currentUser?.email ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '📧 Click the verification link in your email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'After verification, you\'ll be automatically signed in',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await Supabase.instance.client.auth.resend(
                              type: OtpType.signup,
                              email: Supabase.instance.client.auth.currentUser
                                      ?.email ??
                                  '',
                              emailRedirectTo: SupabaseConfig.redirectUrl,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification email resent!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to resend: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Resend Email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.backgroundColor,
                  AppTheme.primaryColor.withOpacity(0.3),
                  AppTheme.backgroundColor,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Summer Walker Logo/Avatar
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Summer Walker Text
                const Text(
                  'Summer Walker',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Artist Portal',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.secondaryTextColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 60),

                // Loading indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LiveScreen(),
    const PostsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _screens[_currentIndex]),
        BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.secondaryTextColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv),
              label: 'Live',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Posts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF5D7FA3),
              Color(0xFF13B8B5),
              Color(0xFF5D7FA3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Image Section - Full screen width, no padding, rounded bottom
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height *
                    0.65, // Takes up most of the screen
                child: Stack(
                  children: [
                    // Hero Image - goes all the way to the top
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: Image.asset(
                          'assets/assets/images/herroimagesummerwaker.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Settings Icon - top right corner
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    // Summer Walker Logo Overlay
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/assets/images/Summer Walker Logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Listen To My Album Button
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add album listening functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Listen To My New Album',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Happening Now Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Happening Now',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Update Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Date
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '16 Feb',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Update Text
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Update on New Album',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Live',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Arrow Icon
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Upcoming Events Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'No upcoming events',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Latest Videos Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest Videos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'No videos available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Latest Music Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest Music',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'No music available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Merch Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Merch',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'No merch available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor.withOpacity(0.3),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Go Live'),
            backgroundColor: Colors.transparent,
            foregroundColor: AppTheme.primaryTextColor,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                color: AppTheme.primaryTextColor,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Live Preview Container
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam_off,
                          size: 80,
                          color: AppTheme.secondaryTextColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Camera Preview',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Connect your camera to start streaming',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Live Stream Controls
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Stream Title Input
                      TextField(
                        style:
                            const TextStyle(color: AppTheme.primaryTextColor),
                        decoration: InputDecoration(
                          hintText: 'Stream title...',
                          hintStyle: const TextStyle(
                              color: AppTheme.secondaryTextColor),
                          prefixIcon: const Icon(Icons.title,
                              color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stream Settings Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.people,
                                      color: AppTheme.primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    '0 viewers',
                                    style: TextStyle(
                                        color: AppTheme.primaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.timer,
                                      color: AppTheme.primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    '00:00',
                                    style: TextStyle(
                                        color: AppTheme.primaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Go Live Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.videocam, size: 28),
                          label: const Text(
                            'GO LIVE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor.withOpacity(0.3),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('My Posts'),
            backgroundColor: Colors.transparent,
            foregroundColor: AppTheme.primaryTextColor,
          ),
          body: const Center(
            child: Text(
              'Content Management\nComing Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.userProfile;
        final artistStats = profileProvider.artistStats;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.backgroundColor,
                  AppTheme.primaryColor.withOpacity(0.3),
                  AppTheme.backgroundColor,
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text('Profile'),
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.primaryTextColor,
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    color: AppTheme.primaryTextColor,
                  ),
                ],
              ),
              body: profileProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : profile == null
                      ? const Center(
                          child: Text(
                            'Failed to load profile',
                            style: TextStyle(color: AppTheme.primaryTextColor),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Profile Header
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.1),
                                      AppTheme.secondaryColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Profile Picture
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryColor,
                                            AppTheme.secondaryColor
                                          ],
                                        ),
                                      ),
                                      child: profile['avatar_url'] != null
                                          ? ClipOval(
                                              child: Image.network(
                                                profile['avatar_url'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(Icons.person,
                                                        color: Colors.white,
                                                        size: 40),
                                              ),
                                            )
                                          : const Icon(Icons.person,
                                              color: Colors.white, size: 40),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profile['full_name'] ??
                                                'Unknown User',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          if (profile['username'] != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '@${profile['username']}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                          if (profile['bio'] != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              profile['bio'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppTheme
                                                        .secondaryTextColor,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Artist Stats (if user is an artist)
                              if (profile['is_artist'] == true &&
                                  artistStats != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor.withOpacity(0.1),
                                        AppTheme.secondaryColor
                                            .withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Artist Statistics',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppTheme.primaryTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _StatItem(
                                            icon: Icons.people,
                                            value: profileProvider
                                                .formattedFollowers,
                                            label: 'Followers',
                                            color: AppTheme.primaryColor,
                                          ),
                                          _StatItem(
                                            icon: Icons.favorite,
                                            value:
                                                profileProvider.formattedLikes,
                                            label: 'Likes',
                                            color: Colors.red,
                                          ),
                                          _StatItem(
                                            icon: Icons.play_circle,
                                            value:
                                                profileProvider.formattedViews,
                                            label: 'Views',
                                            color: AppTheme.secondaryColor,
                                          ),
                                          _StatItem(
                                            icon: Icons.attach_money,
                                            value: profileProvider
                                                .formattedRevenue,
                                            label: 'Revenue',
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Quick Actions
                              Text(
                                'Quick Actions',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppTheme.primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),

                              // Admin Dashboard Button (only for artists)
                              if (profile['is_artist'] == true) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminDashboardPage(),
                                        ),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.admin_panel_settings),
                                    label: const Text('Admin Dashboard'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Other Profile Options
                              _ProfileOption(
                                icon: Icons.edit,
                                title: 'Edit Profile',
                                subtitle: 'Update your personal information',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileEditPage(),
                                    ),
                                  );
                                },
                              ),

                              _ProfileOption(
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle:
                                    'Manage your notification preferences',
                                onTap: () {},
                              ),

                              _ProfileOption(
                                icon: Icons.security,
                                title: 'Privacy & Security',
                                subtitle: 'Control your privacy settings',
                                onTap: () {},
                              ),

                              _ProfileOption(
                                icon: Icons.help,
                                title: 'Help & Support',
                                subtitle: 'Get help and contact support',
                                onTap: () {},
                              ),

                              const SizedBox(height: 24),

                              // Logout Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final authService =
                                        context.read<AuthService>();
                                    await authService.signOut();
                                    profileProvider.clearProfile();
                                    if (mounted) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Logout'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.secondaryTextColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
        ),
      ],
    );
  }
}
