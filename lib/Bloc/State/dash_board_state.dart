abstract class DashBoardState {}

class DashBoardInitialState extends DashBoardState {
  DashBoardInitialState();
}

class DashBoardInitialStateLoaded extends DashBoardState {
  DashBoardInitialStateLoaded();
}

class ShowCaseDashboardState extends DashBoardState {
  ShowCaseDashboardState();
}

class WithoutShowCaseDashboardState extends DashBoardState {
  WithoutShowCaseDashboardState();
}

class DashBoardShowAccountState extends DashBoardState {
  DashBoardShowAccountState();
}
class DashBoardTabChangeState extends DashBoardState {
  DashBoardTabChangeState();
}
