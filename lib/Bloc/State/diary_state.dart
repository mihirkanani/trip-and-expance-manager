abstract class DiaryState {}

class DiaryInitialState extends DiaryState {
  DiaryInitialState();
}

class DiaryDataLoaded extends DiaryState {
  DiaryDataLoaded();
}

class DiaryDataLoading extends DiaryState {
  DiaryDataLoading();
}

