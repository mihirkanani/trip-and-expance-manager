import 'package:flutter/material.dart';

abstract class GroupListEvent {
  const GroupListEvent();
}

class GroupListLoadEvent extends GroupListEvent {
  BuildContext context;

  GroupListLoadEvent(this.context);
}

class GetGroupDataEvent extends GroupListEvent {
  BuildContext context;

  GetGroupDataEvent(this.context);
}

class SetDataEvent extends GroupListEvent {
  BuildContext context;

  SetDataEvent(this.context);
}

class AddPersonEvent extends GroupListEvent {
  BuildContext context;

  AddPersonEvent(this.context);
}

class UpdatePersonEvent extends GroupListEvent {
  BuildContext context;
  var GroupId;

  UpdatePersonEvent(this.context,this.GroupId);
}

class ChangeDateAndTimeEvent extends GroupListEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}
