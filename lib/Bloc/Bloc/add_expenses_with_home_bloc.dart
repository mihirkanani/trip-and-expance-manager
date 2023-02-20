import 'package:expense_manager/Bloc/Event/add_expenses_with_home_event.dart';
import 'package:expense_manager/Bloc/State/add_expenses_with_home_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddExpensesWithHomeBloc extends Bloc<AddExpensesWithHomeEvent, AddExpensesWithHomeState> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  var selectedCate;
  var selectPerson;
  List categories = [
    'Shopping',
    'Sport',
    'Entertainment',
    'House',
    'Food',
    'Parking',
    'Medical',
    'Others',
  ];
  var userData;
  Future<DateTime>? datePicker;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  List userList = [];
  TimeOfDay time = TimeOfDay.now();

  AddExpensesWithHomeBloc({required var this.userData}) : super(AddExpensesWithHomeInitialState()) {
    on<AddExpensesWithHomeInitialEvent>(_onInitialState);
    on<InsertExpenseWithHomeEvent>(_onInsertExpanse);
    on<DataReload>(_onDataReload);
// on<AddExpensesForStoreEvent>(_onAddExpenses);
// on<ChangeDateAndTimeEvent>(_onChangeTimeAndDate);
// on<ChangeTabEvent>(_onTabChange);
// on<UpdateCameraDataEvent>(_onCameraDataUpdate);
  }

  _onInitialState(AddExpensesWithHomeInitialEvent event, Emitter<AddExpensesWithHomeState> emit) async {
    PreferenceUtils.init();
      print("trip id ...... $userData ");
      selectedDate = DateTime.now();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print("category ${prefs.getString('category')}");
      selectedCate = prefs.getString('category') == null ? categories[0] : prefs.getString('category');
      print(" User Trip Id ${userData['${DatabaseHelper.colTripId}']}");
      userList.clear();
      userList = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colTripId} = ${userData['${DatabaseHelper.colTripId}']}');
      print("User List $userList");
      isLoading = true;
      emit(AddExpensesWithHomeDataLoaded());

  }

  _onInsertExpanse(InsertExpenseWithHomeEvent event, Emitter<AddExpensesWithHomeState> emit) async {
    Map<String, dynamic> row = {
      DatabaseHelper.colTripId: userData['${DatabaseHelper.colTripId}'],
      DatabaseHelper.colTripUserId: selectPerson['${DatabaseHelper.colUserId}'],
      DatabaseHelper.colTripCategoryName: selectedCate.toString(),
      DatabaseHelper.colUserId: selectPerson['${DatabaseHelper.colUserId}'],
      DatabaseHelper.colGroupId: userData['${DatabaseHelper.colGroupId}'],
      DatabaseHelper.colTripUserName: selectPerson['${DatabaseHelper.colTripUserName}'],
      DatabaseHelper.colTripExpDesc: descriptionController.text,
      DatabaseHelper.colDateCreated: selectedDate.millisecondsSinceEpoch,
      DatabaseHelper.colTripTime: time.format(event.context),
      DatabaseHelper.colExAndRe: 'e',
      DatabaseHelper.colTripExpAmount: amountController.text,
    };
    print("insert data ... $row");
    final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblTripExpense);
    print('inserted row id: $id');
    Navigator.pop(event.context);
  }

  _onDataReload(DataReload event, Emitter<AddExpensesWithHomeState> emit) {
    emit(AddExpensesWithHomeDataLoaded());
  }
}
