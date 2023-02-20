import 'package:expense_manager/Bloc/Event/trip_expense_event.dart';
import 'package:expense_manager/Bloc/State/trip_expense_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripExpenseBloc extends Bloc<TripExpenseEvent, TripExpenseState> {
  List onGoingTrips = [];
  List onUsersList = [];
  List onGroupList = [];
  List pastTrips = [];
  List upComingTrips = [];
  bool isLoaded = false;
  List users = [];

  TripExpenseBloc() : super(TripExpenseInitialState()) {
    on<GetDataLoadEvent>(_getData);
  }

  _getData(GetDataLoadEvent event, Emitter<TripExpenseState> emit) async {
    onGoingTrips = [];
    pastTrips = [];
    upComingTrips = [];
    int now = DateTime.now().millisecondsSinceEpoch;
    users = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblTripUsers,
    );
    var tripusers = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblTrip,
    );

    for (var u in tripusers) {
      var formDate =
          DateTime.fromMillisecondsSinceEpoch(u[DatabaseHelper.colTripFromDate]).difference(DateTime.fromMillisecondsSinceEpoch(now)).inDays;
      var toDate = DateTime.fromMillisecondsSinceEpoch(u[DatabaseHelper.colTripToDate]).difference(DateTime.fromMillisecondsSinceEpoch(now)).inDays;
      var yesterDate = DateTime.fromMillisecondsSinceEpoch(now).add(const Duration(days: -1));
      var ysterDateCheck = DateTime.fromMillisecondsSinceEpoch(u[DatabaseHelper.colTripToDate]).difference(yesterDate).inDays;
      var tommorowDate = DateTime.fromMillisecondsSinceEpoch(now).add(const Duration(days: 1));
      var tommorowDateCheck = DateTime.fromMillisecondsSinceEpoch(u[DatabaseHelper.colTripFromDate]).difference(tommorowDate).inDays;
      var currentDateCheckWithFromDate = (DateTime.fromMillisecondsSinceEpoch(u[DatabaseHelper.colTripToDate])).toString().split(" ").first;
      var todayDateIs = DateTime.now().toString().split(" ").first;
      bool currentDateIsEqualToFromDate = currentDateCheckWithFromDate == todayDateIs ? true : false;
      if (formDate == 0 || toDate == 0 || toDate > 0 && formDate < 0 || currentDateIsEqualToFromDate) {
        if (ysterDateCheck != 0 || currentDateIsEqualToFromDate) {
          if (tommorowDateCheck != 0 || currentDateIsEqualToFromDate) {
            onGoingTrips.add(u);
          } else {
            upComingTrips.add(u);
          }
        } else if (ysterDateCheck < 0) {
          pastTrips.add(u);
        } else {
          upComingTrips.add(u);
        }
      } else if (formDate < 0 || toDate < 0) {
        pastTrips.add(u);
      } else if (formDate > 0 || toDate > 0) {
        upComingTrips.add(u);
      } else {
      }
    }
    pastTrips.reversed;
    onGoingTrips.reversed;
    onGroupList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblGroupExpense,
    );
    onUsersList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblUsers,
    );
    isLoaded = true;
    emit(TripExpenseLoaded());
  }
}
