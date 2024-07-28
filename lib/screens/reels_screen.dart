import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final List<Map<String, String>> _reelsData = [
    {
      'videoUrl': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      'username': '@user1',
      'profilePicUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'description': 'First reel description',
    },
    {
      'videoUrl': 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
      'username': '@user2',
      'profilePicUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'description': 'Second reel description',
    },
    // Add more reels data here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _reelsData.length,
        itemBuilder: (context, index) {
          return ReelsViewer(
            videoUrl: _reelsData[index]['videoUrl']!,
            username: _reelsData[index]['username']!,
            profilePicUrl: _reelsData[index]['profilePicUrl']!,
            description: _reelsData[index]['description']!,
          );
        },
      ),
    );
  }
}

class ReelsViewer extends StatefulWidget {
  final String videoUrl;
  final String username;
  final String profilePicUrl;
  final String description;

  ReelsViewer({
    required this.videoUrl,
    required this.username,
    required this.profilePicUrl,
    required this.description,
  });

  @override
  _ReelsViewerState createState() => _ReelsViewerState();
}

class _ReelsViewerState extends State<ReelsViewer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isSoundOn = true;
  bool _showControls = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        if (_controller.value.isInitialized) {
          setState(() {
            _isLoading = false;
          });
        }
      })
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _isPlaying = true;
        });
      }).catchError((error) {
        print('Error initializing video: $error');
        setState(() {
          _isLoading = false;
        });
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _controller.seekTo(Duration.zero);
          _controller.play();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
      _showControls = true;
      _hideControlsAfterDelay();
    });
  }

  void _toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
      _controller.setVolume(_isSoundOn ? 1.0 : 0.0);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _hideControlsAfterDelay();
      }
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(Duration(seconds: 3), () {
      if (_isPlaying && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.save),
              title: Text('Save Reel'),
              onTap: () {
                // Handle save reel
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('Report Reel'),
              onTap: () {
                // Handle report reel
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.not_interested),
              title: Text('Not Interested'),
              onTap: () {
                // Handle not interested
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized)
            VideoPlayer(_controller)
          else
            Center(child: CircularProgressIndicator()),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          if (_showControls)
            Center(
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 60,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(widget.profilePicUrl),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.username,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              // Handle follow button press
                            },
                            child: Text(
                              'Follow',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Spacer(),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite_border, color: Colors.white),
                            onPressed: () {
                              // Handle like button press
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.comment, color: Colors.white),
                            onPressed: () {
                              // Handle comment button press
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              // Handle share button press
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onPressed: _showSettingsMenu,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
