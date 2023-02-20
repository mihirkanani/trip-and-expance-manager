import 'package:expense_manager/Bloc/Event/group_list_event.dart';
import 'package:expense_manager/Bloc/State/group_list_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  String groupName = "";
  var userInfo;
  var userTotalExpense = 0;
  List onGroupList = [];
  List<int> onSumList = [];
  List onExpense = [];
  List paid = [];
  List perHeadTrip1 = [];
  List duplicateperHeadTrip1 = [];
  List perHeadTrip2 = [];
  List<double> diffe3 = [];
  var totalExpense;
  bool isLoaded = false;
  var personDiffe = 0.0;
  var totalperHead = 0.0;

  var totalPerHead = 0.0;
  var value = 0.0;

  var backOption;
  List allTripInfo = [];
  List allTripInfoLength = [];
  int? userId;
  int? userExpense;
  List alltripTotalAmount = [];
  List alltripTotalAmount2 = [];
  List allAmountinPerHEad = [];

  GroupListBloc({required this.userId, required this.userExpense}) : super(GroupListInitialState()) {
    on<GroupListLoadEvent>(_onInitialState);
    on<GetGroupDataEvent>(_onGetGroupState);
  }

  _onInitialState(GroupListLoadEvent event, Emitter<GroupListState> emit){
    PreferenceUtils.init();
    BlocProvider.of<GroupListBloc>(event.context).add(GetGroupDataEvent(event.context));
  }

  _onGetGroupState(GetGroupDataEvent event, Emitter<GroupListState> emit) async {
    personDiffe = 0.0;
    userTotalExpense = 0;
    totalperHead = 0.0;
    diffe3 = [];
    paid = [];
    totalPerHead = 0.0;
    value = 0.0;
    duplicateperHeadTrip1.clear();
    // onUserProfile.clear();
    onGroupList.clear();
    onExpense.clear();
    perHeadTrip1.clear();
    allTripInfoLength.clear();
    userInfo = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblUsers, query: "${DatabaseHelper.colUserId} = ${userId}");

    var groupIdList = await dbHelper.getGroupBYData(
        tableName: DatabaseHelper.tblTripUsers, matchId: DatabaseHelper.colUserId, id: userId, groupBy: DatabaseHelper.colGroupId);

    for (var group in groupIdList) {
      var groupl = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblGroupExpense, query: "${DatabaseHelper.colGroupId} == ${group[DatabaseHelper.colGroupId]}");

      onGroupList.add(groupl[0]);

      var paidValue = await dbHelper.getSumWithTwoWhereCondition(
          tableName: '${DatabaseHelper.tblTripExpense}',
          sumName: '${DatabaseHelper.colTripExpAmount}',
          matchId: '${DatabaseHelper.colGroupId}',
          id: group['${DatabaseHelper.colGroupId}'],
          matchId2: '${DatabaseHelper.colUserId}',
          id2: userInfo[0]["${DatabaseHelper.colUserId}"]);

      paid.add(paidValue[0]['total'] == null ? 0 : paidValue[0]['total']);

      userTotalExpense = userTotalExpense += (paidValue[0]['total'] == null ? 0 : int.parse(paidValue[0]['total'].toString()));
      var tripid = await dbHelper.getGroupBWithMultipleCondition(
          tableName: '${DatabaseHelper.tblTripUsers}',
          matchId: '${DatabaseHelper.colGroupId}',
          id: '${group[DatabaseHelper.colGroupId]}',
          matchId2: '${DatabaseHelper.colUserId}',
          id2: '${userId}',
          groupBy: '${DatabaseHelper.colTripId}');

      allTripInfo.add(tripid);
      List tripUserlength = [];
      List tripExpense = [];
      List tripAmount = [];
      var perHeadUser;
      allTripInfoLength.add(tripid.length);
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
          perHeadUser = (totalExpenseGroup[0]['total'] == null ? 0.0 : totalExpenseGroup[0]['total'] / sumofAllPart) * sumofUserpart;
          double finaldiff = double.parse(sumOfTripAmount == null ? '0' : sumOfTripAmount.toString()) - perHeadUser;
          print("User Diffrenace is $finaldiff");
          diffe3.add(finaldiff);
          perHeadTrip1.add(perHeadUser);
          duplicateperHeadTrip1.add(perHeadUser == null ? 0.0 : perHeadUser);
        }
      }

      var expense = await dbHelper.getGroupTotalExpense(
          sumName: '${DatabaseHelper.colTripExpAmount}',
          tableName: '${DatabaseHelper.tblTripExpense}',
          matchId: '${DatabaseHelper.colGroupId}',
          id: group['${DatabaseHelper.colGroupId}']);
      onExpense.add(expense[0]['total'] == null ? 0.0 : expense[0]['total']);
    }

    bool vvas = true;
    for (var i = 0; i < allTripInfo.length; i++) {
      print("Here isss --- ${allTripInfo[i].length}");
      for (var tripList in allTripInfo[i]) {
        vvas = true;
        print("Here isss22 --- ${tripList['${DatabaseHelper.colTripId}']}");
      }
      vvas = false;
    }

    for (var i = 0; i < diffe3.length; i++) {
      personDiffe += num.parse(diffe3[i].toString());
    }
    for (var i = 0; i < perHeadTrip1.length; i++) {
      totalperHead += num.parse(perHeadTrip1[i].toString());
    }
    perHeadTrip2.add(totalperHead);

    totalPerHead = 0.0;

    for (var ji in allTripInfoLength) {
      for (var j = 0; j < ji; j++) {
        if (duplicateperHeadTrip1.length == 1) {
          print("Hello I HEre23 ${duplicateperHeadTrip1[0]}");
          totalPerHead = totalPerHead += duplicateperHeadTrip1[0];
          duplicateperHeadTrip1.removeAt(0);
        } else {
          print("Hello I HEre2344 ${duplicateperHeadTrip1[0]}");
          totalPerHead = totalPerHead += duplicateperHeadTrip1[0];
          duplicateperHeadTrip1.removeAt(0);
        }
      }

      print(" Value Is2 $totalPerHead");
      allAmountinPerHEad.add(totalPerHead);
      if (backOption == 'back') {
        allAmountinPerHEad.removeAt(0);
      }
      totalPerHead = 0.0;
    }
    emit(GroupListDataLoaded());
  }
}
