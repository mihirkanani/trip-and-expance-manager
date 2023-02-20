abstract class UserExpenseState {}

class UserExpenseInitialState extends UserExpenseState {
  UserExpenseInitialState();
}

class UserExpenseDataLoaded extends UserExpenseState {
  UserExpenseDataLoaded();
}

class UserExpenseDataLoading extends UserExpenseState {
  UserExpenseDataLoading();
}

class InsertExpenseState extends UserExpenseState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends UserExpenseState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends UserExpenseState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends UserExpenseState {
  ChangeTabState();
}

