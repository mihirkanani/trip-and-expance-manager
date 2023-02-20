import 'package:expense_manager/Bloc/Event/language_selection_event.dart';
import 'package:expense_manager/Bloc/State/language_selection_state.dart';
import 'package:expense_manager/utils/language/application.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSelectionBloc extends Bloc<LanguageSelectionEvent, LanguageSelectionState> {

  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList = application.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  String selectedLocation = "";
  var selectedValue;
  var reminder;
  LanguageSelectionBloc() : super(LanguageSelectionInitialState()) {
    on<LanguageSelectionLoadEvent>(_onSettingsLoadingState);
  }

  _onSettingsLoadingState(LanguageSelectionLoadEvent event, Emitter<LanguageSelectionState> emit) {
    PreferenceUtils.init();
    emit(LanguageSelectionDataLoaded());
  }
}
