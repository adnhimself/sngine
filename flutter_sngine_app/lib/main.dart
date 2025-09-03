import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase Messaging
  await FirebaseMessaging.instance.requestPermission();
  
  // Initialize Local Notifications
  await NotificationService.initialize();
  
  runApp(
    ProviderScope(
      child: SngineApp(),
    ),
  );
}

class SngineApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}