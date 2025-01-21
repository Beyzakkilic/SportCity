import 'package:go_router/go_router.dart';
import 'package:sportcity/screens/login.dart';
import 'package:sportcity/screens/resetpassword.dart';
import 'package:sportcity/screens/settings.dart';
import '../screens/home.dart';
import '../screens/loading.dart';

// Router yapılandırması
final router = GoRouter(
  initialLocation: '/', // Başlangıç rotası
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: '/resetpassword',
      builder: (context, state) => const ResetScreen(),
    )
  ],
);
