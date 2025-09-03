import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../core/models/post_model.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/story_bar.dart';

class NewsfeedTab extends ConsumerStatefulWidget {
  const NewsfeedTab({Key? key}) : super(key: key);

  @override
  ConsumerState<NewsfeedTab> createState() => _NewsfeedTabState();
}

class _NewsfeedTabState extends ConsumerState<NewsfeedTab> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    await ref.read(postsProvider.notifier).refreshPosts();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await ref.read(postsProvider.notifier).loadMorePosts();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      header: const WaterDropMaterialHeader(),
      footer: const ClassicFooter(),
      child: CustomScrollView(
        slivers: [
          // Stories Section
          const SliverToBoxAdapter(
            child: StoryBar(),
          ),
          
          // Posts
          if (postsState.isLoading && postsState.posts.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (postsState.error != null && postsState.posts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load posts',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      postsState.error!,
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(postsProvider.notifier).refreshPosts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < postsState.posts.length) {
                    return PostCard(post: postsState.posts[index]);
                  }
                  
                  // Loading indicator for pagination
                  if (postsState.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  return null;
                },
                childCount: postsState.posts.length + (postsState.isLoadingMore ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }
}