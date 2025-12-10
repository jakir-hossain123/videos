import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  FlickManager? _flickManager;

  final TextEditingController _urlController = TextEditingController();

  final String _sampleVideoUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";

  @override
  void initState() {
    super.initState();
  }

  void _loadVideoFromUrl(String url) {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      _flickManager?.dispose();
      setState(() {
        _flickManager = null;
      });
      return;
    }

    _flickManager?.dispose();

    setState(() {
      _flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(trimmedUrl)),
      );
    });
  }

  void _playSampleVideo() {
    _loadVideoFromUrl(_sampleVideoUrl);
  }

  void _resetPlayer() {
    _flickManager?.dispose();
    _urlController.clear();
    setState(() {
      _flickManager = null;
    });
  }

  @override
  void dispose() {
    _flickManager?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent[400],
        title: const Text("Flutter Video Player"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _playSampleVideo,
        label: const Text('Play Sample Video'),
        icon: const Icon(Icons.movie_filter),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[

            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                  labelText: 'Video link (URL)',
                  border: OutlineInputBorder(),
                  hintText: 'mp4, mov, or m3u8 link',
                  fillColor: Colors.white,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black54)
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),

            Row( mainAxisAlignment: MainAxisAlignment.center ,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _loadVideoFromUrl(_urlController.text);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Play',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

              ],
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _resetPlayer, // ধাপ ১ এর ফাংশনটি কল করা হলো
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Restart',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // আলাদা রঙ
              ),
            ),


            const SizedBox(height: 20),


            if (_flickManager != null)
            // FlickVideoPlayer
              AspectRatio(
                aspectRatio: 16 / 9,
                child: FlickVideoPlayer(
                  flickManager: _flickManager!,
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        "First input a valid url and press 'Play' button to play video",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "for sample video press 'Play Sample Video' button",
                        style: TextStyle(color: Colors.green, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),

                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}