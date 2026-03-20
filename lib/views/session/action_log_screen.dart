import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/shopping_models.dart';
import '../../viewmodels/session/session_viewmodel.dart';

class ActionLogScreen extends StatefulWidget {
  const ActionLogScreen({super.key});

  @override
  State<ActionLogScreen> createState() => _ActionLogScreenState();
}

class _ActionLogScreenState extends State<ActionLogScreen> {
  List<SessionActionLog> _logs = [];
  bool _isLoading = true;
  String? _error;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _load() async {
    final sessionVM = context.read<SessionViewModel>();
    final sessionId = sessionVM.selectedSession?.id;
    if (sessionId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final logs = await sessionVM.getActionLogs(sessionId);
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
      _subscribeRealtime(sessionId, sessionVM);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _subscribeRealtime(String sessionId, SessionViewModel sessionVM) {
    _channel = Supabase.instance.client
        .channel('logs:$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'session_action_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (_) async {
            final fresh = await sessionVM.getActionLogs(sessionId);
            if (!mounted) return;
            setState(() => _logs = fresh);
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký hoạt động'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (_logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 56, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'Chưa có hoạt động nào',
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _logs.length,
      separatorBuilder: (context, _) =>
          const Divider(height: 1, indent: 64, endIndent: 16),
      itemBuilder: (_, i) => _LogTile(log: _logs[i]),
    );
  }
}

class _LogTile extends StatelessWidget {
  final SessionActionLog log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = log.userId == currentUserId;

    final detail = log.detail;
    return ListTile(
      leading: _Avatar(
        name: log.userDisplayName,
        imageUrl: log.userImageUrl,
        isMe: isMe,
      ),
      title: Text(
        log.description,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                detail,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: detail != null ? 2 : 0),
            child: Text(
              _formatTime(log.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ),
        ],
      ),
      isThreeLine: detail != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _Avatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final bool isMe;

  const _Avatar({this.name, this.imageUrl, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = isMe ? const Color(0xFFE53935) : Colors.blueGrey;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: color.withValues(alpha: 0.15),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        _initials(name),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
