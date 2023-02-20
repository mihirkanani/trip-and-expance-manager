
import 'package:flutter/material.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class HomeDataLoadEvent extends HomeEvent{
  BuildContext context;
  HomeDataLoadEvent(this.context);
}

class GetDataLoadEvent extends HomeEvent{
  GetDataLoadEvent();
}