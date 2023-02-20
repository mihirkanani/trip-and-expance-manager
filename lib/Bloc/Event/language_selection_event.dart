import 'package:flutter/cupertino.dart';

abstract class LanguageSelectionEvent {
  const LanguageSelectionEvent();
}

class LanguageSelectionLoadEvent extends LanguageSelectionEvent {
  final BuildContext context;

  LanguageSelectionLoadEvent(this.context);
}

class GetDataLoadEvent extends LanguageSelectionEvent {
  final BuildContext context;

  GetDataLoadEvent(this.context);
}
