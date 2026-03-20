import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/interfaces/repositories/i_session_repository.dart';
import '../../models/shopping_models.dart';

class SessionViewModel extends ChangeNotifier {
  final ISessionRepository _repository;

  SessionViewModel(this._repository);

  List<ShoppingSession> _sessions = [];
  List<ShoppingSession> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  ShoppingSession? _selectedSession;
  ShoppingSession? get selectedSession => _selectedSession;

  /// Non-null when the current user was removed from a session.
  /// UI should react by navigating to SessionListScreen, then call [clearKicked].
  String? _kickedFromSessionId;
  String? get kickedFromSessionId => _kickedFromSessionId;

  void clearKicked() {
    _kickedFromSessionId = null;
  }

  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  // ─── Session-level Realtime ─────────────────────────────────────────────
  final Map<String, RealtimeChannel> _sessionChannels = {};

  /// Subscribe to session-level events (name/budget changes, member changes).
  /// Call this when a session is opened.
  void subscribeToSession(String sessionId) {
    if (_sessionChannels.containsKey(sessionId)) return;
    final channel = Supabase.instance.client
        .channel('session:$sessionId')
        .onBroadcast(
          event: 'session_changed',
          callback: (_) async {
            // Reload sessions so name/budget reflects the update
            final updated = await _repository.getSessions().catchError((_) => _sessions);
            _sessions = updated;
            if (_selectedSession?.id == sessionId) {
              final fresh = _sessions.where((s) => s.id == sessionId).firstOrNull;
              if (fresh != null) _selectedSession = fresh;
            }
            notifyListeners();
          },
        )
        .onBroadcast(
          event: 'session_deleted',
          callback: (_) {
            _sessions.removeWhere((s) => s.id == sessionId);
            if (_selectedSession?.id == sessionId) _selectedSession = null;
            notifyListeners();
          },
        )
        .onBroadcast(
          event: 'member_removed',
          callback: (payload) {
            final removedId = payload['userId'] as String?;
            if (removedId == null) return;
            if (removedId == currentUserId) {
              _sessions.removeWhere((s) => s.id == sessionId);
              if (_selectedSession?.id == sessionId) _selectedSession = null;
              _kickedFromSessionId = sessionId;
              notifyListeners();
            }
          },
        )
        .subscribe();
    _sessionChannels[sessionId] = channel;
  }

  void unsubscribeFromSession(String sessionId) {
    _sessionChannels.remove(sessionId)?.unsubscribe();
  }

  void _broadcastSession(String sessionId, String event,
      [Map<String, dynamic> payload = const {}]) {
    _sessionChannels[sessionId]
        ?.sendBroadcastMessage(event: event, payload: payload);
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _repository.getSessions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _sessions = [];
    _selectedSession = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void selectSession(ShoppingSession session) {
    _selectedSession = session;
    subscribeToSession(session.id);
    notifyListeners();
  }

  Future<ShoppingSession> createSession(String name, double budget) async {
    final session = await _repository.createSession(name, budget);
    _sessions.insert(0, session);
    notifyListeners();
    _logAction(session.id, 'create_session',
        metadata: {'name': name, 'budget': budget.toInt()});
    return session;
  }

  Future<void> updateSession(
    String sessionId,
    String name,
    double budget,
  ) async {
    final updated = await _repository.updateSession(sessionId, name, budget);
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) _sessions[idx] = updated;
    if (_selectedSession?.id == sessionId) _selectedSession = updated;
    notifyListeners();
    _logAction(sessionId, 'update_session',
        metadata: {'name': name, 'budget': budget.toInt()});
    _broadcastSession(sessionId, 'session_changed');
  }

  Future<void> deleteSession(String sessionId) async {
    _broadcastSession(sessionId, 'session_deleted');
    await _repository.deleteSession(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_selectedSession?.id == sessionId) _selectedSession = null;
    unsubscribeFromSession(sessionId);
    notifyListeners();
  }

  // ─── Sharing ───────────────────────────────────────────────────────────

  Future<String> generateJoinCode(String sessionId) async {
    final code = await _repository.generateJoinCode(sessionId);
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      final s = _sessions[idx];
      _sessions[idx] = ShoppingSession(
        id: s.id,
        userId: s.userId,
        name: s.name,
        budget: s.budget,
        isActive: s.isActive,
        createdAt: s.createdAt,
        joinCode: code,
        isShared: true,
      );
      notifyListeners();
    }
    _logAction(sessionId, 'generate_join_code');
    return code;
  }

  void _logAction(
    String sessionId,
    String actionType, {
    Map<String, dynamic>? metadata,
  }) {
    _repository
        .addLog(
          sessionId: sessionId,
          actionType: actionType,
          metadata: metadata,
        )
        .catchError((_) {});
  }

  Future<ShoppingSession> joinByCode(String code) async {
    final session = await _repository.joinByCode(code);
    if (!_sessions.any((s) => s.id == session.id)) {
      _sessions.insert(0, session);
      notifyListeners();
    }
    _logAction(session.id, 'join_session');
    _broadcastSession(session.id, 'session_changed');
    return session;
  }

  Future<void> leaveSession(String sessionId) async {
    _logAction(sessionId, 'leave_session');
    _broadcastSession(sessionId, 'session_changed');
    await _repository.leaveSession(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_selectedSession?.id == sessionId) _selectedSession = null;
    unsubscribeFromSession(sessionId);
    notifyListeners();
  }

  Future<List<SessionMember>> getSessionMembers(String sessionId) =>
      _repository.getSessionMembers(sessionId);

  Future<void> removeMember(
      String sessionId, String userId, {String? displayName}) async {
    _logAction(sessionId, 'remove_member',
        metadata: {'removed_user_id': userId, 'removed_name': displayName});
    await _repository.removeMember(sessionId, userId);
    _broadcastSession(sessionId, 'member_removed', {'userId': userId});
  }

  Future<List<SessionActionLog>> getActionLogs(String sessionId) =>
      _repository.getActionLogs(sessionId);
}
