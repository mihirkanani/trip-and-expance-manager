import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class TimerInitial extends SplashState {
  const TimerInitial();
}

class TimerRunInProgress extends SplashState {
  const TimerRunInProgress() : super();
}

class TimerRunComplete extends SplashState {
  const TimerRunComplete() : super();
}
