import 'package:flutter/material.dart';

abstract class TripListEvent {
  const TripListEvent();
}

class TripListLoadEvent extends TripListEvent {
  BuildContext context;

  TripListLoadEvent(this.context);
}

class GetTripDataEvent extends TripListEvent {
  BuildContext context;

  GetTripDataEvent(this.context);
}

class GetGroupInfoEvent extends TripListEvent {
  BuildContext context;

  GetGroupInfoEvent(this.context);
}

class GetUserInfoEvent extends TripListEvent {
  BuildContext context;

  GetUserInfoEvent(this.context);
}

class UpdatePersonEvent extends TripListEvent {
  BuildContext context;
  var TripId;

  UpdatePersonEvent(this.context,this.TripId);
}

class ChangeDateAndTimeEvent extends TripListEvent {
  BuildContext context;

  ChangeDateAndTimeEvent(this.context);
}
