abstract class SettingsState {}

class SettingsInitialState extends SettingsState {
  SettingsInitialState();
}

class SettingsDataLoaded extends SettingsState {
  SettingsDataLoaded();
}

class SettingsDataLoading extends SettingsState {
  SettingsDataLoading();
}

