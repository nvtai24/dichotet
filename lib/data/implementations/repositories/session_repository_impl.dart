import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_session_service.dart';
import '../../interfaces/repositories/i_session_repository.dart';

class SessionRepositoryImpl implements ISessionRepository {
  final ISessionService _service;

  SessionRepositoryImpl(this._service);

  @override
  Future<List<ShoppingSession>> getSessions() => _service.getSessions();

  @override
  Future<ShoppingSession> createSession(String name, double budget) =>
      _service.createSession(name, budget);

  @override
  Future<ShoppingSession> updateSession(
    String sessionId,
    String name,
    double budget,
  ) => _service.updateSession(sessionId, name, budget);

  @override
  Future<void> deleteSession(String sessionId) =>
      _service.deleteSession(sessionId);
}
