import '../../../models/shopping_models.dart';

abstract class ISessionService {
  Future<List<ShoppingSession>> getSessions();
  Future<ShoppingSession> createSession(String name, double budget);
  Future<void> deleteSession(String sessionId);
}
