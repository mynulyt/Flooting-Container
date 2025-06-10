import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video.dart'; // This file contains the videoPlaylist list.

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
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
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
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => isMinimized = false),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoList() {
    return ListView.builder(
      itemCount: videoPlaylist.length,
      itemBuilder: (context, index) {
        final tempController = VideoPlayerController.asset(
          videoPlaylist[index],
        );

        return FutureBuilder(
          future: tempController.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final duration = tempController.value.duration;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    _controller.removeListener(checkVideoEnd);
                    _controller.dispose();
                    currentIndex = index;
                    initializePlayer(currentIndex);
                    setState(() => isMinimized = false);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: tempController.value.aspectRatio,
                          child: VideoPlayer(tempController),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Video ${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
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
