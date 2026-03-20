import '../../../models/shopping_models.dart';

abstract class ISessionRepository {
  Future<List<ShoppingSession>> getSessions();
  Future<ShoppingSession> createSession(String name, double budget);
  Future<ShoppingSession> updateSession(
    String sessionId,
    String name,
    double budget,
  );
  Future<void> deleteSession(String sessionId);
  Future<String> generateJoinCode(String sessionId);
  Future<ShoppingSession> joinByCode(String code);
  Future<void> leaveSession(String sessionId);
  Future<List<SessionMember>> getSessionMembers(String sessionId);
  Future<void> removeMember(String sessionId, String userId);
}
