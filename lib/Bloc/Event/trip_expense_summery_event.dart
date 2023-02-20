import 'package:flutter/src/widgets/framework.dart';

abstract class TripExpenseSummeryEvent {
  const TripExpenseSummeryEvent();
}

class DataReload extends TripExpenseSummeryEvent {
  BuildContext context;

  DataReload(this.context);
}

class TripExpenseSummeryLoadEvent extends TripExpenseSummeryEvent {
  BuildContext context;

  TripExpenseSummeryLoadEvent(this.context);
}

class GetDataLoadEvent extends TripExpenseSummeryEvent {
  BuildContext context;

  GetDataLoadEvent(this.context);
}

class GetDataEvent extends TripExpenseSummeryEvent {
  BuildContext context;

  GetDataEvent(this.context);
}