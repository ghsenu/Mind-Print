import 'dart:convert';
import 'package:http/http.dart' as http;

class AssemblyAiService {
  AssemblyAiService(this._apiKey);

  final String _apiKey;

  static const _base = 'https://api.assemblyai.com/v2';

  Map<String, String> get _headers => {
        'authorization': _apiKey,
        'content-type': 'application/json',
      };

  /// Submits [audioUrl] for transcription, polls until complete, returns transcript text.
  Future<String> transcribe(String audioUrl) async {
    // Submit the transcription job.
    final submit = await http
        .post(
          Uri.parse('$_base/transcript'),
          headers: _headers,
          body: jsonEncode({'audio_url': audioUrl}),
        )
        .timeout(const Duration(seconds: 30));

    if (submit.statusCode != 200) {
      throw Exception(
          'AssemblyAI submit failed ${submit.statusCode}: ${submit.body}');
    }

    final id = (jsonDecode(submit.body) as Map)['id'] as String?;
    if (id == null) throw Exception('AssemblyAI returned no transcript ID.');

    // Poll every 5s until completed or error (max 2 minutes).
    final deadline = DateTime.now().add(const Duration(seconds: 120));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 5));

      final poll = await http
          .get(Uri.parse('$_base/transcript/$id'), headers: _headers)
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
