import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceService {
  VoiceService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startRecording(String path) async {
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 64000,
    );
    await _recorder.start(config, path: path);
  }

  Future<String> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) throw Exception('Recording produced no file.');
    return path;
  }

  Future<bool> get isRecording => _recorder.isRecording();

  Future<String> uploadToStorage(
    String userId,
    String fileId,
    String filePath,
  ) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('voice')
        .child(userId)
        .child('$fileId.m4a');

    final snapshot = await ref.putFile(
      File(filePath),
      SettableMetadata(contentType: 'audio/mp4'),
    );
    return snapshot.ref.getDownloadURL();
  }

  Future<void> dispose() => _recorder.dispose();
}
