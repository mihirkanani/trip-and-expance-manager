import 'package:flutter/cupertino.dart';

abstract class DashBoardEvent {
  const DashBoardEvent();
}

class DashBoardInitialEvent extends DashBoardEvent {
  BuildContext context;

  DashBoardInitialEvent(this.context);
}

class ShowCaseDashboardEvent extends DashBoardEvent {
  ShowCaseDashboardEvent();
}

class WithoutShowCaseDashboardEvent extends DashBoardEvent {
  WithoutShowCaseDashboardEvent();
}

class DashBoardShowAccountEvent extends DashBoardEvent {
  BuildContext context;

  DashBoardShowAccountEvent(this.context);
}
class DashBoardShowCaseDoneEvent extends DashBoardEvent {
  BuildContext context;

  DashBoardShowCaseDoneEvent(this.context);
}
class DashBoardTabChangeEvent extends DashBoardEvent {
  BuildContext context;

  DashBoardTabChangeEvent(this.context);
}

