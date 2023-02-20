import 'package:flutter/src/widgets/framework.dart';

abstract class PersonExpenseSummaryEvent {
  const PersonExpenseSummaryEvent();
}

class DataReload extends PersonExpenseSummaryEvent {
  BuildContext context;

  DataReload(this.context);
}

class PersonExpenseSummaryLoadEvent extends PersonExpenseSummaryEvent {
  BuildContext context;

  PersonExpenseSummaryLoadEvent(this.context);
}
class GetDataEvent extends PersonExpenseSummaryEvent {
  BuildContext context;

  GetDataEvent(this.context);
}

class GetDataLoadEvent extends PersonExpenseSummaryEvent {
  BuildContext context;

  GetDataLoadEvent(this.context);
}