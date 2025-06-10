import 'package:flooting_container/video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  int currentIndex = 0;
  bool isMinimized = false;
  Offset position = Offset(20, 500);

  @override
  void initState() {
    super.initState();
    initializePlayer(currentIndex);
  }

  void initializePlayer(int index) {
    _controller = VideoPlayerController.asset(videoPlaylist[index])
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.addListener(checkVideoEnd);
      });
  }

  void checkVideoEnd() {
    if (_controller.value.position >= _controller.value.duration &&
        !_controller.value.isPlaying) {
      playNextVideo();
    }
  }

  void playNextVideo() {
    _controller.removeListener(checkVideoEnd);
    _controller.dispose();
    currentIndex = (currentIndex + 1) % videoPlaylist.length;
    initializePlayer(currentIndex);
  }

  void playPreviousVideo() {
    _controller.removeListener(checkVideoEnd);
    _controller.dispose();
    currentIndex =
        (currentIndex - 1 + videoPlaylist.length) % videoPlaylist.length;
    initializePlayer(currentIndex);
  }

  @override
  void dispose() {
    _controller.removeListener(checkVideoEnd);
    _controller.dispose();
    super.dispose();
  }

  Widget miniPlayer() {
    return Dismissible(
      key: ValueKey("mini-player"),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => setState(() => isMinimized = false),
      child: Container(
        width: 180,
        height: 100,
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
                onTap: () => setState(() => isMinimized = false),
                child: Icon(Icons.fullscreen, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVideoList() {
    return ListView.builder(
      itemCount: videoPlaylist.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Video ${index + 1}'),
          onTap: () {
            _controller.removeListener(checkVideoEnd);
            _controller.dispose();
            currentIndex = index;
            initializePlayer(currentIndex);
            setState(() {
              isMinimized = false;
            });
          },
        );
      },
    );
  }

  Widget buildFullPlayer() {
    return Stack(
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
            onPressed: () => setState(() => isMinimized = true),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, size: 36, color: Colors.white),
                onPressed: playPreviousVideo,
              ),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 36,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, size: 36, color: Colors.white),
                onPressed: playNextVideo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Floating Video Playlist")),
      body: Stack(
        children: [
          buildVideoList(),
          if (!isMinimized && _controller.value.isInitialized)
            Positioned.fill(
              child: Container(color: Colors.black, child: buildFullPlayer()),
            ),
          if (isMinimized && _controller.value.isInitialized)
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Draggable(
                feedback: miniPlayer(),
                childWhenDragging: Container(),
                onDragEnd:
                    (details) => setState(() => position = details.offset),
                child: miniPlayer(),
              ),
            ),
        ],
      ),
    );
  }
}
