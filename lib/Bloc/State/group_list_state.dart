abstract class GroupListState {}

class GroupListInitialState extends GroupListState {
  GroupListInitialState();
}

class GroupListDataLoaded extends GroupListState {
  GroupListDataLoaded();
}

class GroupListDataLoading extends GroupListState {
  GroupListDataLoading();
}

class InsertExpenseState extends GroupListState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends GroupListState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends GroupListState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends GroupListState {
  ChangeTabState();
}

