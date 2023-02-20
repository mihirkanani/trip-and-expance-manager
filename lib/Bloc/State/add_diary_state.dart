abstract class AddDiaryState {}

class AddDiaryInitialState extends AddDiaryState {
  AddDiaryInitialState();
}

class AddDiaryDataLoaded extends AddDiaryState {
  AddDiaryDataLoaded();
}

class AddDiaryDataLoading extends AddDiaryState {
  AddDiaryDataLoading();
}

class InsertExpenseState extends AddDiaryState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends AddDiaryState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends AddDiaryState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends AddDiaryState {
  ChangeTabState();
}

