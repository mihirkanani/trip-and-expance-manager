import 'package:flutter/cupertino.dart';

abstract class AddExpensesWithHomeEvent {
  const AddExpensesWithHomeEvent();
}

class AddExpensesWithHomeInitialEvent extends AddExpensesWithHomeEvent {
  BuildContext context;

  AddExpensesWithHomeInitialEvent(this.context);
}

class InsertExpenseWithHomeEvent extends AddExpensesWithHomeEvent {
  BuildContext context;

  InsertExpenseWithHomeEvent(this.context);
}

class AddExpensesForStoreEvent extends AddExpensesWithHomeEvent {
  BuildContext context;
  int index;
  String amountController;
  String remarkController;

  AddExpensesForStoreEvent(this.context, this.index, this.amountController, this.remarkController);
}

class ChangeDateAndTimeEvent extends AddExpensesWithHomeEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}

class ChangeTabEvent extends AddExpensesWithHomeEvent {
  BuildContext context;

  ChangeTabEvent(this.context);
}

class UpdateCameraDataEvent extends AddExpensesWithHomeEvent {
  BuildContext context;

  String imageByte;
  String imageDescController;
  UpdateCameraDataEvent(this.context,this.imageByte,this.imageDescController);
}

class DataReload extends AddExpensesWithHomeEvent {
  BuildContext context;

  DataReload(this.context);
}