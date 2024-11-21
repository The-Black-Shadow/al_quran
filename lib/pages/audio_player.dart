import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerPage extends StatefulWidget {
  final String title;
  final String filePath;
  final List<Map<String, dynamic>> chapters;

  const AudioPlayerPage({
    super.key,
    required this.title,
    required this.filePath,
    required this.chapters,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _audioPlayer.setAsset(widget.filePath);
      _totalDuration = (await _audioPlayer.load())!;
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });

      // Listen for playback completion
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          setState(() {
            _audioPlayer.pause(); // Pause the player
            _currentPosition = Duration.zero; // Reset to the beginning
          });
        }
      });
    } catch (e) {
      debugPrint("Error initializing audio: $e");
    }
  }

  /// Play a specific chapter
  void _playChapter(Duration start) async {
    await _audioPlayer.seek(start);
    await _audioPlayer.play();
    setState(() {});
  }

  /// Toggle play/pause
  void _togglePlayPause() async {
    if (_audioPlayer.playing) {
      // If currently playing, pause the audio
      await _audioPlayer.pause();
    } else {
      // If the position is at the end or the beginning, restart playback
      if (_currentPosition >= _totalDuration ||
          _currentPosition == Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blueAccent.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Song Duration Display
                Text(
                  '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Seek Bar
                SliderTheme(
                  data: const SliderThemeData(
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.blueAccent,
                    inactiveTrackColor: Colors.white38,
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                const SizedBox(height: 5),

                // Play/Pause Button
                Center(
                  child: IconButton(
                    iconSize: 72,
                    icon: Icon(
                      (_audioPlayer.playing &&
                              _currentPosition < _totalDuration)
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
                const SizedBox(height: 16),

                // Chapter List Header
                const Text(
                  'Chapters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Chapter List
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = widget.chapters[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(12), // Add corner radius
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              tileColor: Colors.white,
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                chapter['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Start: ${_formatDuration(chapter['start'])}, '
                                'End: ${_formatDuration(chapter['end'])}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.play_arrow,
                                color: Colors.blueAccent,
                              ),
                              onTap: () => _playChapter(chapter['start']),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
