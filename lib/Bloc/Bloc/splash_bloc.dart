import 'dart:async';
import 'package:expense_manager/Bloc/Event/splash_event.dart';
import 'package:expense_manager/Bloc/State/splash_state.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(TimerInitial()) {
    on<TimerStarted>(_onStarted);
  }

  void _onStarted(TimerStarted event, Emitter<SplashState> emit) {
    Timer(Duration(seconds: 5), () {
      if (PreferenceUtils.getBool(key: isRegistered)) {
        Navigator.pushNamed(event.context, "/dashboard");
      } else {
        Navigator.pushNamed(event.context, '/select_language');
      }
    });
    emit(TimerRunInProgress());
   }
}
