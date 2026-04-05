import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  const Env._();

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      dotenv.testLoad(fileInput: '');
    }
  }

  static FirebaseOptions firebaseOptions() {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: _require('FIREBASE_WEB_API_KEY'),
        appId: _require('FIREBASE_WEB_APP_ID'),
        messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _require('FIREBASE_PROJECT_ID'),
        authDomain: dotenv.maybeGet('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        measurementId: dotenv.maybeGet('FIREBASE_WEB_MEASUREMENT_ID'),
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: _require('FIREBASE_ANDROID_API_KEY'),
          appId: _require('FIREBASE_ANDROID_APP_ID'),
          messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: _require('FIREBASE_PROJECT_ID'),
          storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: _require('FIREBASE_IOS_API_KEY'),
          appId: _require('FIREBASE_IOS_APP_ID'),
          messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: _require('FIREBASE_PROJECT_ID'),
          iosBundleId: dotenv.maybeGet('FIREBASE_IOS_BUNDLE_ID'),
          storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        );
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: _require('FIREBASE_MACOS_API_KEY'),
          appId: _require('FIREBASE_MACOS_APP_ID'),
          messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: _require('FIREBASE_PROJECT_ID'),
          storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        );
      case TargetPlatform.windows:
        return FirebaseOptions(
          apiKey: _require('FIREBASE_WINDOWS_API_KEY'),
          appId: _require('FIREBASE_WINDOWS_APP_ID'),
          messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: _require('FIREBASE_PROJECT_ID'),
          authDomain: dotenv.maybeGet('FIREBASE_WINDOWS_AUTH_DOMAIN'),
          storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        );
      case TargetPlatform.linux:
        return FirebaseOptions(
          apiKey: _require('FIREBASE_LINUX_API_KEY'),
          appId: _require('FIREBASE_LINUX_APP_ID'),
          messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: _require('FIREBASE_PROJECT_ID'),
          storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        );
      default:
        throw UnsupportedError(
          'Firebase env setup is not configured for this platform yet.',
        );
    }
  }

  static String _require(String key) {
    final String? value = dotenv.maybeGet(key);
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing required env key: $key');
    }
    return value;
  }
}
