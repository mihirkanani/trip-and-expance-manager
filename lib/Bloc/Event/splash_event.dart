import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SplashEvent {
  const SplashEvent();
}

class TimerStarted extends SplashEvent {
  BuildContext context;

  TimerStarted(this.context);
}
