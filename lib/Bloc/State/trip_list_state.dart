abstract class TripListState {}

class TripListInitialState extends TripListState {
  TripListInitialState();
}

class TripListDataLoaded extends TripListState {
  TripListDataLoaded();
}

class TripListDataLoading extends TripListState {
  TripListDataLoading();
}

class InsertExpenseState extends TripListState {
  InsertExpenseState();
}

class AddIncomeForStoreState extends TripListState {
  AddIncomeForStoreState();
}

class ChangeDateAndTimeState extends TripListState {
  ChangeDateAndTimeState();
}
class ChangeTabState extends TripListState {
  ChangeTabState();
}

