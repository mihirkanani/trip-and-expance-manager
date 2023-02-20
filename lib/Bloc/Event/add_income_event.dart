import 'package:flutter/cupertino.dart';

abstract class AddIncomeEvent {
  const AddIncomeEvent();
}

class AddIncomeInitialEvent extends AddIncomeEvent {
  BuildContext context;

  AddIncomeInitialEvent(this.context);
}

class InsertExpenseEvent extends AddIncomeEvent {
  BuildContext context;

  InsertExpenseEvent(this.context);
}

class AddIncomeForStoreEvent extends AddIncomeEvent {
  BuildContext context;
  int index;
  String amountController;
  String remarkController;

  AddIncomeForStoreEvent(this.context, this.index, this.amountController, this.remarkController);
}

class ChangeDateAndTimeEvent extends AddIncomeEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}

class ChangeTabEvent extends AddIncomeEvent {
  BuildContext context;

  ChangeTabEvent(this.context);
}

class UpdateCameraDataEvent extends AddIncomeEvent {
  BuildContext context;

  String imageByte;
  String imageDescController;
  UpdateCameraDataEvent(this.context,this.imageByte,this.imageDescController);
}