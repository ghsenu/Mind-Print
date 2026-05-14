import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../services/rate_limiter_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final rateLimiterServiceProvider = Provider<RateLimiterService>((ref) {
  return RateLimiterService();
});
