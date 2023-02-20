import 'package:flutter/cupertino.dart';

abstract class InfoEvent {
  const InfoEvent();
}

class InfoDoneEvent extends InfoEvent {
  final BuildContext context;

  InfoDoneEvent(this.context);
}
