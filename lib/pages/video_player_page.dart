import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:videos/pages/saved_video_page.dart';
import 'package:videos/pages/video_storage.dart';
import 'dart:io';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  FlickManager? _flickManager;



  final TextEditingController _urlController = TextEditingController();

  final String _sampleVideoUrl =
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";

  final VideoStorage _storage = VideoStorage();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _loadVideoFromUrl(String url) async {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      _flickManager?.dispose();
      setState(() {
        _flickManager = null;
        _isLoading = false;
      });
      return;
    }

    _flickManager?.dispose();

    setState(() {
      _flickManager = null;
      _isLoading = true;
    });

    File? videoFile;
    VideoPlayerController? controller;

    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(trimmedUrl);

      if (fileInfo != null) {
        videoFile = fileInfo.file;
        print('Video loaded from cache: ${videoFile.path}');
      } else {
        final file = await DefaultCacheManager().getSingleFile(trimmedUrl);
        videoFile = file;
        print('Video downloaded and saved to cache: ${videoFile.path}');
      }

      if (videoFile != null) {
        controller = VideoPlayerController.file(videoFile!);
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(trimmedUrl));
      }

    } catch (e) {
      print('Error during caching/downloading: $e');

      controller = VideoPlayerController.networkUrl(Uri.parse(trimmedUrl));
    }


    setState(() {
      //stip loading
      _isLoading = false;

      if (controller != null) {
        // FlickManager set
        _flickManager = FlickManager(
          videoPlayerController: controller!,
        );
      }
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


  void _saveVideoUrl() async {
    final urlToSave = _urlController.text.trim();
    if (urlToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid video URL to save.')),
      );
      return;
    }

    await _storage.saveVideo(urlToSave);


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video link saved successfully!')),
    );
  }



  void _navigateToSavedVideos() async {
    final resultUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedVideosPage()),
    );

    if (resultUrl != null && resultUrl is String) {
      _urlController.text = resultUrl;
      _loadVideoFromUrl(resultUrl);
    }
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _resetPlayer,
              icon: const Icon(Icons.close),
              label: const Text(
                'clean url input',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
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
                const SizedBox(width: 20),

                // save button
                ElevatedButton.icon(
                  onPressed: _saveVideoUrl,
                  icon: const Icon(Icons.save,color: Colors.white,),
                  label: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                ),

              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _navigateToSavedVideos,
              icon: const Icon(Icons.list,color: Colors.white,),
              label: const Text(
                'Go to Saved Videos',
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),


            if (_flickManager != null)
            // FlickVideoPlayer
              AspectRatio(
                aspectRatio: 16 / 9,
                child: FlickVideoPlayer(
                  flickManager: _flickManager!,
                ),
              )


            else if (_isLoading)

              const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 15),
                      Text("Loading video...", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
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