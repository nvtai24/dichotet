import '../../dtos/budget_dto.dart';

abstract class IBudgetService {
  Future<BudgetData> getBudgetData(String sessionId, {double sessionBudget = 0});
}
