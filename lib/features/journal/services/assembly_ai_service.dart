import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../shared/services/rate_limiter_service.dart';

class AssemblyAiService {
  AssemblyAiService(this._apiKey, this._rateLimiter);

  final String _apiKey;
  final RateLimiterService _rateLimiter;

  static const _base = 'https://api.assemblyai.com/v2';

  Map<String, String> get _jsonHeaders => {
    'authorization': _apiKey,
    'content-type': 'application/json',
  };

  /// Uploads a local audio [filePath] directly to AssemblyAI, then
  /// transcribes it. No external storage service required.
  Future<String> transcribeFile(
    String filePath, {
    void Function(String status)? onStatus,
  }) async {
    // Check rate limit
    final isAllowed = await _rateLimiter.isAllowed('assembly_ai');
    if (!isAllowed) {
      throw Exception('Transcription rate limit exceeded. Please try again in a minute.');
    }

    onStatus?.call('uploading');
    final uploadRequest = http.StreamedRequest(
      'POST',
      Uri.parse('$_base/upload'),
    );
    uploadRequest.headers.addAll({
      'authorization': _apiKey,
      'content-type': 'application/octet-stream',
    });
    await uploadRequest.sink.addStream(File(filePath).openRead());
    await uploadRequest.sink.close();

    final uploadStreamed = await uploadRequest.send().timeout(
      const Duration(seconds: 60),
    );
    final upload = await http.Response.fromStream(uploadStreamed);

    if (upload.statusCode != 200) {
      throw Exception(
        'AssemblyAI upload failed ${upload.statusCode}: ${upload.body}',
      );
    }

    final uploadUrl = (jsonDecode(upload.body) as Map)['upload_url'] as String?;
    if (uploadUrl == null) {
      throw Exception('AssemblyAI returned no upload URL.');
    }

    onStatus?.call('transcribing');
    return _submitAndPoll(uploadUrl);
  }

  Future<String> _submitAndPoll(String audioUrl) async {
    final submit = await http
        .post(
          Uri.parse('$_base/transcript'),
          headers: _jsonHeaders,
          body: jsonEncode({
            'audio_url': audioUrl,
            'speech_models': ['universal-3-pro', 'universal-2'],
          }),
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

      if (poll.statusCode != 200) {
        throw Exception(
          'AssemblyAI poll failed ${poll.statusCode}: ${poll.body}',
        );
      }

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
