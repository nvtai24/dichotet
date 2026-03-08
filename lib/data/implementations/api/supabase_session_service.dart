import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_session_service.dart';

class SupabaseSessionService implements ISessionService {
  final SupabaseClient _client;

  SupabaseSessionService(this._client);

  @override
  Future<List<ShoppingSession>> getSessions() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await _client
        .from('shopping_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows.map((r) {
      return ShoppingSession(
        id: r['id'] as String,
        userId: r['user_id'] as String,
        name: r['name'] as String,
        budget: (r['budget'] as num?)?.toDouble() ?? 0,
        isActive: r['is_active'] as bool? ?? true,
        createdAt:
            DateTime.tryParse(r['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<ShoppingSession> createSession(String name, double budget) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Chưa đăng nhập');

    final rows = await _client.from('shopping_sessions').insert({
      'user_id': userId,
      'name': name,
      'budget': budget,
      'is_active': true,
    }).select();

    final r = rows.first;
    return ShoppingSession(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      name: r['name'] as String,
      budget: (r['budget'] as num?)?.toDouble() ?? 0,
      isActive: r['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<ShoppingSession> updateSession(
    String sessionId,
    String name,
    double budget,
  ) async {
    final rows = await _client
        .from('shopping_sessions')
        .update({'name': name, 'budget': budget})
        .eq('id', sessionId)
        .select();

    final r = rows.first;
    return ShoppingSession(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      name: r['name'] as String,
      budget: (r['budget'] as num?)?.toDouble() ?? 0,
      isActive: r['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _client.from('shopping_sessions').delete().eq('id', sessionId);
  }
}
