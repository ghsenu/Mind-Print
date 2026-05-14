import 'package:shared_preferences/shared_preferences.dart';

class RateLimiterService {
  static const int _windowMinutes = 1;
  static const Map<String, int> _limits = {
    'assembly_ai': 3, // 3 transcriptions per minute
    'gemini': 10,     // 10 analyses per minute
  };

  Future<bool> isAllowed(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastReset = prefs.getInt('${serviceName}_last_reset') ?? 0;
    final currentCount = prefs.getInt('${serviceName}_count') ?? 0;

    // Check if we are in a new window
    if (now - lastReset > _windowMinutes * 60 * 1000) {
      await prefs.setInt('${serviceName}_last_reset', now);
      await prefs.setInt('${serviceName}_count', 1);
      return true;
    }

    final limit = _limits[serviceName] ?? 5;
    if (currentCount < limit) {
      await prefs.setInt('${serviceName}_count', currentCount + 1);
      return true;
    }

    return false;
  }

  Future<int> getRemainingRequests(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastReset = prefs.getInt('${serviceName}_last_reset') ?? 0;
    final currentCount = prefs.getInt('${serviceName}_count') ?? 0;

    if (now - lastReset > _windowMinutes * 60 * 1000) {
      return _limits[serviceName] ?? 5;
    }

    final limit = _limits[serviceName] ?? 5;
    return (limit - currentCount).clamp(0, limit);
  }
}
