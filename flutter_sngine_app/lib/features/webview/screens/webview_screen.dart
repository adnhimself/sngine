import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../auth/providers/auth_provider.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  final String url;
  final String title;
  final bool showAppBar;
  
  const WebViewScreen({
    Key? key,
    required this.url,
    required this.title,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _updateTitle();
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            
            // Handle navigation within the app
            if (_shouldHandleInternally(url)) {
              return NavigationDecision.navigate;
            }
            
            // Handle native Flutter routes
            if (_shouldOpenInFlutter(url)) {
              _handleFlutterNavigation(url);
              return NavigationDecision.prevent;
            }
            
            // Allow all other navigation in WebView
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      );

    // Inject authentication if user is logged in
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      _injectAuthSession();
    }

    _controller.loadRequest(Uri.parse(widget.url));
  }

  bool _shouldHandleInternally(String url) {
    // Keep all Sngine domain URLs in WebView
    return url.contains(AppConfig.baseUrl) || 
           url.startsWith(AppConfig.webBaseUrl) ||
           AppConfig.webViewRoutes.any((route) => url.contains(route));
  }

  bool _shouldOpenInFlutter(String url) {
    // Check if this URL should open in native Flutter
    return AppConfig.nativeRoutes.any((route) {
      if (route == '/') {
        return url == AppConfig.baseUrl || url == '${AppConfig.baseUrl}/';
      }
      return url.contains(route);
    });
  }

  void _handleFlutterNavigation(String url) {
    // Extract route from URL and navigate using GoRouter
    final uri = Uri.parse(url);
    final path = uri.path;
    
    if (path == '/' || path.isEmpty) {
      context.go('/');
    } else if (path.startsWith('/profile/')) {
      final username = path.split('/')[2];
      context.go('/profile/$username');
    } else if (path.contains('/messages')) {
      context.go('/messages');
    } else if (path.contains('/notifications')) {
      context.go('/notifications');
    }
    // Add more route handling as needed
  }

  void _handleJavaScriptMessage(String message) {
    // Handle messages from JavaScript
    try {
      // You can send commands from Sngine web to Flutter
      // Example: FlutterBridge.postMessage('{"action": "navigate", "route": "/profile/john"}')
      // Handle navigation, notifications, etc.
    } catch (e) {
      debugPrint('Error handling JS message: $e');
    }
  }

  void _injectAuthSession() {
    // Inject authentication session into WebView
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      final script = '''
        // Set authentication in localStorage or cookies
        localStorage.setItem('sngine_user_id', '${authState.user!.userId}');
        localStorage.setItem('sngine_access_token', '${authState.accessToken}');
        
        // You might need to set cookies depending on Sngine's auth system
        document.cookie = "user_id=${authState.user!.userId}; path=/";
        document.cookie = "access_token=${authState.accessToken}; path=/";
      ''';
      
      _controller.runJavaScript(script);
    }
  }

  void _updateTitle() {
    _controller.getTitle().then((title) {
      if (title != null && title.isNotEmpty) {
        setState(() {
          _currentTitle = title;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(_currentTitle.isNotEmpty ? _currentTitle : widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              await _controller.goBack();
            } else {
              if (context.mounted) {
                context.pop();
              }
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'home':
                  context.go('/');
                  break;
                case 'external':
                  // Open in external browser if needed
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'home',
                child: Text('Go to Home'),
              ),
              const PopupMenuItem(
                value: 'external',
                child: Text('Open in Browser'),
              ),
            ],
          ),
        ],
      ) : null,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}