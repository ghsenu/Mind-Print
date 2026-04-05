import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mind_print/core/config/env.dart';
import 'package:mind_print/firebase_options.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    await Env.load();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }
}
