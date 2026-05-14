import 'package:firebase_storage/firebase_storage.dart';

class MusicStorageService {
  static const _bucket = 'mindprint-db.firebasestorage.app';

  // Call this once after uploading files to Firebase Storage to get permanent
  // download URLs. Print results to console, then paste into track definitions.
  static Future<String> getDownloadUrl(String storagePath) async {
    final ref = FirebaseStorage.instanceFor(bucket: 'gs://$_bucket')
        .ref(storagePath);
    return ref.getDownloadURL();
  }

  // Storage paths for all music assets
  static const Map<String, String> trackPaths = {
    'ocean-calm': 'music/ocean-calm.mp3',
    'forest-rain': 'music/forest-rain.mp3',
    'zen-focus': 'music/zen-focus.mp3',
    'deep-sleep': 'music/deep-sleep.mp3',
    'morning-light': 'music/morning-light.mp3',
    'gentle-flow': 'music/gentle-flow.mp3',
    'soft-horizon': 'music/soft-horizon.mp3',
    'still-waters': 'music/still-waters.mp3',
    'meditation-ambient': 'music/meditation-ambient.mp3',
    'breathing-ambient': 'music/breathing-ambient.mp3',
  };

  // Call this in a debug context to print all download URLs to console.
  // Paste the output into music_therapy_screen.dart, meditation_screen.dart,
  // and breathing_screen.dart, then remove this call.
  static Future<void> printAllUrls() async {
    for (final entry in trackPaths.entries) {
      final url = await getDownloadUrl(entry.value);
      // ignore: avoid_print
      print('${entry.key}: $url');
    }
  }
}
