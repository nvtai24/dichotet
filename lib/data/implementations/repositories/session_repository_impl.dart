import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_session_service.dart';
import '../../interfaces/repositories/i_session_repository.dart';
import '../../local/local_cache_service.dart';
import '../../local/cache_serializer.dart';

class SessionRepositoryImpl implements ISessionRepository {
  final ISessionService _service;
  final LocalCacheService _cache;

  SessionRepositoryImpl(this._service, this._cache);

  @override
  Future<List<ShoppingSession>> getSessions() async {
    final cached = _cache.getSessions();
    if (cached != null) {
      // Return cache immediately, refresh in background
      _service.getSessions().then((fresh) {
        _cache.saveSessions(CacheSerializer.encodeSessions(fresh));
      }).catchError((_) {});
      return CacheSerializer.decodeSessions(cached);
    }
    // Cache miss: fetch from API and store
    final result = await _service.getSessions();
    _cache.saveSessions(CacheSerializer.encodeSessions(result));
    return result;
  }

  @override
  Future<ShoppingSession> createSession(String name, double budget) async {
    final session = await _service.createSession(name, budget);
    _cache.invalidateSessions(); // ViewModel updates in-memory; cache refreshed next load
    return session;
  }

  @override
  Future<ShoppingSession> updateSession(
      String sessionId, String name, double budget) async {
    final updated = await _service.updateSession(sessionId, name, budget);
    _cache.invalidateSessions();
    return updated;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _service.deleteSession(sessionId);
    _cache.invalidateSessions();
  }
}
