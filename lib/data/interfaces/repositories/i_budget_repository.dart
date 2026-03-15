import '../../dtos/budget_dto.dart';

abstract class IBudgetRepository {
  Future<BudgetData> getBudgetData(String sessionId);
}
