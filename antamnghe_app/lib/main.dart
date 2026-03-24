import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/spam_detail_screen.dart';
import 'services/auth_service.dart';
import 'services/config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/protection_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/vip_list_screen.dart';
import 'screens/blocked_screen.dart';
import 'screens/history_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/privacy_center_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Choose base URL depending on platform. For Flutter Web use localhost,
  // for mobile/emulator use 10.0.2.2 by default. Override with
  // --dart-define=API_BASE_URL=... when needed.
  const envBase = String.fromEnvironment('API_BASE_URL');
  if (envBase.isNotEmpty) {
    ServiceConfig.baseUrl = envBase;
  } else {
    ServiceConfig.baseUrl = kIsWeb
        ? 'http://localhost:5195'
        : 'http://10.0.2.2:5195';
  }
  final user = await AuthService.instance.currentUser();
  final initial = (user == null) ? '/login' : '/profile';
  runApp(MyApp(initialRoute: initial));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = '/login'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntamNghe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/protection': (_) => const ProtectionScreen(),
        '/premium': (_) => const PremiumScreen(),
        '/spam_detail': (_) => const SpamDetailScreen(),
        '/vip-list': (_) => const VipListScreen(),
        '/blocked': (_) => const BlockedScreen(),
        '/history': (_) => const HistoryScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/emergency': (_) => const EmergencyScreen(),
        '/privacy-center': (_) => const PrivacyCenterScreen(),
      },
    );
  }
}
