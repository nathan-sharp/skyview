import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bluesky/app_bsky_feed_post.dart' as bsky;
import '../../core/auth/auth_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _selectedVideo;
  bool _isUploading = false;
  String? _statusMessage;

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _statusMessage = null;
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;
    
    final auth = ref.read(authProvider);
    if (auth.session == null) return;

    setState(() {
      _isUploading = true;
      _statusMessage = 'Uploading video blob...';
    });

    try {
      final bytes = await _selectedVideo!.readAsBytes();
      
      final blobResponse = await auth.session!.atproto.repo.uploadBlob(bytes: bytes);
      
      setState(() {
        _statusMessage = 'Creating post record...';
      });

      await auth.session!.feed.post.create(
        text: _textController.text.trim(),
        embed: bsky.UFeedPostEmbed.unknown(data: {
          r'$type': 'app.bsky.embed.video',
          'video': blobResponse.data.blob.toJson(),
          'alt': 'A video uploaded via Skyview',
        }),
      );

      setState(() {
        _isUploading = false;
        _statusMessage = 'Video posted successfully!';
        _selectedVideo = null;
        _textController.clear();
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Error uploading: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Describe your video...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            if (_selectedVideo != null) ...[
              const Icon(Icons.video_file, size: 80, color: Colors.blue),
              Text(
                'Selected: ${_selectedVideo!.name}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickVideo,
                icon: const Icon(Icons.refresh),
                label: const Text('Change Video'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Select Video'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  backgroundColor: Colors.grey[900],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains('Error') ? Colors.red : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: (_selectedVideo == null || _isUploading) ? null : _uploadVideo,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Post Video', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
