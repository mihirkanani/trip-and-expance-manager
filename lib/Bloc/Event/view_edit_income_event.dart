
import 'package:flutter/material.dart';

abstract class ViewEditIncomeEvent {
  const ViewEditIncomeEvent();
}

class ViewEditIncomeLoadEvent extends ViewEditIncomeEvent{
  ViewEditIncomeLoadEvent();
}

class GetDataLoadEvent extends ViewEditIncomeEvent{
  GetDataLoadEvent();
}

class ChangeDateAndTimeEvent extends ViewEditIncomeEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}

class InsertIncomeEvent extends ViewEditIncomeEvent {
  BuildContext context;

  InsertIncomeEvent(this.context);
}

class ChangeTabEvent extends ViewEditIncomeEvent {
  BuildContext context;

  ChangeTabEvent(this.context);
}

class UpdateCameraDataEvent extends ViewEditIncomeEvent {
  BuildContext context;

  String imageByte;
  String imageDescController;
  UpdateCameraDataEvent(this.context,this.imageByte,this.imageDescController);
}

