import 'package:flutter/cupertino.dart';

abstract class SettingsEvent {
  const SettingsEvent();
}

class SettingsDoneEvent extends SettingsEvent {
  final BuildContext context;

  SettingsDoneEvent(this.context);
}

class GetDataLoadEvent extends SettingsEvent {
  final BuildContext context;

  GetDataLoadEvent(this.context);
}

class SettingsLoadingEvent extends SettingsEvent {
  final BuildContext context;

  SettingsLoadingEvent(this.context);
}

class GetVersionEvent extends SettingsEvent {
  final BuildContext context;

  GetVersionEvent(this.context);
}
