abstract class AddExpensesState {}

class AddExpensesInitialState extends AddExpensesState {
  AddExpensesInitialState();
}

class AddExpensesDataLoaded extends AddExpensesState {
  AddExpensesDataLoaded();
}

class AddExpensesDataLoading extends AddExpensesState {
  AddExpensesDataLoading();
}

class InsertExpenseState extends AddExpensesState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends AddExpensesState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends AddExpensesState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends AddExpensesState {
  ChangeTabState();
}

