import 'package:flutter/cupertino.dart';

abstract class AddExpensesEvent {
  const AddExpensesEvent();
}

class AddExpensesInitialEvent extends AddExpensesEvent {
  BuildContext context;

  AddExpensesInitialEvent(this.context);
}

class InsertExpenseEvent extends AddExpensesEvent {
  BuildContext context;

  InsertExpenseEvent(this.context);
}

class AddExpensesForStoreEvent extends AddExpensesEvent {
  BuildContext context;
  int index;
  String amountController;
  String remarkController;

  AddExpensesForStoreEvent(this.context, this.index, this.amountController, this.remarkController);
}

class ChangeDateAndTimeEvent extends AddExpensesEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}

class ChangeTabEvent extends AddExpensesEvent {
  BuildContext context;

  ChangeTabEvent(this.context);
}

class UpdateCameraDataEvent extends AddExpensesEvent {
  BuildContext context;

  String imageByte;
  String imageDescController;
  UpdateCameraDataEvent(this.context,this.imageByte,this.imageDescController);
}