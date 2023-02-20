abstract class TripInfoState {}

class TripInfoInitialState extends TripInfoState {}

class TripInfoEmptyState extends TripInfoState{}
class TripInfoLoading extends TripInfoState{}
class TripInfoLoaded extends TripInfoState{}
class GetDataLoadState extends TripInfoState{}