import 'package:flutter/cupertino.dart';

abstract class TripExpenseEvent {
  const TripExpenseEvent();
}

class TripExpenseDoneEvent extends TripExpenseEvent {
  final BuildContext context;

  TripExpenseDoneEvent(this.context);
}

class GetDataLoadEvent extends TripExpenseEvent{
  GetDataLoadEvent();
}