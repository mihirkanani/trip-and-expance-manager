import 'package:expense_manager/Bloc/Event/trip_info_event.dart';
import 'package:expense_manager/Bloc/State/trip_info_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripInfoBloc extends Bloc<EditTripInfoEvent, TripInfoState> {
  final int tripId;
  int? totalUsers;
  double? perHead;
  double? perUserHead;
  int? totalExpense;
  var tripData;
  bool isLoaded = false;
  List userList = [];
  List? expenseList;
  var sumofUserpart;
  int? interstitialId;
  bool userPartMatch = true;
  List<int> userPart1 = [];
  List testUserData = [];

  TripInfoBloc(this.tripId) : super(TripInfoEmptyState()) {
    on<EditTripInfoDataLoadEvent>(_onDataLoadState);
    on<UpdateTripExpenseEvent>(_updateTripExpense);
  }

  _onDataLoadState(EditTripInfoDataLoadEvent event, Emitter<TripInfoState> emit) async {
    print("==> ${tripId}");
    PreferenceUtils.init();
    userList.clear();
    userPart1 = [];
    List data = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTrip, query: '${DatabaseHelper.colId} = $tripId');
    tripData = data[0];
    List userdata = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colTripId} = $tripId');
    print("user list ............$userList");

    List userpart = await dbHelper.getSingleData(tableName: DatabaseHelper.tblTripUsers);
    print("user part ............$userpart");
    totalUsers = userdata.length;

    for (var i in userdata) {
      int? total;
      await dbHelper.copysumOfSummaryWithUserColumn(
        tableName: DatabaseHelper.tblTripExpense,
        columnName: DatabaseHelper.colTripExpAmount,
        matchId: DatabaseHelper.colUserId,
        id: i[DatabaseHelper.colUserId].toString(),
        matchId2: DatabaseHelper.colTripId,
        id2: '$tripId',
      ).then((value) {
        if(value != null){
          total = value as int;
        }else{
          total = 0;
        }
      });
      userList.add({'data': i, 'expense': total});
      var value = userdata.first[DatabaseHelper.colTripUserPart];

      if (i[DatabaseHelper.colTripUserPart] == value) {
        userPart1.add(0);
        userPartMatch = true;
      } else {
        userPart1.add(1);
        userPartMatch = false;
      }
    }

    totalExpense = (await dbHelper.sumOfTripExpense(columnName: DatabaseHelper.colTripExpAmount, tripId: tripId) ?? 00) as int?;
    expenseList = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTripExpense, query: '${DatabaseHelper.colTripId} = $tripId');
    perHead = totalExpense! / totalUsers!;
    sumofUserpart = await dbHelper.sumOfSummaryColumn(
        columnName: DatabaseHelper.colTripUserPart, tableName: DatabaseHelper.tblTripUsers, matchId: DatabaseHelper.colTripId, id: "$tripId");
    print("Sum Is $sumofUserpart");
    if (sumofUserpart == null) {
      perUserHead = totalExpense == null ? 0.0 : totalExpense! / 0.0;
    } else {
      perUserHead = totalExpense == null ? 0.0 : totalExpense! / sumofUserpart;
    }
    emit(TripInfoLoaded());
    isLoaded = true;
  }

  _updateTripExpense(UpdateTripExpenseEvent event, Emitter<TripInfoState> emit) async {
    int userPart;
    if (event.increment) {
      userPart = await event.personData['${DatabaseHelper.colTripUserPart}'] + 1;
    } else {
      userPart = await event.personData['${DatabaseHelper.colTripUserPart}'] - 1;
    }
    if (userPart < 0) {
      showToast("Please Enter Valid Value");
    } else {
      showLoader(event.context);
      final id = await dbHelper.tripUserPartUpdate(
          tableName: DatabaseHelper.tblTripUsers,
          tripUserPart: "$userPart",
          userId: '${event.personData['${DatabaseHelper.colUserId}']}',
          tripId: "$tripId");
      print('updated row id: $id');
    }
    // await getData();
    Navigator.pop(event.context);
  }
}
