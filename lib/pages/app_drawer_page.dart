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
          return ListTile(
            title: Text(surah['title']),
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
          );
        },
      ),
    );
  }
}
