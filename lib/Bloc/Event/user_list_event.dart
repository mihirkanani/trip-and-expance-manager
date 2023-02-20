import 'package:flutter/material.dart';

abstract class UserListEvent {
  const UserListEvent();
}

class UserListLoadEvent extends UserListEvent {
  BuildContext context;

  UserListLoadEvent(this.context);
}

class GetUserDataEvent extends UserListEvent {
  BuildContext context;

  GetUserDataEvent(this.context);
}

class SetDataEvent extends UserListEvent {
  BuildContext context;

  SetDataEvent(this.context);
}

class AddPersonEvent extends UserListEvent {
  BuildContext context;

  AddPersonEvent(this.context);
}

class UpdatePersonEvent extends UserListEvent {
  BuildContext context;
  var userId;

  UpdatePersonEvent(this.context,this.userId);
}

class ChangeDateAndTimeEvent extends UserListEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}
