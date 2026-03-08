import '../../../data/interfaces/api/i_budget_service.dart';
import '../../interfaces/repositories/i_budget_repository.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final IBudgetService _service;

  BudgetRepositoryImpl(this._service);

  @override
  Future<BudgetData> getBudgetData(String sessionId) =>
      _service.getBudgetData(sessionId);
}
