import 'package:expense_manager/Bloc/Event/user_expense_event.dart';
import 'package:expense_manager/Bloc/State/user_expense_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/pref_util.dart';
import 'package:collection/collection.dart';

class UserExpenseBloc extends Bloc<UserExpenseEvent, UserExpenseState> {
  List onUserList = [];
  List<int> onSumList = [];
  List onUserProfile = [];
  var totalExpense;
  bool isLoaded = false;
  double? diff;
  double totalPerHead = 0;
  var perHead;
  double? value;
  List diffe3 = [];
  List personDiffe = [];
  List perHeadTrip = [];
  int? groupId;
  String? groupName;

  UserExpenseBloc({required this.groupId, required this.groupName}) : super(UserExpenseInitialState()) {
    on<UserExpenseLoadEvent>(_onInitialState);
    on<GetUserExpenseDataEvent>(_onUserExpenseDataState);
  }

  _onInitialState(UserExpenseLoadEvent event, Emitter<UserExpenseState> emit) {
    PreferenceUtils.init();
    BlocProvider.of<UserExpenseBloc>(event.context).add(GetUserExpenseDataEvent(event.context));
  }

  _onUserExpenseDataState(GetUserExpenseDataEvent event, Emitter<UserExpenseState> emit) async {
    totalPerHead = 0;
    onUserProfile.clear();
    onSumList.clear();
    personDiffe.clear();
    perHeadTrip.clear();
    onUserList = await dbHelper.getGroupBYData(
        tableName: DatabaseHelper.tblTripUsers, matchId: DatabaseHelper.colGroupId, id: groupId, groupBy: DatabaseHelper.colUserId);

    for (var group in onUserList) {
      var groupl = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblUsers, query: "${DatabaseHelper.colUserId} == ${group[DatabaseHelper.colUserId]}");
      onUserProfile.add(groupl[0]);

      var sumlist = await dbHelper.getGroupBYSumWithMultipleCondition(
        sumName: DatabaseHelper.colTripExpAmount,
        tableName: DatabaseHelper.tblTripExpense,
        matchId: DatabaseHelper.colGroupId,
        id: groupId,
        id2: group[DatabaseHelper.colUserId],
        matchId2: DatabaseHelper.colUserId,
        groupBy: DatabaseHelper.colUserId,
      );
      onSumList.add(sumlist.length > 0 ? sumlist[0]['total'] : 0);
      perHead = onSumList.sum / onUserList.length;

      print("Username is ${group['${DatabaseHelper.colTripUserName}']}");
      // Find Trip Id on User
      var tripUserPart = await dbHelper.getMultiDifferent(
        tableName: DatabaseHelper.tblTripUsers,
        matchId: DatabaseHelper.colGroupId,
        id: groupId,
        id2: group[DatabaseHelper.colUserId],
        matchId2: DatabaseHelper.colUserId,
      );

      // Find Total Expense
      var tripUserPart1 = await dbHelper.getGroupBWithMultipleCondition(
        tableName: DatabaseHelper.tblTripUsers,
        matchId: DatabaseHelper.colGroupId,
        id: groupId,
        id2: group[DatabaseHelper.colUserId],
        matchId2: DatabaseHelper.colUserId,
        groupBy: DatabaseHelper.colTripId,
      );

      print(" Trip Userpart .......${tripUserPart1.length}");
      List tripUserPartTotal = [];
      List tripTotalExpense = [];
      List tripExpenseAmount = [];
      List tripUserPartAmount = [];
      List tripUserAmountDiffe = [];
      List perHEad = [];
      for (var trip in tripUserPart1) {
        // Trip User Part
        var tripUserPart = await dbHelper.getSingleViewMultiDifferent(
          tableName: DatabaseHelper.tblTripUsers,
          matchId: DatabaseHelper.colUserId,
          id: "${group[DatabaseHelper.colUserId]}",
          id2: "${trip['${DatabaseHelper.colTripId}']}",
          matchId2: DatabaseHelper.colTripId,
        );
        tripUserPartAmount.add(tripUserPart[0]['total']);

        //TRip Total User Part
        var tripTotalPart = await dbHelper.getGroupTotalExpense(
          sumName: "${DatabaseHelper.colTripUserPart}",
          tableName: DatabaseHelper.tblTripUsers,
          matchId: DatabaseHelper.colTripId,
          id: "${trip['${DatabaseHelper.colTripId}']}",
        );

        tripUserPartTotal.add(tripTotalPart[0]['total']);

        //Trip Total Expense
        var tripExpense = await dbHelper.getGroupTotalExpense(
          sumName: "${DatabaseHelper.colTripExpAmount}",
          tableName: DatabaseHelper.tblTripExpense,
          matchId: DatabaseHelper.colTripId,
          id: "${trip['${DatabaseHelper.colTripId}']}",
        );
        tripTotalExpense.add(tripExpense[0]['total']);

        // Trip Paid User Value
        var tripAmountAdd = await dbHelper.getSumWithTwoWhereCondition(
          sumName: "${DatabaseHelper.colTripExpAmount}",
          tableName: DatabaseHelper.tblTripExpense,
          matchId: DatabaseHelper.colTripId,
          id: "${trip['${DatabaseHelper.colTripId}']}",
          matchId2: DatabaseHelper.colUserId,
          id2: "${group['${DatabaseHelper.colUserId}']}",
        );
        tripExpenseAmount.add(tripAmountAdd[0]['total'] == null ? 0 : tripAmountAdd[0]['total']);

        // calculator part
        var perHeadUser = (tripExpense[0]['total'] == null ? 0.0 : tripExpense[0]['total'] / tripTotalPart[0]['total']) * tripUserPart[0]['total'];
        double finaldiff = double.parse(tripAmountAdd[0]['total'] == null ? '0' : tripAmountAdd[0]['total'].toString()) - perHeadUser;
        tripUserAmountDiffe.add(finaldiff.toStringAsFixed(2));
        perHEad.add(perHeadUser);
      }

      var summation = 0.0;
      var trpiPerHead = 0.0;
      for (var i = 0; i < tripUserAmountDiffe.length; i++) {
        summation += num.parse(tripUserAmountDiffe[i].toString());
      }
      personDiffe.add(summation);
      for (var i = 0; i < perHEad.length; i++) {
        trpiPerHead += num.parse(perHEad[i].toString());
      }
      perHeadTrip.add(trpiPerHead);
    }

    for (var i = 0; i < perHeadTrip.length; i++) {
      totalPerHead += num.parse(perHeadTrip[i].toString());
    }
    print(" Diffreance is ${perHeadTrip}");
    emit(UserExpenseDataLoaded());
  }
}
