abstract class AddTripState {}

class AddTripInitialState extends AddTripState {}

class AddTripEmptyState extends AddTripState{}
class AddTripDataLoading extends AddTripState{}
class AddTripDataLoaded extends AddTripState{}
class GetDataLoadState extends AddTripState{}