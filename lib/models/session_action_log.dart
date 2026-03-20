class SessionActionLog {
  final String id;
  final String sessionId;
  final String userId;
  final String actionType;
  final String? itemName;
  final int? itemId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String? userDisplayName;

  const SessionActionLog({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.actionType,
    this.itemName,
    this.itemId,
    required this.metadata,
    required this.createdAt,
    this.userDisplayName,
  });

  /// Human-readable description of the action
  String get description {
    final actor = userDisplayName ?? 'Người dùng';
    switch (actionType) {
      case 'add_item':
        return '$actor đã thêm "${itemName ?? 'sản phẩm'}"';
      case 'update_item':
        final oldName = metadata['old_name'] as String?;
        if (oldName != null && oldName != itemName) {
          return '$actor đã sửa "$oldName" → "${itemName ?? ''}"';
        }
        return '$actor đã sửa "${itemName ?? 'sản phẩm'}"';
      case 'delete_item':
        return '$actor đã xóa "${itemName ?? 'sản phẩm'}"';
      case 'check_item':
        final store = metadata['store'] as String?;
        final price = metadata['price'] as int?;
        if (store != null && price != null) {
          return '$actor đã mua "${itemName ?? ''}" tại $store · ${_fmt(price)}đ';
        }
        return '$actor đã đánh dấu mua "${itemName ?? 'sản phẩm'}"';
      case 'uncheck_item':
        return '$actor bỏ đánh dấu "${itemName ?? 'sản phẩm'}"';
      case 'add_price':
        final store = metadata['store'] as String?;
        final price = metadata['price'] as int?;
        if (store != null && price != null) {
          return '$actor thêm giá "${itemName ?? ''}" tại $store: ${_fmt(price)}đ';
        }
        return '$actor thêm giá cho "${itemName ?? 'sản phẩm'}"';
      case 'join_session':
        return '$actor đã tham gia phiên';
      case 'leave_session':
        return '$actor đã rời phiên';
      case 'update_purchase':
        final store = metadata['store'] as String?;
        final price = metadata['price'] as int?;
        if (store != null && price != null) {
          return '$actor đã sửa thông tin mua "${itemName ?? ''}" tại $store · ${_fmt(price)}đ';
        }
        return '$actor đã sửa thông tin mua "${itemName ?? 'sản phẩm'}"';
      case 'remove_member':
        final name = metadata['removed_name'] as String?;
        return '$actor đã xóa${name != null ? ' $name' : ' thành viên'} khỏi phiên';
      default:
        return '$actor thực hiện thao tác';
    }
  }

  String _fmt(int v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M';
    }
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
