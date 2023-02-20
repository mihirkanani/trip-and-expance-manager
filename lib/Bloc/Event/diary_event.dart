import 'package:flutter/material.dart';

abstract class DiaryEvent {
  const DiaryEvent();
}

class DiaryLoadEvent extends DiaryEvent {
  BuildContext context;

  DiaryLoadEvent(this.context);
}

class DiaryLoadingEvent extends DiaryEvent {
  BuildContext context;

  DiaryLoadingEvent(this.context);
}

class GetDiaryDataEvent extends DiaryEvent {
  BuildContext context;

  GetDiaryDataEvent(this.context);
}

class AddDiaryExpenseEvent extends DiaryEvent {
  BuildContext context;

  AddDiaryExpenseEvent(this.context);
}

class UpdateDiaryEvent extends DiaryEvent {
  BuildContext context;
  var DiaryId;

  UpdateDiaryEvent(this.context, this.DiaryId);
}

class UpdatePersonEvent extends DiaryEvent {
  BuildContext context;
  var userId;

  UpdatePersonEvent(this.context, this.userId);
}

class ChangeDateAndTimeEvent extends DiaryEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}
