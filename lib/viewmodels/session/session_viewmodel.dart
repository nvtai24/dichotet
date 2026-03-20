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

  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

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
    notifyListeners();
  }

  Future<ShoppingSession> createSession(String name, double budget) async {
    final session = await _repository.createSession(name, budget);
    _sessions.insert(0, session);
    notifyListeners();
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
  }

  Future<void> deleteSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_selectedSession?.id == sessionId) {
      _selectedSession = null;
    }
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
    return session;
  }

  Future<void> leaveSession(String sessionId) async {
    _logAction(sessionId, 'leave_session');
    await _repository.leaveSession(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_selectedSession?.id == sessionId) _selectedSession = null;
    notifyListeners();
  }

  Future<List<SessionMember>> getSessionMembers(String sessionId) =>
      _repository.getSessionMembers(sessionId);

  Future<void> removeMember(
      String sessionId, String userId, {String? displayName}) async {
    _logAction(sessionId, 'remove_member',
        metadata: {'removed_user_id': userId, 'removed_name': displayName});
    await _repository.removeMember(sessionId, userId);
  }

  Future<List<SessionActionLog>> getActionLogs(String sessionId) =>
      _repository.getActionLogs(sessionId);
}
