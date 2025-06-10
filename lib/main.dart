import 'package:flutter/material.dart';
import 'video_player_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Video Player',
      debugShowCheckedModeBanner: false,
      home: VideoPlayerPage(),
    );
  }
}
