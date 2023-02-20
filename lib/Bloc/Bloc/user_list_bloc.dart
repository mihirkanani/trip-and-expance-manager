import 'dart:convert';
import 'package:expense_manager/Bloc/Event/user_list_event.dart';
import 'package:expense_manager/Bloc/State/user_list_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  String userName = "";
  String userProfile = "";
  List onUsersList = [];
  List onUserExpense = [];
  List onUserDelete = [];
  var defaultImgBytes;
  var personDiffe = 0.0;
  var totalperHead = 0.0;
  List perHeadTrip1 = [];
  List perHeadTrip2 = [];
  List<double> diffe3 = [];
  var totalperhead22 = 0.0;
  var totalDifffge = 0.0;

  UserListBloc() : super(UserListInitialState()) {
    on<UserListLoadEvent>(_onInitialState);
    on<GetUserDataEvent>(_onGetUserDataState);
    on<SetDataEvent>(_onSetDataState);
    on<AddPersonEvent>(_onAddPersonState);
    on<UpdatePersonEvent>(_onUpdatePersonState);
  }

  _onInitialState(UserListLoadEvent event, Emitter<UserListState> emit) {
    PreferenceUtils.init();
    BlocProvider.of<UserListBloc>(event.context).add(GetUserDataEvent(event.context));
  }

  _onGetUserDataState(GetUserDataEvent event, Emitter<UserListState> emit) async {
    onUserExpense.clear();
    diffe3.clear();
    perHeadTrip1.clear();
    onUserDelete.clear();
    onUsersList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblUsers,
    );
    for (var user in onUsersList) {
      var groupl = await dbHelper.getGroupTotalExpense(
        sumName: '${DatabaseHelper.colTripExpAmount}',
        tableName: '${DatabaseHelper.tblTripExpense}',
        matchId: '${DatabaseHelper.colUserId}',
        id: user['${DatabaseHelper.colUserId}'],
      );

      onUserExpense.add(groupl[0]['total'] == null ? 0.0 : groupl[0]['total']);

      var deleteUser = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colUserId} = ${user['${DatabaseHelper.colUserId}']}');

      onUserDelete.add(deleteUser);

      var groupIdList = await dbHelper.getGroupBYData(
          tableName: DatabaseHelper.tblTripUsers,
          matchId: DatabaseHelper.colUserId,
          id: '${user['${DatabaseHelper.colUserId}']}',
          groupBy: DatabaseHelper.colGroupId);
      List tripUserlength = [];
      List tripExpense = [];
      List tripAmount = [];
      var perHeadUser;
      double finaldiff = 0.0;
      for (var group in groupIdList) {
        var tripid = await dbHelper.getGroupBWithMultipleCondition(
          tableName: '${DatabaseHelper.tblTripUsers}',
          matchId: '${DatabaseHelper.colGroupId}',
          id: '${group[DatabaseHelper.colGroupId]}',
          matchId2: '${DatabaseHelper.colUserId}',
          id2: '${user['${DatabaseHelper.colUserId}']}',
          groupBy: '${DatabaseHelper.colTripId}',
        );

        for (var trip in tripid) {
          var diffance = await dbHelper.queryStringRow(
              tableName: '${DatabaseHelper.tblTripUsers}', query: "${DatabaseHelper.colTripId} == ${trip['${DatabaseHelper.colTripId}']}");

          var totalExpenseGroup = await dbHelper.getGroupTotalExpense(
            tableName: '${DatabaseHelper.tblTripExpense}',
            sumName: '${DatabaseHelper.colTripExpAmount}',
            matchId: '${DatabaseHelper.colTripId}',
            id: '${trip['${DatabaseHelper.colTripId}']}',
          );

          tripExpense.add(totalExpenseGroup[0]['total']);

          var groupAmopunt = await dbHelper.getGroupAmountCondition(
            tableName: '${DatabaseHelper.tblTripExpense}',
            sumName: '${DatabaseHelper.colTripExpAmount}',
            matchId: '${DatabaseHelper.colTripId}',
            id: '${trip['${DatabaseHelper.colTripId}']}',
            matchId2: '${DatabaseHelper.colGroupId}',
            id2: '${diffance[0]['${DatabaseHelper.colGroupId}']}',
            matchId3: '${DatabaseHelper.colUserId}',
            id3: '${user['${DatabaseHelper.colUserId}']}',
          );

          tripAmount.add(groupAmopunt[0]['sum']);

          var sumofAllPart = await dbHelper.sumOfSummaryColumn(
              columnName: "${DatabaseHelper.colTripUserPart}",
              tableName: "${DatabaseHelper.tblTripUsers}",
              matchId: "${DatabaseHelper.colTripId}",
              id: "${trip['${DatabaseHelper.colTripId}']}");

          var sumofUserpart = await dbHelper.sumOfSummaryWithUserColumn(
              columnName: "${DatabaseHelper.colTripUserPart}",
              tableName: "${DatabaseHelper.tblTripUsers}",
              matchId: "${DatabaseHelper.colTripId}",
              id: "${trip['${DatabaseHelper.colTripId}']}",
              matchId2: "${DatabaseHelper.colUserId}",
              id2: '${user['${DatabaseHelper.colUserId}']}');

          var sumOfTripAmount = await dbHelper.copysumOfSummaryWithUserColumn(
              columnName: "${DatabaseHelper.colTripExpAmount}",
              tableName: "${DatabaseHelper.tblTripExpense}",
              matchId: "${DatabaseHelper.colTripId}",
              id: "${trip['${DatabaseHelper.colTripId}']}",
              matchId2: "${DatabaseHelper.colUserId}",
              id2: '${user['${DatabaseHelper.colUserId}']}');

          // print(
          //     "SumOf User Part $sumofAllPart and $sumofUserpart and ${totalExpenseGroup[0]['total']} and Trip Amount $sumOfTripAmount");
          if (sumofUserpart != null) {
            perHeadUser = (totalExpenseGroup[0]['total'] == null ? 0.0 : totalExpenseGroup[0]['total'] / sumofAllPart) * sumofUserpart;
            finaldiff = double.parse(sumOfTripAmount == null ? '0' : sumOfTripAmount.toString()) - perHeadUser;
          }

          totalperhead22 = totalperhead22 += perHeadUser == null ? 0.0 : perHeadUser;
          totalDifffge = totalDifffge += finaldiff == null ? 0.0 : finaldiff;
        }
      }
      diffe3.add(totalDifffge == null ? 0.0 : totalDifffge);
      perHeadTrip1.add(totalperhead22 == null ? 0.0 : totalperhead22);
      totalperhead22 = 0.0;
      totalDifffge = 0.0;
    }
    BlocProvider.of<UserListBloc>(event.context).add(SetDataEvent(event.context));
  }

  _onSetDataState(SetDataEvent event, Emitter<UserListState> emit) async {
    ByteData bytes = await rootBundle.load('assets/images/defaultPersonImg.png');
    var buffer = bytes.buffer;
    defaultImgBytes = base64.encode(Uint8List.view(buffer));
    emit(UserListDataLoaded());
  }

  _onAddPersonState(AddPersonEvent event, Emitter<UserListState> emit) async {
    Map<String, dynamic> row = {DatabaseHelper.colUserName: userName, DatabaseHelper.colUserProfile: userProfile, DatabaseHelper.colUserExpense: ''};

    await dbHelper.insert(row: row, tableName: DatabaseHelper.tblUsers);
    BlocProvider.of<UserListBloc>(event.context).add(GetUserDataEvent(event.context));
  }

  _onUpdatePersonState(UpdatePersonEvent event, Emitter<UserListState> emit) async {
    Map<String, dynamic> row = {DatabaseHelper.colUserName: userName, DatabaseHelper.colUserProfile: userProfile, DatabaseHelper.colUserExpense: ''};

    await dbHelper.updateArg(row: row, tableName: DatabaseHelper.tblUsers, id: event.userId, whereId: DatabaseHelper.colUserId);
    await dbHelper.updateUserName(
      userName: DatabaseHelper.colTripUserName,
      updateName: userName,
      userId: DatabaseHelper.colUserId,
      selectedUserId: event.userId.toString(),
      tableName: DatabaseHelper.tblTripExpense,
    );
    await dbHelper.updateTripUserName(
      userName: DatabaseHelper.colTripUserName,
      updateName: userName,
      userProfile: DatabaseHelper.colTripUserProfile,
      updateProfile: userProfile,
      userId: DatabaseHelper.colUserId,
      selectedUserId: event.userId.toString(),
      tableName: DatabaseHelper.tblTripUsers,
    );
    BlocProvider.of<UserListBloc>(event.context).add(GetUserDataEvent(event.context));
  }
}
