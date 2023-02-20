import 'package:expense_manager/Bloc/Event/trip_expense_summery_event.dart';
import 'package:expense_manager/Bloc/State/trip_expense_summery_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripExpenseSummeryBloc extends Bloc<TripExpenseSummeryEvent, TripExpenseSummeryState> {
  var personId;
  var tripId;
  List personExpenseList = [];
  List categoryList = [];
  List catwithExpenseList = [];
  bool isLoaded = false;
  var totalExpen = 0.0;

  var beginDate;
  var endDate;
  double? totalUsers;
  int? totalTripExpense;
  String? currency;
  List userList = [];
  var tripData;
  var selectedData;

  TripExpenseSummeryBloc({required var this.selectedData}) : super(TripExpenseSummeryEmptyState()) {
    on<TripExpenseSummeryLoadEvent>(_onDataLoadState);
    on<GetDataEvent>(_onGetData);
  }

  _onDataLoadState(TripExpenseSummeryLoadEvent event, Emitter<TripExpenseSummeryState> emit) async {
    PreferenceUtils.init();
    currency = PreferenceUtils.getString(key: selectedCurrency);
    tripId = selectedData["tripId"];
    totalTripExpense = selectedData["total_expense"];
    beginDate = selectedData['${DatabaseHelper.colTripFromDate}'];
    endDate = selectedData['${DatabaseHelper.colTripToDate}'];
    print("personID :- $personId");
    BlocProvider.of<TripExpenseSummeryBloc>(event.context).add(GetDataEvent(event.context));
  }

  _onGetData(GetDataEvent event, Emitter<TripExpenseSummeryState> emit) async {
    totalExpen = 0.0;
    personExpenseList = await dbHelper.queryStringRow(
        tableName: DatabaseHelper.tblTripExpense, query: '${DatabaseHelper.colTripId} = $tripId  GROUP BY ${DatabaseHelper.colDateCreated}');
    print(personExpenseList);

    categoryList = await dbHelper.getSingleDataWithGroupBy(
      tableName: DatabaseHelper.tblTripExpense,
      selectedValue: "${DatabaseHelper.colTripCategoryName}",
      matchId: "${DatabaseHelper.colTripId}",
      id: "$tripId",
      groupBy: "${DatabaseHelper.colTripCategoryName}",
    );

    catwithExpenseList = await dbHelper.getGroupBYSum(
      tableName: DatabaseHelper.tblTripExpense,
      sumName: "${DatabaseHelper.colTripExpAmount}",
      matchId: "${DatabaseHelper.colTripId}",
      id: "$tripId",
      groupBy: "${DatabaseHelper.colTripCategoryName}",
    );

    print("Category List " + categoryList.toString());
    print("Category With Expense List " + catwithExpenseList.toString());

    var totalExpense;
    await dbHelper.sumOfSummaryColumn(tableName: DatabaseHelper.tblTripExpense, columnName: '${DatabaseHelper.colTripExpAmount}').then((value) {
      if (value != null) {
        totalExpense = value as double;
      } else {
        totalExpense = 00.00;
      }
    });

    print(" Trip Total Expense Is $totalExpense");
    totalExpen = totalExpense;

    userList.clear();
    print(" ------------ summary pdf -------------");
    List data = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTrip, query: '${DatabaseHelper.colId} = $tripId');
    tripData = data[0];

    List userdata = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colTripId} = $tripId');
    List sumOfUserData = await dbHelper.getGroupTotalExpense(
      sumName: '${DatabaseHelper.colTripUserPart}',
      tableName: DatabaseHelper.tblTripUsers,
      matchId: '${DatabaseHelper.colTripId}',
      id: '$tripId',
    );
    print("sumOfUserData ${sumOfUserData[0]['total']}");
    totalUsers = sumOfUserData[0]['total'];
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
          total = value as int?;
        } else {
          total = 00;
        }
      });
      userList.add({'data': i, 'expense': total});
      print(total);
    }

    for (int i = 0; i < personExpenseList.length; i++) {
      totalExpen = totalExpen + int.parse(personExpenseList[i]['${DatabaseHelper.colTripExpAmount}'].toString());
    }

    isLoaded = true;

    emit(TripExpenseSummeryDataLoaded());
  }
}
