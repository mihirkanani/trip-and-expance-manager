
import 'package:flutter/material.dart';

abstract class ViewEditExpenseEvent {
  const ViewEditExpenseEvent();
}

class ViewEditExpenseLoadEvent extends ViewEditExpenseEvent{
  ViewEditExpenseLoadEvent();
}

class GetDataLoadEvent extends ViewEditExpenseEvent{
  GetDataLoadEvent();
}

class ChangeDateAndTimeEvent extends ViewEditExpenseEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}

class InsertExpenseEvent extends ViewEditExpenseEvent {
  BuildContext context;

  InsertExpenseEvent(this.context);
}

class ChangeTabEvent extends ViewEditExpenseEvent {
  BuildContext context;

  ChangeTabEvent(this.context);
}

class UpdateCameraDataEvent extends ViewEditExpenseEvent {
  BuildContext context;

  String imageByte;
  String imageDescController;
  UpdateCameraDataEvent(this.context,this.imageByte,this.imageDescController);
}

