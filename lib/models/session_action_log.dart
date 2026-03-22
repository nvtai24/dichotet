class SessionActionLog {
  final String id;
  final String sessionId;
  final String userId;
  final String actionType;
  final String? itemName;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String? userDisplayName;
  final String? userImageUrl;

  const SessionActionLog({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.actionType,
    this.itemName,
    required this.metadata,
    required this.createdAt,
    this.userDisplayName,
    this.userImageUrl,
  });

  String get actor => userDisplayName ?? 'Người dùng';

  /// Short one-liner: who did what
  String get description {
    switch (actionType) {
      case 'add_item':
        return '$actor đã thêm "${itemName ?? 'sản phẩm'}"';
      case 'update_item':
        final oldName = metadata['old_name'] as String?;
        if (oldName != null) return '$actor đã đổi tên "$oldName" → "$itemName"';
        return '$actor đã sửa "${itemName ?? 'sản phẩm'}"';
      case 'delete_item':
        return '$actor đã xóa "${itemName ?? 'sản phẩm'}"';
      case 'add_price':
        return '$actor thêm giá cho "${itemName ?? 'sản phẩm'}"';
      case 'update_purchase':
        return '$actor sửa thông tin mua "${itemName ?? 'sản phẩm'}"';
      case 'create_session':
        final name = metadata['name'] as String?;
        return '$actor đã tạo phiên${name != null ? ' "$name"' : ''}';
      case 'update_session':
        return '$actor đã cập nhật thông tin phiên';
      case 'generate_join_code':
        return '$actor đã tạo mã mời tham gia phiên';
      case 'join_session':
        return '$actor đã tham gia phiên';
      case 'leave_session':
        return '$actor đã rời phiên';
      case 'remove_member':
        final name = metadata['removed_name'] as String?;
        return '$actor đã xóa${name != null ? ' $name' : ' thành viên'} khỏi phiên';
      case 'delete_session':
        return '$actor đã xóa phiên mua sắm';
      default:
        return '$actor thực hiện thao tác';
    }
  }

  /// Extra detail line shown below description (null = no detail)
  String? get detail {
    switch (actionType) {
      case 'add_item':
        final parts = <String>[];
        final cat = metadata['category'] as String?;
        final qty = metadata['quantity'] as int?;
        final unit = metadata['unit'] as String?;
        final price = metadata['est_price'] as int?;
        final note = metadata['note'] as String?;
        if (cat != null) parts.add(cat);
        if (qty != null) parts.add('$qty ${unit ?? 'cái'}');
        if (price != null && price > 0) parts.add('~${_fmt(price)}đ/${unit ?? 'đv'}');
        if (note != null) parts.add('Ghi chú: $note');
        return parts.isEmpty ? null : parts.join(' · ');

      case 'update_item':
        final changes = <String>[];
        final oldQty = metadata['old_qty'] as int?;
        final newQty = metadata['new_qty'] as int?;
        final oldPrice = metadata['old_price'] as int?;
        final newPrice = metadata['new_price'] as int?;
        final oldCat = metadata['old_category'] as String?;
        final newCat = metadata['new_category'] as String?;
        final unit = metadata['unit'] as String? ?? '';
        if (oldQty != null && newQty != null) {
          changes.add('SL: $oldQty → $newQty $unit');
        }
        if (oldPrice != null && newPrice != null) {
          changes.add('Giá: ${_fmt(oldPrice)} → ${_fmt(newPrice)}đ');
        }
        if (oldCat != null && newCat != null) {
          changes.add('Danh mục: $oldCat → $newCat');
        }
        return changes.isEmpty ? null : changes.join(' · ');

      case 'delete_item':
        final parts = <String>[];
        final cat = metadata['category'] as String?;
        final qty = metadata['quantity'] as int?;
        final unit = metadata['unit'] as String?;
        if (cat != null) parts.add(cat);
        if (qty != null) parts.add('$qty ${unit ?? 'cái'}');
        return parts.isEmpty ? null : parts.join(' · ');

      case 'add_price':
        final store = metadata['store'] as String?;
        final price = metadata['price'] as int?;
        final unit = metadata['unit'] as String?;
        if (store == null && price == null) return null;
        final parts = <String>[];
        if (store != null) parts.add(store);
        if (price != null && price > 0) {
          parts.add('${_fmt(price)}đ/${unit ?? 'đv'}');
        }
        return parts.join(' · ');

      case 'update_purchase':
        final parts = <String>[];
        final store = metadata['store'] as String?;
        final qty = metadata['quantity'] as int?;
        final unit = metadata['unit'] as String?;
        final price = metadata['price'] as int?;
        if (store != null) parts.add(store);
        if (qty != null) parts.add('$qty ${unit ?? 'cái'}');
        if (price != null) parts.add('${_fmt(price)}đ/${unit ?? 'đv'}');
        return parts.isEmpty ? null : parts.join(' · ');

      case 'update_session':
        final name = metadata['name'] as String?;
        final budget = metadata['budget'] as int?;
        final parts = <String>[];
        if (name != null) parts.add('Tên: "$name"');
        if (budget != null) parts.add('Ngân sách: ${_fmt(budget)}đ');
        return parts.isEmpty ? null : parts.join(' · ');

      default:
        return null;
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
