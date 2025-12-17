import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'services/supabase_service.dart';
import 'services/theme_service.dart';
import 'services/deep_link_service.dart';
import 'services/socket_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Supabase for avatar uploads
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  // Initialize Theme
  try {
    await ThemeService().init();
  } catch (e) {
    debugPrint('Theme initialization failed: $e');
  }

  runApp(const DiskusiBisnisApp());
}

class DiskusiBisnisApp extends StatefulWidget {
  const DiskusiBisnisApp({super.key});

  @override
  State<DiskusiBisnisApp> createState() => _DiskusiBisnisAppState();
}

class _DiskusiBisnisAppState extends State<DiskusiBisnisApp> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  final FCMService _fcmService = FCMService();
  final DeepLinkService _deepLinkService = DeepLinkService();
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _checkAuth();

      // Initialize FCM if user is authenticated
      if (_isAuthenticated) {
        await _fcmService.initialize();
        // Connect to WebSocket for real-time notifications
        await _socketService.connect();
      }

      // Initialize Deep Linking
      await _deepLinkService.initialize();

      // Listen for deep links
      _deepLinkService.deepLinkStream.listen(_handleDeepLink);
    } catch (e) {
      debugPrint('Initialization failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleDeepLink(Uri uri) {
    final parsed = _deepLinkService.parseDeepLink(uri);
    if (parsed != null) {
      debugPrint(
          'Navigating to: ${parsed['route']} with params: ${parsed['params']}');
      // Navigation will be handled by MainNavScreen when it receives the deep link
      // For now, just ensure the app opens to the main screen
    }
  }

  Future<void> _checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (mounted) {
        setState(() {
          _isAuthenticated = token != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Auth check failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAuthenticated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create Inter text theme with consistent inherit value
    final baseTextTheme = ThemeData.light().textTheme;
    final interTextTheme = GoogleFonts.interTextTheme(baseTextTheme);

    // Show splash screen while loading
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: interTextTheme,
        ),
        home: const _SimpleSplashScreen(),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'DiskusiBisnis',
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: false,
          showSemanticsDebugger: false,
          checkerboardRasterCacheImages: false,
          checkerboardOffscreenLayers: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFF059669),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF059669),
              primary: const Color(0xFF059669),
              surface: const Color(0xFFF8FAFC),
            ),
            textTheme: interTextTheme,
            primaryTextTheme: interTextTheme,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              titleTextStyle: GoogleFonts.inter(
                color: const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              elevation: 4,
            ),
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF059669),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF059669),
              primary: const Color(0xFF059669),
              surface: const Color(0xFF0F172A),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            primaryTextTheme:
                GoogleFonts.interTextTheme(ThemeData.dark().primaryTextTheme),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1E293B),
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF334155),
              contentTextStyle: TextStyle(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              elevation: 4,
            ),
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
          home:
              _isAuthenticated ? const MainNavScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}

/// Simple splash screen shown during initialization
class _SimpleSplashScreen extends StatelessWidget {
  const _SimpleSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
                Color(0xFF047857),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'DB',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
