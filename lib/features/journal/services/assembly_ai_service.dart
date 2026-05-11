import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AssemblyAiService {
  AssemblyAiService(this._apiKey);

  final String _apiKey;

  static const _base = 'https://api.assemblyai.com/v2';

  Map<String, String> get _jsonHeaders => {
    'authorization': _apiKey,
    'content-type': 'application/json',
  };

  /// Uploads a local audio [filePath] directly to AssemblyAI, then
  /// transcribes it. No external storage service required.
  Future<String> transcribeFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();

    final upload = await http
        .post(
          Uri.parse('$_base/upload'),
          headers: {
            'authorization': _apiKey,
            'content-type': 'application/octet-stream',
          },
          body: bytes,
        )
        .timeout(const Duration(seconds: 60));

    if (upload.statusCode != 200) {
      throw Exception(
        'AssemblyAI upload failed ${upload.statusCode}: ${upload.body}',
      );
    }

    final uploadUrl = (jsonDecode(upload.body) as Map)['upload_url'] as String?;
    if (uploadUrl == null) {
      throw Exception('AssemblyAI returned no upload URL.');
    }

    return _submitAndPoll(uploadUrl);
  }

  Future<String> _submitAndPoll(String audioUrl) async {
    final submit = await http
        .post(
          Uri.parse('$_base/transcript'),
          headers: _jsonHeaders,
          body: jsonEncode({'audio_url': audioUrl}),
        )
        .timeout(const Duration(seconds: 30));

    if (submit.statusCode != 200) {
      throw Exception(
        'AssemblyAI submit failed ${submit.statusCode}: ${submit.body}',
      );
    }

    final id = (jsonDecode(submit.body) as Map)['id'] as String?;
    if (id == null) throw Exception('AssemblyAI returned no transcript ID.');

    // Poll every 5s until completed or error (max 2 minutes).
    final deadline = DateTime.now().add(const Duration(seconds: 120));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 5));

      final poll = await http
          .get(Uri.parse('$_base/transcript/$id'), headers: _jsonHeaders)
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(poll.body) as Map;
      final status = body['status'] as String?;

      if (status == 'completed') {
        final text = (body['text'] as String?)?.trim() ?? '';
        if (text.isEmpty) {
          throw Exception('Recording was silent or too short to transcribe.');
        }
        return text;
      }

      if (status == 'error') {
        throw Exception('AssemblyAI transcription error: ${body['error']}');
      }
      // status is 'queued' or 'processing' — keep polling.
    }

    throw Exception('Transcription timed out. Try a shorter recording.');
  }
}
