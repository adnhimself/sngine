import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/messages/screens/messages_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/webview/screens/webview_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.location == '/login' || state.location == '/register';
      final isSplash = state.location == '/splash';
      
      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isLoggingIn && !isSplash) {
        return '/login';
      }
      
      // If logged in and on auth pages, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes (Native Flutter)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile/:username',
            builder: (context, state) => ProfileScreen(
              username: state.pathParameters['username']!,
            ),
          ),
          GoRoute(
            path: 'messages',
            builder: (context, state) => const MessagesScreen(),
            routes: [
              GoRoute(
                path: ':conversationId',
                builder: (context, state) => MessagesScreen(
                  conversationId: int.tryParse(state.pathParameters['conversationId']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
      
      // WebView Routes (Complex Sngine pages)
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'];
          final title = state.uri.queryParameters['title'] ?? 'Sngine';
          
          return WebViewScreen(
            url: url ?? AppConfig.webBaseUrl,
            title: title,
          );
        },
      ),
      
      // Specific WebView Routes
      ...AppConfig.webViewRoutes.map(
        (route) => GoRoute(
          path: route,
          builder: (context, state) => WebViewScreen(
            url: '${AppConfig.webBaseUrl}$route',
            title: _getPageTitle(route),
          ),
        ),
      ),
    ],
  );
});

String _getPageTitle(String route) {
  switch (route) {
    case '/admin':
      return 'Admin Panel';
    case '/settings':
      return 'Settings';
    case '/wallet':
      return 'Wallet';
    case '/packages':
      return 'Packages';
    case '/market':
      return 'Marketplace';
    case '/jobs':
      return 'Jobs';
    case '/offers':
      return 'Offers';
    case '/developers':
      return 'Developers';
    case '/courses':
      return 'Courses';
    case '/movies':
      return 'Movies';
    case '/games':
      return 'Games';
    case '/forums':
      return 'Forums';
    case '/funding':
      return 'Funding';
    case '/ads':
      return 'Ads';
    default:
      return 'Sngine';
  }
}