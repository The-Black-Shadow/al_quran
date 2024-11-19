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
    } catch (e) {
      debugPrint("Error initializing audio: $e");
    }
  }

  void _playChapter(Duration start) async {
    await _audioPlayer.seek(start);
    await _audioPlayer.play();
  }

  void _togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _currentPosition.inSeconds.toDouble(),
              max: _totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            const SizedBox(height: 16),
            IconButton(
              iconSize: 64,
              icon: Icon(
                _audioPlayer.playing
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              onPressed: _togglePlayPause,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: widget.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = widget.chapters[index];
                  return ListTile(
                    title: Text(chapter['title']),
                    subtitle: Text(
                      'Start: ${_formatDuration(chapter['start'])}, '
                      'End: ${_formatDuration(chapter['end'])}',
                    ),
                    onTap: () => _playChapter(chapter['start']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
