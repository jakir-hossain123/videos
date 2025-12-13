// video_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class VideoStorage {

  static const String _videoListKey = 'savedVideoUrls';

  // load saved url
  Future<List<String>> loadVideos() async {
    final prefs = await SharedPreferences.getInstance();
    // String List from SharedPreferences
    return prefs.getStringList(_videoListKey) ?? [];
  }

  // save new url
  Future<void> saveVideo(String url) async {
    if (url.trim().isEmpty) return; // dont save empty url

    final prefs = await SharedPreferences.getInstance();
    List<String> currentVideos = prefs.getStringList(_videoListKey) ?? [];

    // avoid duplicate save
    if (!currentVideos.contains(url)) {
      currentVideos.add(url.trim());
      await prefs.setStringList(_videoListKey, currentVideos);
    }
  }

  // delete url
  Future<void> deleteVideo(String url) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentVideos = prefs.getStringList(_videoListKey) ?? [];

    // remove url from list
    currentVideos.remove(url);
    await prefs.setStringList(_videoListKey, currentVideos);
  }
}