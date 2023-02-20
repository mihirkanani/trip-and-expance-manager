import 'package:flutter/material.dart';

abstract class GroupEvent {
  const GroupEvent();
}

class GroupLoadEvent extends GroupEvent {
  BuildContext context;

  GroupLoadEvent(this.context);
}

class GroupLoadingEvent extends GroupEvent {
  BuildContext context;

  GroupLoadingEvent(this.context);
}

class GetGroupDataEvent extends GroupEvent {
  BuildContext context;

  GetGroupDataEvent(this.context);
}

class AddGroupExpenseEvent extends GroupEvent {
  BuildContext context;

  AddGroupExpenseEvent(this.context);
}

class UpdateGroupEvent extends GroupEvent {
  BuildContext context;
  var groupId;

  UpdateGroupEvent(this.context, this.groupId);
}

class UpdatePersonEvent extends GroupEvent {
  BuildContext context;
  var userId;

  UpdatePersonEvent(this.context, this.userId);
}

class ChangeDateAndTimeEvent extends GroupEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}
