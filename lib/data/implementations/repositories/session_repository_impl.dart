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
  void invalidateSessions() => _cache.invalidateSessions();

  @override
  Future<ShoppingSession> createSession(String name, double budget) async {
    final session = await _service.createSession(name, budget);
    _cache.invalidateSessions();
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

  @override
  Future<String> generateJoinCode(String sessionId) async {
    final code = await _service.generateJoinCode(sessionId);
    _cache.invalidateSessions();
    return code;
  }

  @override
  Future<ShoppingSession> joinByCode(String code) async {
    final session = await _service.joinByCode(code);
    _cache.invalidateSessions();
    return session;
  }

  @override
  Future<void> leaveSession(String sessionId) async {
    await _service.leaveSession(sessionId);
    _cache.invalidateSessions();
  }

  @override
  Future<List<SessionMember>> getSessionMembers(String sessionId) =>
      _service.getSessionMembers(sessionId);

  @override
  Future<void> removeMember(String sessionId, String userId) =>
      _service.removeMember(sessionId, userId);

  @override
  Future<void> addLog({
    required String sessionId,
    required String actionType,
    String? itemName,
    Map<String, dynamic>? metadata,
  }) =>
      _service.addLog(
        sessionId: sessionId,
        actionType: actionType,
        itemName: itemName,
        metadata: metadata,
      );

  @override
  Future<List<SessionActionLog>> getActionLogs(
    String sessionId, {
    int limit = 50,
  }) =>
      _service.getActionLogs(sessionId, limit: limit);
}
