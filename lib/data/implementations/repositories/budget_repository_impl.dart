import '../../../data/dtos/budget_dto.dart';
import '../../interfaces/api/i_budget_service.dart';
import '../../interfaces/repositories/i_budget_repository.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final IBudgetService _service;

  BudgetRepositoryImpl(this._service);

  @override
  Future<BudgetData> getBudgetData(String sessionId, {double sessionBudget = 0}) =>
      _service.getBudgetData(sessionId, sessionBudget: sessionBudget);
}
