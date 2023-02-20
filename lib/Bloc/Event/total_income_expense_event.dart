import 'package:flutter/cupertino.dart';

abstract class TotalIncomeExpenseEvent {
  const TotalIncomeExpenseEvent();
}

class TotalIncomeExpenseLoadEvent extends TotalIncomeExpenseEvent{
  TotalIncomeExpenseLoadEvent();
}

class TotalIncomeExpenseDoneEvent extends TotalIncomeExpenseEvent {
  final BuildContext context;

  TotalIncomeExpenseDoneEvent(this.context);
}

class GetDataLoadEvent extends TotalIncomeExpenseEvent{
  final BuildContext context;
  GetDataLoadEvent(this.context);
}
class GetExpenseListEvent extends TotalIncomeExpenseEvent{
  GetExpenseListEvent();
}