abstract class LanguageSelectionState {}

class LanguageSelectionInitialState extends LanguageSelectionState {
  LanguageSelectionInitialState();
}

class LanguageSelectionDataLoaded extends LanguageSelectionState {
  LanguageSelectionDataLoaded();
}

class LanguageSelectionDataLoading extends LanguageSelectionState {
  LanguageSelectionDataLoading();
}

