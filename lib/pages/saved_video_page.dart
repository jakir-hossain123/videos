import 'package:flutter/material.dart';
import 'video_storage.dart';


class SavedVideosPage extends StatefulWidget {
  const SavedVideosPage({super.key});

  @override
  State<SavedVideosPage> createState() => _SavedVideosPageState();
}

class _SavedVideosPageState extends State<SavedVideosPage> {
  final VideoStorage _storage = VideoStorage();
  List<String> _videoUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  // load saved videos
  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });
    final urls = await _storage.loadVideos();
    setState(() {
      _videoUrls = urls;
      _isLoading = false;
    });
  }

  // delete saved videos
  void _deleteVideo(String url) async {
    await _storage.deleteVideo(url);
    _loadVideos();
  }

  void _playVideo(BuildContext context, String url) {
    Navigator.pop(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Videos"),
        backgroundColor: Colors.blueAccent[400],
        actions: [

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videoUrls.isEmpty
          ? const Center(
        child: Text(
          "No saved videos yet. Save a video link from the player page.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _videoUrls.length,
        itemBuilder: (context, index) {
          final url = _videoUrls[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(url),
              onTap: () => _playVideo(context, url),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteVideo(url),
              ),
            ),
          );
        },
      ),
    );
  }
}