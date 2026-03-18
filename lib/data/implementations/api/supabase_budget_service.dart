import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/budget_dto.dart';
import '../../interfaces/api/i_budget_service.dart';

class SupabaseBudgetService implements IBudgetService {
  final SupabaseClient _client;

  SupabaseBudgetService(this._client);

  @override
  Future<BudgetData> getBudgetData(String sessionId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const BudgetData(
        sessionBudget: 0,
        totalEstimated: 0,
        totalSpent: 0,
        categories: [],
      );
    }

    // 1. Lấy budget của session
    final sessionRow = await _client
        .from('shopping_sessions')
        .select('budget')
        .eq('id', sessionId)
        .eq('user_id', userId)
        .maybeSingle();

    final sessionBudget = (sessionRow?['budget'] as num?)?.toDouble() ?? 0;

    // 2. Lấy tất cả items của session kèm category name và purchases
    final itemRows = await _client
        .from('shopping_items')
        .select(
          'quantity, est_price_per_unit, category_id, categories(category_name), purchases(quantity, price_per_unit)',
        )
        .eq('user_id', userId)
        .eq('session_id', sessionId);

    // 3. Tính tổng dự tính và đã chi, nhóm theo category
    int totalEstimated = 0;
    int totalSpent = 0;
    final Map<int, _CatAccumulator> catMap = {};

    for (final row in itemRows) {
      final catId = row['category_id'] as int?;
      if (catId == null) continue;

      final catData = row['categories'] as Map<String, dynamic>?;
      final catName = catData?['category_name'] as String? ?? '';
      final qty = (row['quantity'] as num?)?.toInt() ?? 0;
      final estPrice = (row['est_price_per_unit'] as num?)?.toInt() ?? 0;
      final itemEstimated = qty * estPrice;

      final purchases = row['purchases'] as List<dynamic>? ?? [];
      int itemSpent = 0;
      for (final p in purchases) {
        final pm = p as Map<String, dynamic>;
        final pQty = (pm['quantity'] as num?)?.toInt() ?? 0;
        final pPrice = (pm['price_per_unit'] as num?)?.toInt() ?? 0;
        itemSpent += pQty * pPrice;
      }

      totalEstimated += itemEstimated;
      totalSpent += itemSpent;

      final acc = catMap.putIfAbsent(
        catId,
        () => _CatAccumulator(catName),
      );
      acc.estimated += itemEstimated;
      acc.spent += itemSpent;
    }

    final categories = catMap.entries
        .where((e) => e.value.estimated > 0 || e.value.spent > 0)
        .map(
          (e) => CategoryBudgetData(
            name: e.value.name,
            categoryId: e.key,
            estimated: e.value.estimated,
            spent: e.value.spent,
          ),
        )
        .toList();

    return BudgetData(
      sessionBudget: sessionBudget,
      totalEstimated: totalEstimated,
      totalSpent: totalSpent,
      categories: categories,
    );
  }
}

class _CatAccumulator {
  final String name;
  int estimated = 0;
  int spent = 0;
  _CatAccumulator(this.name);
}
