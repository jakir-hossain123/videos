import 'package:flutter/material.dart';
import 'package:videos/pages/video_player_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepOrange),
      ),
      home: VideoPlayerPage(),
    );
  }
}




