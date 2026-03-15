import 'package:flutter/foundation.dart';
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
}
