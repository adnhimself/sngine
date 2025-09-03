class AppConfig {
  // App Configuration
  static const String appName = 'Sngine';
  static const String appVersion = '1.0.0';
  
  // Sngine Backend Configuration
  static const String baseUrl = 'https://your-sngine-domain.com'; // Replace with your domain
  static const String apiBaseUrl = '$baseUrl/includes/ajax';
  static const String webBaseUrl = baseUrl;
  
  // API Endpoints
  static const String loginEndpoint = '/users/signin.php';
  static const String registerEndpoint = '/users/signup.php';
  static const String profileEndpoint = '/users/profile.php';
  static const String postsEndpoint = '/posts/post.php';
  static const String chatEndpoint = '/chat/conversation.php';
  static const String notificationsEndpoint = '/core/notifications.php';
  
  // WebView Routes (Complex pages that use WebView)
  static const List<String> webViewRoutes = [
    '/admin',
    '/settings',
    '/wallet',
    '/packages',
    '/market',
    '/jobs',
    '/offers',
    '/developers',
    '/courses',
    '/movies',
    '/games',
    '/forums',
    '/funding',
    '/ads',
  ];
  
  // Native Routes (Implemented in Flutter)
  static const List<String> nativeRoutes = [
    '/',
    '/profile',
    '/messages',
    '/notifications',
    '/search',
    '/groups',
    '/events',
    '/live',
    '/reels',
  ];
  
  // App Settings
  static const int postsPerPage = 10;
  static const int messagesPerPage = 20;
  static const Duration cacheTimeout = Duration(minutes: 5);
  
  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableBiometricAuth = true;
}