import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool isMinimized = false;
  Offset position = Offset(20, 500);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget miniPlayer() {
    return Container(
      width: 160,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMinimized = false;
                });
              },
              child: Icon(Icons.fullscreen, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Floating Video Demo")),
      body: Stack(
        children: [
          Center(
            child: Text(
              "Main Content Behind the Video",
              style: TextStyle(fontSize: 18),
            ),
          ),

          // Fullscreen video player
          if (!isMinimized && _controller.value.isInitialized)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 40,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isMinimized = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Mini floating video
          if (isMinimized && _controller.value.isInitialized)
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Draggable(
                feedback: miniPlayer(),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  setState(() {
                    position = details.offset;
                  });
                },
                child: miniPlayer(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
