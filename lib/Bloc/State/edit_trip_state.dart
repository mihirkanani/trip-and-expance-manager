abstract class EditTripState {}

class EditTripInitialState extends EditTripState {}

class EditTripEmptyState extends EditTripState{}
class EditTripDataLoading extends EditTripState{}
class EditTripDataLoaded extends EditTripState{}
class GetDataLoadState extends EditTripState{}