import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/app_bsky_feed_defs.dart' as bsky;
import 'package:bluesky/app_bsky_embed_video.dart' as bsky;
import 'video_player_widget.dart';

class VideoFeedView extends ConsumerWidget {
  final List<dynamic> feed; // bsky.FeedViewPost or bsky.PostView

  const VideoFeedView({super.key, required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (feed.isEmpty) {
      return const Center(child: Text('No videos found', style: TextStyle(color: Colors.white)));
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: feed.length,
      itemBuilder: (context, index) {
        final item = feed[index];
        final post = item is bsky.FeedViewPost ? item.post : (item as bsky.PostView);
        final author = post.author;
        
        bsky.EmbedVideoView? videoEmbed;
        final embed = post.embed;
        if (embed != null) {
          if (embed.isEmbedVideoView) {
            videoEmbed = embed.embedVideoView;
          }
        }

        if (videoEmbed == null) return const SizedBox.shrink();

        return Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayerWidget(videoEmbed: videoEmbed),
            Positioned(
              bottom: 24,
              left: 16,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${author.handle}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.record['text']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              right: 16,
              child: Column(
                children: [
                  _buildActionButton(Icons.favorite, post.likeCount.toString()),
                  const SizedBox(height: 16),
                  _buildActionButton(Icons.chat_bubble, post.replyCount.toString()),
                  const SizedBox(height: 16),
                  _buildActionButton(Icons.repeat, post.repostCount.toString()),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
