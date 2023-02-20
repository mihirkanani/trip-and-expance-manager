import 'package:expense_manager/Bloc/Event/trip_list_event.dart';
import 'package:expense_manager/Bloc/State/trip_list_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  String groupName = "";
  var groupInformation;
  var groupTotalExpese;
  var groupUserPaid;
  var userInformation;
  var userExpense = 0;
  List onTripExpenseList = [];
  List onTripList = [];
  List onPaidList = [];
  List perPersonList = [];
  List onTotalExpense = [];
  bool isLoaded = false;
  List perhead = [];
  List<double> diffe3 = [];
  var personDiffe = 0.0;
  var totalPerHead = 0.0;

  int? groupId;
  int? userId;
  int? groupUserId;
  bool? group;

  TripListBloc({required this.groupId, required this.userId, required this.groupUserId, required this.group}) : super(TripListInitialState()) {
    on<TripListLoadEvent>(_onInitialState);
    on<GetTripDataEvent>(_onGetGroupState);
    on<GetGroupInfoEvent>(_onGetGroupInfoState);
    on<GetUserInfoEvent>(_onGetUserInfoState);
  }

  _onInitialState(TripListLoadEvent event, Emitter<TripListState> emit) {
    PreferenceUtils.init();
    BlocProvider.of<TripListBloc>(event.context).add(GetTripDataEvent(event.context));
  }

  _onGetGroupState(GetTripDataEvent event, Emitter<TripListState> emit) async {
    diffe3 = [];
    personDiffe = 0.0;
    totalPerHead = 0.0;
    onTripList.clear();
    perPersonList.clear();
    onPaidList.clear();
    onTotalExpense.clear();
    onTripExpenseList = await dbHelper.queryStringRow(
      tableName: DatabaseHelper.tblTripUsers,
      query: '${DatabaseHelper.colGroupId} == ${groupId} AND ${DatabaseHelper.colUserId} == ${userId} GROUP BY ${DatabaseHelper.colTripId}',
    );

    for (var trip in onTripExpenseList) {
      var tripItem =
          await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTrip, query: "${DatabaseHelper.colId} == ${trip[DatabaseHelper.colTripId]}");

      // var tripGroupBy =

      var totalPaid = await dbHelper.getSumWithTwoWhereCondition(
          sumName: '${DatabaseHelper.colTripExpAmount}',
          tableName: '${DatabaseHelper.tblTripExpense}',
          matchId: '${DatabaseHelper.colTripId}',
          id: '${trip[DatabaseHelper.colTripId]}',
          matchId2: '${DatabaseHelper.colUserId}',
          id2: '${userId ?? groupUserId}');

      var totalExpense;
      await dbHelper.sumOfTripExpense(columnName: DatabaseHelper.colTripExpAmount, tripId: trip[DatabaseHelper.colTripId]).then((value) {
        if (value == null) {
          totalExpense = 00;
        } else {
          totalExpense = value;
        }
      });

      List userdata = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colTripId} = ${trip[DatabaseHelper.colTripId]}');

      // userList.addAll(userdata);
      var totalUsers = userdata.length;
      print("total ---- $userdata");
      var expenseList = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblTripExpense, query: '${DatabaseHelper.colTripId} = ${trip[DatabaseHelper.colTripId]}');
      print(expenseList);
      var perHead = totalExpense / totalUsers;
      print(" Per Head Of User $perHead");
      onTripList.add(tripItem[0]);
      // perPersonList.add(perHead);
      onTotalExpense.add(totalExpense);
      perhead.add(perHead);
      onPaidList.add(totalPaid[0]['total'] == null ? 0 : totalPaid[0]['total']);
    }
    group!
        ? BlocProvider.of<TripListBloc>(event.context).add(GetGroupInfoEvent(event.context))
        : BlocProvider.of<TripListBloc>(event.context).add(GetUserInfoEvent(event.context));

    print(" Group List .......${onPaidList}");
    print(" Group List .......${perPersonList}");
    print(" Group List .......${onTotalExpense}");
    print(" Group List .......${onTripList.length}");
  }

  _onGetGroupInfoState(GetGroupInfoEvent event, Emitter<TripListState> emit) async {
    userExpense = 0;
    groupInformation = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblGroupExpense, query: '${DatabaseHelper.colGroupId} = ${groupId}');

    //Group Toal Expense
    groupTotalExpese = await dbHelper.getGroupTotalExpense(
        sumName: '${DatabaseHelper.colTripExpAmount}',
        tableName: '${DatabaseHelper.tblTripExpense}',
        matchId: '${DatabaseHelper.colGroupId}',
        id: groupId);

    // group Paid User Total
    groupUserPaid = await dbHelper.getSumWithTwoWhereCondition(
        tableName: '${DatabaseHelper.tblTripExpense}',
        sumName: '${DatabaseHelper.colTripExpAmount}',
        matchId: '${DatabaseHelper.colGroupId}',
        id: groupId,
        matchId2: '${DatabaseHelper.colUserId}',
        id2: groupUserId);

    var tripid = await dbHelper.getDifferent(
        tableName: '${DatabaseHelper.tblTripUsers}',
        matchId: '${DatabaseHelper.colGroupId}',
        id: '${groupId}',
        groupBy: '${DatabaseHelper.colTripId}');

    List tripUserlength = [];
    List tripExpense = [];
    List tripAmount = [];

    for (var trip in tripid) {
      var diffance = await dbHelper.queryStringRow(
          tableName: '${DatabaseHelper.tblTripUsers}', query: "${DatabaseHelper.colTripId} == ${trip['${DatabaseHelper.colTripId}']}");

      tripUserlength.add(diffance.length);

      var totalExpenseGroup = await dbHelper.getGroupTotalExpense(
          tableName: '${DatabaseHelper.tblTripExpense}',
          sumName: '${DatabaseHelper.colTripExpAmount}',
          matchId: '${DatabaseHelper.colTripId}',
          id: '${trip['${DatabaseHelper.colTripId}']}');

      tripExpense.add(totalExpenseGroup[0]['total']);

      var groupAmopunt = await dbHelper.getGroupAmountCondition(
          tableName: '${DatabaseHelper.tblTripExpense}',
          sumName: '${DatabaseHelper.colTripExpAmount}',
          matchId: '${DatabaseHelper.colTripId}',
          id: '${trip['${DatabaseHelper.colTripId}']}',
          matchId2: '${DatabaseHelper.colGroupId}',
          id2: '${diffance[0]['${DatabaseHelper.colGroupId}']}',
          matchId3: '${DatabaseHelper.colUserId}',
          id3: "${userId}");

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
          id2: "${userId}");

      var sumOfTripAmount = await dbHelper.copysumOfSummaryWithUserColumn(
          columnName: "${DatabaseHelper.colTripExpAmount}",
          tableName: "${DatabaseHelper.tblTripExpense}",
          matchId: "${DatabaseHelper.colTripId}",
          id: "${trip['${DatabaseHelper.colTripId}']}",
          matchId2: "${DatabaseHelper.colUserId}",
          id2: "${userId}");

      print("SumOf User Part $sumofAllPart and $sumofUserpart and ${totalExpenseGroup[0]['total']} and Trip Amount $sumOfTripAmount");
      if (sumofUserpart != null) {
        var perHeadUser = (totalExpenseGroup[0]['total'] == null ? 0.0 : totalExpenseGroup[0]['total'] / sumofAllPart) * sumofUserpart;
        double finaldiff = double.parse(sumOfTripAmount == null ? '0' : sumOfTripAmount.toString()) - perHeadUser;
        print("User Diffrenace is $finaldiff");
        diffe3.add(finaldiff);
        perPersonList.add(perHeadUser);
      }
    }
    for (var i = 0; i < diffe3.length; i++) {
      personDiffe += num.parse(diffe3[i].toString());
    }

    for (var i = 0; i < perPersonList.length; i++) {
      totalPerHead += num.parse(perPersonList[i].toString());
    }
    emit(TripListDataLoaded());
  }

  _onGetUserInfoState(GetUserInfoEvent event, Emitter<TripListState> emit) async {
    userInformation = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblUsers, query: '${DatabaseHelper.colUserId} = ${userId}');
    // User Expense
    var sumlist = await dbHelper.getGroupBYSumWithMultipleCondition(
        sumName: DatabaseHelper.colTripExpAmount,
        tableName: DatabaseHelper.tblTripExpense,
        matchId: DatabaseHelper.colGroupId,
        id: groupId,
        id2: userId,
        matchId2: DatabaseHelper.colUserId,
        groupBy: DatabaseHelper.colUserId);
    userExpense = sumlist.toString() == '[]' ? 0 : sumlist[0]['total'];
    print("Sum Of List $sumlist");

    var tripid = await dbHelper.getDifferent(
        tableName: '${DatabaseHelper.tblTripUsers}',
        matchId: '${DatabaseHelper.colGroupId}',
        id: '${groupId}',
        groupBy: '${DatabaseHelper.colTripId}');

    List tripUserlength = [];
    List tripExpense = [];
    List tripAmount = [];

    for (var trip in tripid) {
      var diffance = await dbHelper.queryStringRow(
          tableName: '${DatabaseHelper.tblTripUsers}', query: "${DatabaseHelper.colTripId} == ${trip['${DatabaseHelper.colTripId}']}");

      tripUserlength.add(diffance.length);

      var totalExpenseGroup = await dbHelper.getGroupTotalExpense(
          tableName: '${DatabaseHelper.tblTripExpense}',
          sumName: '${DatabaseHelper.colTripExpAmount}',
          matchId: '${DatabaseHelper.colTripId}',
          id: '${trip['${DatabaseHelper.colTripId}']}');

      tripExpense.add(totalExpenseGroup[0]['total']);

      var groupAmopunt = await dbHelper.getGroupAmountCondition(
          tableName: '${DatabaseHelper.tblTripExpense}',
          sumName: '${DatabaseHelper.colTripExpAmount}',
          matchId: '${DatabaseHelper.colTripId}',
          id: '${trip['${DatabaseHelper.colTripId}']}',
          matchId2: '${DatabaseHelper.colGroupId}',
          id2: '${diffance[0]['${DatabaseHelper.colGroupId}']}',
          matchId3: '${DatabaseHelper.colUserId}',
          id3: "${userId}");

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
          id2: "${userId}");

      var sumOfTripAmount = await dbHelper.copysumOfSummaryWithUserColumn(
          columnName: "${DatabaseHelper.colTripExpAmount}",
          tableName: "${DatabaseHelper.tblTripExpense}",
          matchId: "${DatabaseHelper.colTripId}",
          id: "${trip['${DatabaseHelper.colTripId}']}",
          matchId2: "${DatabaseHelper.colUserId}",
          id2: "${userId}");

      print("SumOf User Part $sumofAllPart and $sumofUserpart and ${totalExpenseGroup[0]['total']} and Trip Amount $sumOfTripAmount");
      if (sumofUserpart != null) {
        var perHeadUser = (totalExpenseGroup[0]['total'] == null ? 0.0 : totalExpenseGroup[0]['total'] / sumofAllPart) * sumofUserpart;
        double finaldiff = double.parse(sumOfTripAmount == null ? '0' : sumOfTripAmount.toString()) - perHeadUser;
        print("User Diffrenace is $finaldiff");
        diffe3.add(finaldiff);
        perPersonList.add(perHeadUser);
      }
    }
    for (var i = 0; i < diffe3.length; i++) {
      personDiffe += num.parse(diffe3[i].toString());
    }
    for (var i = 0; i < perPersonList.length; i++) {
      totalPerHead += num.parse(perPersonList[i].toString());
    }
    emit(TripListDataLoaded());
  }
}
