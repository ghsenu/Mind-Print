import 'dart:convert';
import 'package:http/http.dart' as http;

class _EmotionAnalysis {
  _EmotionAnalysis(this.primaryEmotion, this.intensity, this.secondaryEmotions);
  final String primaryEmotion;
  final double intensity;
  final List<String> secondaryEmotions;
}

class HuggingFaceService {
  static const _baseUrl = 'https://api-inference.huggingface.co/models';

  HuggingFaceService(this._apiKey);

  final String _apiKey;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

  // Makes a POST request, retrying once if the model is loading (503).
  Future<dynamic> _post(String model, Map<String, dynamic> body) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$model'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 503) {
        // Model is loading — HuggingFace returns {"estimated_time": N}
        if (attempt < 2) {
          await Future.delayed(const Duration(seconds: 20));
          continue;
        }
        throw Exception('HuggingFace model $model is unavailable (503).');
      }

      if (response.statusCode != 200) {
        throw Exception(
          'HuggingFace error ${response.statusCode}: ${response.body}',
        );
      }

      return jsonDecode(response.body);
    }
  }

  // text-classification models return [[{label, score}, ...]]
  Future<List<Map<String, dynamic>>> _classify(
      String model, String text) async {
    final raw = await _post(model, {'inputs': text});
    final outer = raw as List<dynamic>;
    final inner = outer[0] as List<dynamic>;
    return inner
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // zero-shot classification returns {sequence, labels, scores}
  Future<Map<String, dynamic>> _zeroShot(
    String model,
    String text,
    List<String> candidates,
  ) async {
    final raw = await _post(model, {
      'inputs': text,
      'parameters': {'candidate_labels': candidates},
    });
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<_EmotionAnalysis> _analyzeEmotion(String text) async {
    final results =
        await _classify('j-hartmann/emotion-english-distilroberta-base', text);

    results.sort(
      (a, b) =>
          (b['score'] as double).compareTo(a['score'] as double),
    );

    final primary = results.first;
    final secondaries = results
        .skip(1)
        .where((e) => (e['score'] as double) > 0.05)
        .map((e) => e['label'] as String)
        .take(3)
        .toList();

    return _EmotionAnalysis(
      primary['label'] as String,
      primary['score'] as double,
      secondaries,
    );
  }

  Future<String> analyzeSentiment(String text) async {
    final results = await _classify(
      'cardiffnlp/twitter-roberta-base-sentiment-latest',
      text,
    );

    results.sort(
      (a, b) =>
          (b['score'] as double).compareTo(a['score'] as double),
    );

    final label = (results.first['label'] as String).toLowerCase();
    if (label.contains('positive') || label == 'label_2') return 'positive';
    if (label.contains('negative') || label == 'label_0') return 'negative';
    return 'neutral';
  }

  Future<String?> detectDistortion(String text) async {
    const candidates = [
      'overgeneralization',
      'catastrophizing',
      'black-and-white thinking',
      'personalization',
      'mental filtering',
      'no cognitive distortion',
    ];

    final result = await _zeroShot('facebook/bart-large-mnli', text, candidates);

    final labels = List<String>.from(result['labels'] as List);
    final scores = List<double>.from(
      (result['scores'] as List).map((s) => (s as num).toDouble()),
    );

    if (scores.isNotEmpty &&
        scores.first > 0.30 &&
        labels.first != 'no cognitive distortion') {
      return labels.first;
    }
    return null;
  }

  // Runs emotion, sentiment, and distortion analysis in parallel.
  Future<({
    String primaryEmotion,
    double intensity,
    List<String> secondaryEmotions,
    String sentiment,
    String? distortionType,
  })> analyze(String text) async {
    final emotionFuture = _analyzeEmotion(text);
    final sentimentFuture = analyzeSentiment(text);
    final distortionFuture = detectDistortion(text);

    final emotion = await emotionFuture;
    final sentiment = await sentimentFuture;
    final distortion = await distortionFuture;

    return (
      primaryEmotion: emotion.primaryEmotion,
      intensity: emotion.intensity,
      secondaryEmotions: emotion.secondaryEmotions,
      sentiment: sentiment,
      distortionType: distortion,
    );
  }
}
