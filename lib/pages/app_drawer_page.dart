import 'package:al_quran/modules/surah_list.dart';
import 'package:al_quran/pages/audio_player.dart';
import 'package:flutter/material.dart';

class AppDrawerPage extends StatelessWidget {
  const AppDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surah List'),
      ),
      body: ListView.builder(
        itemCount: surahList.length,
        itemBuilder: (context, index) {
          final surah = surahList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  (index + 1).toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                surah['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Tap to play',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blueAccent,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioPlayerPage(
                      title: surah['title'],
                      filePath: surah['file'],
                      chapters: surah['chapters'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
