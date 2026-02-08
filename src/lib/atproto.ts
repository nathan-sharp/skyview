import { AtpAgent } from "@atproto/api";

// Initialize a public agent (no login required for public profiles)
const agent = new AtpAgent({
  service: "https://public.api.bsky.app",
});

export interface VideoPost {
  uri: string;
  cid: string;
  author: {
    displayName: string;
    handle: string;
    avatar?: string;
  };
  text: string;
  thumbnail?: string;
  playlist?: string;
  createdAt: string;
}

export async function getAuthorVideos(handle: string): Promise<VideoPost[]> {
  try {
    const { data } = await agent.getAuthorFeed({
      actor: handle,
      filter: "posts_with_media",
      limit: 30,
    });

    // Filter and map to a clean video structure
    const videos = data.feed
      .map((item) => {
        const post = item.post;
        const embed = post.embed;

        // Check if the embed is a video view
        if (
          embed &&
          embed.$type === "app.bsky.embed.video#view" &&
          (embed as any).playlist
        ) {
          const videoEmbed = embed as any;
          return {
            uri: post.uri,
            cid: post.cid,
            author: {
              displayName: post.author.displayName || post.author.handle,
              handle: post.author.handle,
              avatar: post.author.avatar,
            },
            text: (post.record as any).text,
            thumbnail: videoEmbed.thumbnail,
            playlist: videoEmbed.playlist,
            createdAt: post.indexedAt,
          };
        }
        return null;
      })
      .filter((video) => video !== null) as VideoPost[];

    return videos;
  } catch (error) {
    console.error("Error fetching videos from BlueSky:", error);
    return [];
  }
}
