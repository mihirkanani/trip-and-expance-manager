abstract class AddIncomeState {}

class AddIncomeInitialState extends AddIncomeState {
  AddIncomeInitialState();
}

class AddIncomeDataLoaded extends AddIncomeState {
  AddIncomeDataLoaded();
}

class AddIncomeDataLoading extends AddIncomeState {
  AddIncomeDataLoading();
}

class InsertExpenseState extends AddIncomeState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends AddIncomeState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends AddIncomeState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends AddIncomeState {
  ChangeTabState();
}
