import 'package:flutter/src/widgets/framework.dart';

abstract class EditTripEvent {
  const EditTripEvent();
}

class EditTripLoadEvent extends EditTripEvent {
  BuildContext context;

  EditTripLoadEvent(this.context);
}

class EditTripGetGroupDataEvent extends EditTripEvent {
  BuildContext context;
  var groupList;
  var userList1;

  EditTripGetGroupDataEvent(this.context, this.groupList, this.userList1);
}

class AddGroupExpansesEvent extends EditTripEvent {
  BuildContext context;

  AddGroupExpansesEvent(this.context);
}

class GetGroupInfoEvent extends EditTripEvent {
  BuildContext context;

  GetGroupInfoEvent(this.context,);
}

class AddUserEvent extends EditTripEvent {
  BuildContext context;

  AddUserEvent(this.context);
}

class GetUserInfo extends EditTripEvent {
  BuildContext context;

  GetUserInfo(this.context);
}

class UpdateTripEvent extends EditTripEvent {
  BuildContext context;

  UpdateTripEvent(this.context);
}

class DataFillChangeEvent extends EditTripEvent {
  DataFillChangeEvent();
}
class DataReload extends EditTripEvent {
  BuildContext context;

  DataReload(this.context);
}


