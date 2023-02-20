import 'package:flutter/material.dart';

abstract class UserExpenseEvent {
  const UserExpenseEvent();
}

class UserExpenseLoadEvent extends UserExpenseEvent {
  BuildContext context;

  UserExpenseLoadEvent(this.context);
}

class GetUserExpenseDataEvent extends UserExpenseEvent {
  BuildContext context;

  GetUserExpenseDataEvent(this.context);
}

class AddUserExpenseExpenseEvent extends UserExpenseEvent {
  BuildContext context;

  AddUserExpenseExpenseEvent(this.context);
}

class UpdateUserExpenseEvent extends UserExpenseEvent {
  BuildContext context;
  var UserExpenseId;

  UpdateUserExpenseEvent(this.context, this.UserExpenseId);
}

class UpdatePersonEvent extends UserExpenseEvent {
  BuildContext context;
  var userId;

  UpdatePersonEvent(this.context, this.userId);
}

class ChangeDateAndTimeEvent extends UserExpenseEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}
