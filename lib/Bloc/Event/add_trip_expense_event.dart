import 'package:flutter/src/widgets/framework.dart';

abstract class AddTripExpenseEvent {
  const AddTripExpenseEvent();
}

class AddTripExpenseLoadEvent extends AddTripExpenseEvent {
  BuildContext context;

  AddTripExpenseLoadEvent(this.context);
}

class SaveTripExpanseEvent extends AddTripExpenseEvent {
  BuildContext context;

  SaveTripExpanseEvent(this.context);
}

class DataReload extends AddTripExpenseEvent {
  BuildContext context;

  DataReload(this.context);
}
