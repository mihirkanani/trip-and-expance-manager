import 'package:flutter/material.dart';

abstract class AddDiaryEvent {
  const AddDiaryEvent();
}

class AddDiaryLoadEvent extends AddDiaryEvent {
  BuildContext context;

  AddDiaryLoadEvent(this.context);
}

class AddDiaryLoadingEvent extends AddDiaryEvent {
  BuildContext context;

  AddDiaryLoadingEvent(this.context);
}

class GetAddDiaryDataEvent extends AddDiaryEvent {
  BuildContext context;

  GetAddDiaryDataEvent(this.context);
}

class AddDiaryDataEvent extends AddDiaryEvent {
  BuildContext context;

  AddDiaryDataEvent(this.context);
}

class UpdateAddDiaryDataEvent extends AddDiaryEvent {
  BuildContext context;

  UpdateAddDiaryDataEvent(this.context);
}

class RefreshDataEvent extends AddDiaryEvent {
  BuildContext context;

  RefreshDataEvent(this.context);
}

class UpdatePersonEvent extends AddDiaryEvent {
  BuildContext context;

  UpdatePersonEvent(this.context);
}

class ChangeDateAndTimeEvent extends AddDiaryEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}
