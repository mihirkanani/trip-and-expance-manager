import 'package:expense_manager/Bloc/Event/settings_event.dart';
import 'package:expense_manager/Bloc/State/settings_state.dart';
import 'package:expense_manager/utils/language/application.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  String packageName = "";
  String version = "";
  TextEditingController _textFeedback = TextEditingController();
  ValueNotifier<String> selectedCurrencyValue = ValueNotifier("${PreferenceUtils.getString(key: selectedCurrency)}");
  var reminder;
  List<String> languagesList = application.supportedLanguages;
  List<String> languageCodesList = application.supportedLanguagesCodes;
  String selectedLocation = "";
  var selectedValue;
  Map<dynamic, dynamic>? languagesMap;

  SettingsBloc() : super(SettingsInitialState()) {
    on<SettingsLoadingEvent>(_onSettingsLoadingState);
    on<GetVersionEvent>(_onGetVersionState);
  }

  _onSettingsLoadingState(SettingsLoadingEvent event, Emitter<SettingsState> emit) {
    PreferenceUtils.init();
    languagesMap = {
      languagesList[0]: languageCodesList[0],
      languagesList[1]: languageCodesList[1],
    };
    BlocProvider.of<SettingsBloc>(event.context).add(GetVersionEvent(event.context));
  }

  _onGetVersionState(GetVersionEvent event, Emitter<SettingsState> emit) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      packageName = packageInfo.packageName;
      debugPrint("version $version");
    });
    emit(SettingsDataLoaded());
  }
}
