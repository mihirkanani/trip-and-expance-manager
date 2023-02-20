abstract class UserListState {}

class UserListInitialState extends UserListState {
  UserListInitialState();
}

class UserListDataLoaded extends UserListState {
  UserListDataLoaded();
}

class UserListDataLoading extends UserListState {
  UserListDataLoading();
}

class InsertExpenseState extends UserListState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends UserListState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends UserListState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends UserListState {
  ChangeTabState();
}

