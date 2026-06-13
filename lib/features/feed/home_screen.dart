import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import 'feed_provider.dart';
import 'video_feed_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingFeedProvider);
    final forYouAsync = ref.watch(forYouFeedProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            tabs: [
              Tab(text: 'Following'),
              Tab(text: 'For You'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            // Following Feed
            followingAsync.when(
              data: (feed) => VideoFeedView(feed: feed),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
            ),
            // For You Feed
            forYouAsync.when(
              data: (feed) => VideoFeedView(feed: feed),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}
