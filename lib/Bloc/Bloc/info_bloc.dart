import 'package:expense_manager/Bloc/Event/info_event.dart';
import 'package:expense_manager/Bloc/State/info_state.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState>{
  final introKey = GlobalKey<IntroductionScreenState>();

  InfoBloc():super(InfoInitialState()){
    on<InfoDoneEvent>((event, emit){
      PreferenceUtils.setBool(key: isRegistered, value: true);
      Navigator.pushNamed(event.context, "/dashboard");
    });
  }
}