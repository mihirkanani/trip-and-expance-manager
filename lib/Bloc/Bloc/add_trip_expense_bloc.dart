import 'package:expense_manager/Bloc/Event/add_trip_expense_event.dart';
import 'package:expense_manager/Bloc/State/add_trip_expense_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTripExpenseBloc extends Bloc<AddTripExpenseEvent, AddTripExpenseState> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  var selectedCate;
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
  TimeOfDay time = TimeOfDay.now();

  AddTripExpenseBloc({required var this.userData}) : super(AddTripExpenseEmptyState()) {
    on<AddTripExpenseLoadEvent>(_onDataLoadState);
    on<SaveTripExpanseEvent>(_onUpdateTripExpanse);
    on<DataReload>(_onDataReload);
  }

  _onDataLoadState(AddTripExpenseLoadEvent event, Emitter<AddTripExpenseState> emit) async {
    PreferenceUtils.init();
    Future.delayed(Duration.zero, () {
      print(userData);
      selectedDate = DateTime.now();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("category ${prefs.getString('category')}");
    selectedCate = prefs.getString('category') == null ? categories[0] : prefs.getString('category');
    emit(AddTripExpenseDataLoaded());
  }

  _onUpdateTripExpanse(SaveTripExpanseEvent event, Emitter<AddTripExpenseState> emit) async {
    Map<String, dynamic> row = {
      DatabaseHelper.colTripId: userData['${DatabaseHelper.colTripId}'],
      DatabaseHelper.colTripUserId: userData['${DatabaseHelper.colTripUserId}'],
      DatabaseHelper.colTripCategoryName: selectedCate.toString(),
      DatabaseHelper.colUserId: userData['${DatabaseHelper.colUserId}'],
      DatabaseHelper.colGroupId: userData['${DatabaseHelper.colGroupId}'],
      DatabaseHelper.colTripUserName: userData['${DatabaseHelper.colTripUserName}'],
      DatabaseHelper.colTripExpDesc: descriptionController.text,
      DatabaseHelper.colDateCreated: selectedDate.millisecondsSinceEpoch,
      DatabaseHelper.colTripTime: time.format(event.context),
      DatabaseHelper.colExAndRe: 'e',
      DatabaseHelper.colTripExpAmount: amountController.text,
    };
    print("insert data ... $row");
    final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblTripExpense);
    print('inserted row id: $id');
  }

  _onDataReload(DataReload event, Emitter<AddTripExpenseState> emit){
    emit(AddTripExpenseDataLoaded());
  }
}
