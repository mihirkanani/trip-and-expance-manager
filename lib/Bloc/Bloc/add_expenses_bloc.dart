import 'dart:async';

import 'package:expense_manager/Bloc/Event/add_expenses_event.dart';
import 'package:expense_manager/Bloc/State/add_expenses_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddExpensesBloc extends Bloc<AddExpensesEvent, AddExpensesState> {
  bool isCategory = true;
  bool isLoaded = false;
  List categoryList = [];
  List imageDataList = [];
  int expensesAmount = 0;
  AnimationController? animateController;
  DateTime datePicker = DateTime.now();
  List selectedDateList = [];
  List selectedTimeList = [];
  DateTime selectedDate = DateTime.now();
  List expenseAmountList = [];
  List remarkList = [];
  List selectedCatList = [];
  int selectedCatLength = 0;
  TimeOfDay time = TimeOfDay.now();
  String imageByte = "";

  TextEditingController imageDescController = TextEditingController();

  AddExpensesBloc() : super(AddExpensesInitialState()) {
    on<AddExpensesInitialEvent>(_onInitialState);
    on<InsertExpenseEvent>(_onInsertExpanse);
    on<AddExpensesForStoreEvent>(_onAddExpenses);
    on<ChangeDateAndTimeEvent>(_onChangeTimeAndDate);
    on<ChangeTabEvent>(_onTabChange);
    on<UpdateCameraDataEvent>(_onCameraDataUpdate);
  }

  _onCameraDataUpdate(UpdateCameraDataEvent event, Emitter<AddExpensesState> emit) {
    if (event.imageByte == "") {
      showToast("first select image");
    } else if (event.imageDescController == "") {
      showToast("first enter description or remarks");
    } else {
      imageDataList.add({"image": event.imageByte, "description": event.imageDescController});
      print("==> ${imageDataList}");
      emit(AddExpensesDataLoaded());
      Navigator.pop(event.context);
    }
  }

  void _onInitialState(AddExpensesInitialEvent event, Emitter<AddExpensesState> emit) {
    getCategories();
    PreferenceUtils.init();
    selectedDate = DateTime.now();
    isLoaded = true;

    emit(AddExpensesDataLoaded());
  }

  getCategories() async {
    categoryList.clear();
    categoryList.addAll(await dbHelper.queryStringRow(tableName: DatabaseHelper.tblCategory, query: '${DatabaseHelper.colCategoryType}=0'));
  }

  _onChangeTimeAndDate(ChangeDateAndTimeEvent event, Emitter<AddExpensesState> emit) {
    emit(AddExpensesDataLoaded());
  }

  _onTabChange(ChangeTabEvent event, Emitter<AddExpensesState> emit) {
    emit(AddExpensesDataLoaded());
  }

  _onAddExpenses(AddExpensesForStoreEvent event, Emitter<AddExpensesState> emit) {
    if (event.amountController == "") {
      showToast("Enter amount");
    } else {
      selectedCatList.add(categoryList[event.index]);
      expenseAmountList.add(int.parse(event.amountController));
      remarkList.add(event.remarkController);
      selectedDateList.add(selectedDate.millisecondsSinceEpoch);
      selectedTimeList.add(time.format(event.context));
      selectedCatLength = selectedCatList.length;
      emit(AddExpensesDataLoaded());
      Navigator.pop(event.context);
    }
  }

  Future<void> _onInsertExpanse(InsertExpenseEvent event, Emitter<AddExpensesState> emit) async {
    isLoaded = false;

    for (var list = 0; list < selectedCatList.length; list++) {
      Map<String, dynamic> row = {
        DatabaseHelper.colAccId: 1,
        DatabaseHelper.colCategoryName: "${selectedCatList[list][DatabaseHelper.colName]}",
        DatabaseHelper.colCateId: "${selectedCatList[list][DatabaseHelper.colId]}",
        DatabaseHelper.colCateIcon: "${selectedCatList[list][DatabaseHelper.colCateIcon]}",
        DatabaseHelper.colCateColor: "${selectedCatList[list][DatabaseHelper.colCateColor]}",
        DatabaseHelper.colRemarks: remarkList[list].toString(),
        DatabaseHelper.colAmount: expenseAmountList[list].toString(),
        DatabaseHelper.colTime: selectedTimeList[list].toString(),
        DatabaseHelper.colDateCreated: selectedDateList[list].toString(),
      };
      final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblExpense);
      for (int i = 0; i < imageDataList.length; i++) {
        Map<String, dynamic> img = {
          DatabaseHelper.colImageId: id,
          DatabaseHelper.colType: 0,
          DatabaseHelper.colImageData: imageDataList[i]['image'],
          DatabaseHelper.colImageDesc: imageDataList[i]['description'],
          DatabaseHelper.colDateCreated: selectedDateList[list].toString(),
        };
        await dbHelper.insert(row: img, tableName: DatabaseHelper.tblImage);
      }
    }
    isLoaded = true;

    Navigator.pop(event.context);
    showToast("Yay! Expense added");
  }
}
