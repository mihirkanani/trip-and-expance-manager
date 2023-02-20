abstract class AddExpensesWithHomeState {}

class AddExpensesWithHomeInitialState extends AddExpensesWithHomeState {
  AddExpensesWithHomeInitialState();
}

class AddExpensesWithHomeDataLoaded extends AddExpensesWithHomeState {
  AddExpensesWithHomeDataLoaded();
}

class AddExpensesWithHomeDataLoading extends AddExpensesWithHomeState {
  AddExpensesWithHomeDataLoading();
}

class InsertExpenseWithHomeState extends AddExpensesWithHomeState {
  InsertExpenseWithHomeState();
}

class AddIncomeForStoreState extends AddExpensesWithHomeState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends AddExpensesWithHomeState {
  ChangeDateAndTimeState();
}

class ChangeTabState extends AddExpensesWithHomeState {
  ChangeTabState();
}
