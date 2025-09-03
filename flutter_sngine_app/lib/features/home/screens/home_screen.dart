import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/newsfeed_tab.dart';
import '../widgets/explore_tab.dart';
import '../widgets/notifications_tab.dart';
import '../widgets/profile_tab.dart';
import '../../webview/screens/webview_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _tabs = [
    const NewsfeedTab(),
    const ExploreTab(),
    const NotificationsTab(),
    const ProfileTab(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sngine'),
        elevation: 0,
        actions: [
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search or navigate to search page
              showSearch(
                context: context,
                delegate: SngineSearchDelegate(),
              );
            },
          ),
          
          // More options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  context.go('/settings');
                  break;
                case 'wallet':
                  context.go('/wallet');
                  break;
                case 'market':
                  context.go('/market');
                  break;
                case 'jobs':
                  context.go('/jobs');
                  break;
                case 'admin':
                  context.go('/admin');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'wallet', child: Text('Wallet')),
              const PopupMenuItem(value: 'market', child: Text('Marketplace')),
              const PopupMenuItem(value: 'jobs', child: Text('Jobs')),
              const PopupMenuItem(value: 'admin', child: Text('Admin Panel')),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _tabs,
      ),
      bottomNavigationBar: SngineBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show post creation dialog or navigate to post creation
          _showPostCreationDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPostCreationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Post creation options
              const Text(
                'Create Post',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Quick options
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text Post'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to native post creation
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo Post'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to photo post creation
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video Post'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to video post creation
                },
              ),
              ListTile(
                leading: const Icon(Icons.live_tv),
                title: const Text('Go Live'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/live');
                },
              ),
              ListTile(
                leading: const Icon(Icons.more_horiz),
                title: const Text('More Options'),
                onTap: () {
                  Navigator.pop(context);
                  // Open full post creation in WebView
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebViewScreen(
                        url: '${AppConfig.webBaseUrl}/?composer=true',
                        title: 'Create Post',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search Delegate
class SngineSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return const Center(child: Text('Search Results'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return const Center(child: Text('Search Suggestions'));
  }
}