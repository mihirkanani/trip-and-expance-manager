import 'package:expense_manager/Bloc/Event/Person_expense_summary_event.dart';
import 'package:expense_manager/Bloc/State/Person_expense_summary_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonExpenseSummaryBloc extends Bloc<PersonExpenseSummaryEvent, PersonExpenseSummaryState> {
  var personId;
  var tripId;
  var userId;
  var userName;
  List personExpenseList = [];
  bool isLoaded = false;
  var totalExpen = 0;
  var sumofUserpart;
  int? totalUsers;
  double? perHead;
  int? totalExpense;
  var tripData;
  List userList = [];
  List expenseList = [];
  var selectedData;
  var beginDate;
  var endDate;

  PersonExpenseSummaryBloc({required var this.selectedData}) : super(PersonExpenseSummaryEmptyState()) {
    on<PersonExpenseSummaryLoadEvent>(_onDataLoadState);
    on<GetDataEvent>(_onGetData);
  }

  _onDataLoadState(PersonExpenseSummaryLoadEvent event, Emitter<PersonExpenseSummaryState> emit) {
    PreferenceUtils.init();
    personId = selectedData["personId"];
    tripId = selectedData["tripId"];
    userId = selectedData["userId"];
    userName = selectedData["personName"];
    beginDate = selectedData['${DatabaseHelper.colTripFromDate}'];
    endDate = selectedData['${DatabaseHelper.colTripToDate}'];
    print("personID :- $personId");
    BlocProvider.of<PersonExpenseSummaryBloc>(event.context).add(GetDataEvent(event.context));
  }

  _onGetData(GetDataEvent event, Emitter<PersonExpenseSummaryState> emit) async {
    userList.clear();
    totalExpen = 0;
    personExpenseList = await dbHelper.queryStringRow(
        tableName: DatabaseHelper.tblTripExpense,
        query: '${DatabaseHelper.colTripId} = $tripId AND ${DatabaseHelper.colUserId} = $personId  GROUP BY ${DatabaseHelper.colDateCreated}');
    print("Person Expense" + personExpenseList.toString());

    for (int i = 0; i < personExpenseList.length; i++) {
      totalExpen = totalExpen + int.parse(personExpenseList[i]['${DatabaseHelper.colTripExpAmount}'].toString());
    }

    List data = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTrip, query: '${DatabaseHelper.colId} = $tripId');
    tripData = data[0];
    List userdata = await dbHelper.queryStringRow(
        tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colTripId} = $tripId AND ${DatabaseHelper.colUserId} = $userId');
    print("user list ............$userList");
    List userLength = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colTripId} = $tripId');
    print("user list ............$userList");
    totalUsers = userLength.length;
    for (var i in userdata) {
      int? total;
      await dbHelper
          .copysumOfSummaryWithUserColumn(
        tableName: DatabaseHelper.tblTripExpense,
        columnName: DatabaseHelper.colTripExpAmount,
        matchId: '${DatabaseHelper.colUserId}',
        id: i['${DatabaseHelper.colUserId}'].toString(),
        matchId2: '${DatabaseHelper.colTripId}',
        id2: '$tripId',
      )
          .then((value) {
        if (value != null) {
          total = value as int;
        } else {
          total = 0;
        }
      });
      userList.add({'data': i, 'expense': total});
      print(total);
    }

    await dbHelper.sumOfTripExpense(columnName: DatabaseHelper.colTripExpAmount, tripId: tripId).then((value) {
      if (value != null) {
        totalExpense = value as int?;
      } else {
        totalExpense = 00;
      }
    });
    print("total ---- $totalExpense......$totalUsers");
    expenseList = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTripExpense, query: '${DatabaseHelper.colTripId} = $tripId');
    print(expenseList);
    perHead = totalExpense! / totalUsers!;

    sumofUserpart = await dbHelper.sumOfSummaryColumn(
      columnName: "${DatabaseHelper.colTripUserPart}",
      tableName: "${DatabaseHelper.tblTripUsers}",
      matchId: "${DatabaseHelper.colTripId}",
      id: "$tripId",
    );

    isLoaded = true;
    emit(PersonExpenseSummaryDataLoaded());
  }
}
