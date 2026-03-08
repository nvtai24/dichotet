import '../api/i_budget_service.dart';

abstract class IBudgetRepository {
  Future<BudgetData> getBudgetData(String sessionId);
}
