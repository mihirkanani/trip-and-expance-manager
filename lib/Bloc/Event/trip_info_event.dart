import 'package:flutter/material.dart';

abstract class EditTripInfoEvent {
  const EditTripInfoEvent();
}

class EditTripInfoDataLoadEvent extends EditTripInfoEvent {
  EditTripInfoDataLoadEvent();
}

class GetDataLoadEvent extends EditTripInfoEvent {
  GetDataLoadEvent();
}

class UpdateTripExpenseEvent extends EditTripInfoEvent {
 final tripId, tripPart, personData, increment;
 final BuildContext context;
  UpdateTripExpenseEvent(this.tripId,this.tripPart,this.personData,this.increment,this.context);
}
