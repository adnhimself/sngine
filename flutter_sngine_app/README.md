# Sngine Flutter App

A modern Flutter mobile application for the Sngine social media platform.

## 🚀 Features

### Native Flutter Implementation
- **News Feed** - Fast, native scrolling with pull-to-refresh
- **User Profiles** - Native profile viewing and editing
- **Messaging** - Real-time chat with push notifications
- **Stories/Reels** - Instagram-like stories experience
- **Search** - Fast user and content search
- **Notifications** - Native notification handling

### WebView Integration
- **Admin Panel** - Full web admin experience
- **Settings** - Complex settings pages
- **Marketplace** - Product browsing and purchasing
- **Wallet** - Payment and transaction management
- **Jobs Board** - Job posting and applications
- **Courses** - Educational content
- **Live Streaming** - Video streaming features

## 🏗️ Architecture

### Hybrid Approach
This app uses a **hybrid architecture** combining the best of both worlds:

1. **Core Social Features** → Native Flutter for performance
2. **Complex Business Logic** → WebView for existing Sngine functionality
3. **Seamless Integration** → Smart routing between native and web

### State Management
- **Riverpod** for dependency injection and state management
- **Go Router** for navigation
- **Dio + Retrofit** for API communication

### Key Benefits
- ✅ **Fast Development** - Leverage existing Sngine backend
- ✅ **Native Performance** - Core features feel native
- ✅ **Easy Maintenance** - Web updates automatically available
- ✅ **Cost Effective** - No need to rebuild everything

## 🛠️ Setup Instructions

### Prerequisites
- Flutter 3.10+ installed
- Dart 3.0+
- Sngine backend running
- Firebase project (for push notifications)

### Installation

1. **Clone and Setup**
```bash
cd flutter_sngine_app
flutter pub get
```

2. **Configure Backend URL**
Edit `lib/core/config/app_config.dart`:
```dart
static const String baseUrl = 'https://your-sngine-domain.com';
```

3. **Generate Code**
```bash
flutter packages pub run build_runner build
```

4. **Run the App**
```bash
flutter run
```

## 📱 App Structure

```
lib/
├── core/
│   ├── config/           # App configuration
│   ├── models/           # Data models
│   ├── services/         # API services
│   ├── providers/        # Global providers
│   └── routing/          # App routing
├── features/
│   ├── auth/             # Authentication
│   ├── home/             # Main feed & navigation
│   ├── profile/          # User profiles
│   ├── messages/         # Chat & messaging
│   ├── notifications/    # Push notifications
│   ├── webview/          # WebView integration
│   └── splash/           # Splash screen
└── shared/
    ├── widgets/          # Reusable widgets
    └── utils/            # Utilities
```

## 🔧 Backend Integration

### API Endpoints Used
The app integrates with Sngine's existing AJAX endpoints:

- **Authentication**: `/includes/ajax/users/signin.php`
- **Posts**: `/includes/ajax/posts/post.php`
- **Messages**: `/includes/ajax/chat/conversation.php`
- **Notifications**: `/includes/ajax/core/notifications.php`
- **Profile**: `/includes/ajax/users/profile.php`

### Session Management
- Uses secure storage for tokens
- Automatically syncs with WebView sessions
- Handles token refresh and expiration

## 🌐 WebView Integration

### Smart Routing
The app automatically determines whether to:
- Open pages natively in Flutter
- Open complex pages in WebView
- Handle authentication across both

### WebView Features
- **Session Sync** - Shares authentication between native and web
- **JavaScript Bridge** - Communication between Flutter and web
- **Custom Navigation** - Smart back button handling
- **Performance** - Cached WebView instances

## 🔔 Push Notifications

### Firebase Integration
- Real-time notifications for messages, reactions, comments
- Background notification handling
- Deep linking to specific content

### Local Notifications
- Offline notification support
- Scheduled notifications
- Custom notification actions

## 🎨 UI/UX Design

### Design Principles
- **Material Design 3** with custom Sngine branding
- **Native Feel** - Platform-specific interactions
- **Consistent** - Unified design between native and web
- **Responsive** - Works on all screen sizes

### Key Components
- Custom post cards with media support
- Story/reels viewer
- Chat bubbles and message UI
- Profile layouts
- Navigation components

## 🚀 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Configuration
1. Update app icons and splash screens
2. Configure Firebase for push notifications
3. Set up deep linking
4. Configure app signing

## 🔒 Security

### Authentication
- Secure token storage using FlutterSecureStorage
- Session management with automatic refresh
- Biometric authentication support (optional)

### Data Protection
- HTTPS enforcement
- Input validation
- Secure API communication

## 📈 Performance

### Optimization Features
- **Image Caching** - Cached network images
- **Lazy Loading** - Posts loaded on demand
- **Memory Management** - Efficient list handling
- **WebView Caching** - Cached web pages

### Monitoring
- Performance metrics
- Crash reporting
- User analytics

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📋 TODO / Roadmap

- [ ] Implement offline mode
- [ ] Add biometric authentication
- [ ] Implement video calling
- [ ] Add AR filters for stories
- [ ] Implement push-to-talk messaging
- [ ] Add dark mode toggle
- [ ] Implement advanced search filters
- [ ] Add accessibility features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support with:
- **Flutter App**: Create an issue in this repository
- **Sngine Backend**: Visit [Sngine Documentation](https://sngine.com/docs)
- **API Integration**: Check the `/includes/ajax/` endpoints documentation

---

**Note**: This app requires a running Sngine backend. Make sure your Sngine installation is properly configured and accessible before running the Flutter app.