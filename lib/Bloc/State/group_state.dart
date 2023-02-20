abstract class GroupState {}

class GroupInitialState extends GroupState {
  GroupInitialState();
}

class GroupDataLoaded extends GroupState {
  GroupDataLoaded();
}

class GroupDataLoading extends GroupState {
  GroupDataLoading();
}

class InsertExpenseState extends GroupState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends GroupState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends GroupState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends GroupState {
  ChangeTabState();
}

