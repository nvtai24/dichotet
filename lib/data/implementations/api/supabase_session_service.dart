import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/shopping_models.dart';
import '../../interfaces/api/i_session_service.dart';

class SupabaseSessionService implements ISessionService {
  final SupabaseClient _client;

  SupabaseSessionService(this._client);

  ShoppingSession _sessionFromRow(Map<String, dynamic> r) => ShoppingSession(
        id: r['id'] as String,
        userId: r['user_id'] as String,
        name: r['name'] as String,
        budget: (r['budget'] as num?)?.toDouble() ?? 0,
        isActive: r['is_active'] as bool? ?? true,
        createdAt:
            DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
        joinCode: r['join_code'] as String?,
        isShared: r['is_shared'] as bool? ?? false,
      );

  @override
  Future<List<ShoppingSession>> getSessions() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    // RLS handles filtering: returns owned sessions + joined sessions
    final rows = await _client
        .from('shopping_sessions')
        .select()
        .order('created_at', ascending: false);

    return rows.map(_sessionFromRow).toList();
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

    final session = _sessionFromRow(rows.first);

    // Add creator as owner in session_members
    await _client.from('session_members').upsert({
      'session_id': session.id,
      'user_id': userId,
      'role': 'owner',
    }, onConflict: 'session_id,user_id');

    return session;
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

    return _sessionFromRow(rows.first);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _client.from('shopping_sessions').delete().eq('id', sessionId);
  }

  @override
  Future<String> generateJoinCode(String sessionId) async {
    // If session already has a code, return it
    final existing = await _client
        .from('shopping_sessions')
        .select('join_code')
        .eq('id', sessionId)
        .single();

    if (existing['join_code'] != null) {
      return existing['join_code'] as String;
    }

    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final code =
        List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();

    await _client.from('shopping_sessions').update({
      'join_code': code,
      'is_shared': true,
    }).eq('id', sessionId);

    return code;
  }

  @override
  Future<ShoppingSession> joinByCode(String code) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Chưa đăng nhập');

    final rows = await _client
        .from('shopping_sessions')
        .select()
        .eq('join_code', code.toUpperCase().trim())
        .limit(1);

    if (rows.isEmpty) throw Exception('Mã không hợp lệ');

    final session = _sessionFromRow(rows.first);

    if (session.userId == userId) {
      throw Exception('Đây là phiên của bạn');
    }

    // Upsert to handle re-joining gracefully
    await _client.from('session_members').upsert({
      'session_id': session.id,
      'user_id': userId,
      'role': 'member',
    }, onConflict: 'session_id,user_id');

    return session;
  }

  @override
  Future<void> leaveSession(String sessionId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('session_members')
        .delete()
        .eq('session_id', sessionId)
        .eq('user_id', userId);
  }

  @override
  Future<List<SessionMember>> getSessionMembers(String sessionId) async {
    final rows = await _client
        .from('session_members')
        .select('id, session_id, user_id, role, joined_at')
        .eq('session_id', sessionId);

    // Fetch profiles separately (session_members.user_id → auth.users, not profiles directly)
    final userIds = rows.map((r) => r['user_id'] as String).toList();
    final Map<String, Map<String, dynamic>> profileMap = {};
    if (userIds.isNotEmpty) {
      final profiles = await _client
          .from('profiles')
          .select('id, first_name, last_name')
          .inFilter('id', userIds);
      for (final p in profiles) {
        profileMap[p['id'] as String] = p;
      }
    }

    return rows.map((r) {
      final userId = r['user_id'] as String;
      final profile = profileMap[userId];
      final firstName = profile?['first_name'] as String? ?? '';
      final lastName = profile?['last_name'] as String? ?? '';
      final name = '$firstName $lastName'.trim();
      return SessionMember(
        id: r['id'] as String,
        sessionId: r['session_id'] as String,
        userId: userId,
        role: r['role'] as String,
        joinedAt:
            DateTime.tryParse(r['joined_at'] as String? ?? '') ?? DateTime.now(),
        displayName: name.isEmpty ? null : name,
      );
    }).toList();
  }

  @override
  Future<void> removeMember(String sessionId, String userId) async {
    await _client
        .from('session_members')
        .delete()
        .eq('session_id', sessionId)
        .eq('user_id', userId);
  }
}
