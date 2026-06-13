import 'package:bluesky/app_bsky_feed_defs.dart' as bsky;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';

final followingFeedProvider = FutureProvider<List<bsky.FeedViewPost>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.session == null) return [];

  try {
    final response = await auth.session!.feed.getTimeline(limit: 100);
    final feed = response.data.feed;
    
    return feed.where((view) {
      final embed = view.post.embed;
      if (embed == null) return false;
      return embed.isEmbedVideoView;
    }).toList();
  } catch (e) {
    return [];
  }
});

final forYouFeedProvider = FutureProvider<List<bsky.PostView>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.session == null) return [];

  try {
    final response = await auth.session!.feed.searchPosts(
      q: 'video',
      limit: 50,
    );
    
    return response.data.posts.where((post) {
      final embed = post.embed;
      if (embed == null) return false;
      return embed.isEmbedVideoView;
    }).toList();
  } catch (e) {
    return [];
  }
});
