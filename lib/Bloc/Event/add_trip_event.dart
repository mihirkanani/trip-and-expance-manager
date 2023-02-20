import 'package:flutter/src/widgets/framework.dart';

abstract class AddTripEvent {
  const AddTripEvent();
}

class DataReload extends AddTripEvent {
  BuildContext context;

  DataReload(this.context);
}

class AddTripLoadEvent extends AddTripEvent {
  BuildContext context;

  AddTripLoadEvent(this.context);
}

class GetDataLoadEvent extends AddTripEvent {
  BuildContext context;

  GetDataLoadEvent(this.context);
}

class SetDataLoadEvent extends AddTripEvent {
  SetDataLoadEvent();
}

class AddTripDataEvent extends AddTripEvent {
  BuildContext context;

  AddTripDataEvent(this.context);
}

class AddPersonEvent extends AddTripEvent {
  BuildContext context;

  AddPersonEvent(this.context);
}

class UpdateUserEvent extends AddTripEvent {
  BuildContext context;
  UpdateUserEvent(this.context);
}

class AddGroupExpenseEvent extends AddTripEvent {
  BuildContext context;

  AddGroupExpenseEvent(this.context);
}

class GetGroupInfoEvent extends AddTripEvent {
  BuildContext context;

  GetGroupInfoEvent(this.context);
}

class GetGroupDataEvent extends AddTripEvent {
  GetGroupDataEvent();
}

class AddUserEvent extends AddTripEvent {
  BuildContext context;

  AddUserEvent(this.context);
}

class GetUserInfoEvent extends AddTripEvent {
  BuildContext context;

  GetUserInfoEvent(this.context);
}

class GetUserDataEvent extends AddTripEvent {
  GetUserDataEvent();
}

class DataFillChangeEvent extends AddTripEvent {
  DataFillChangeEvent();
}
