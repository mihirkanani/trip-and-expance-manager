import 'package:expense_manager/Bloc/Event/add_category_event.dart';
import 'package:expense_manager/Bloc/State/add_category_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';

class AddCategoryBloc extends Bloc<AddCategoryEvent, AddCategoryState> {
  bool isExpenses = true;
  List expensesCategoryList = [];
  List incomeCategoryList = [];
  bool isLoaded = false;
  bool argumentData = false;
  List name = [];
  List categoryList = [];
  List selectedCatList = [];
  var selectedCat;
  Future<DateTime>? datePicker;
  List selectedDateList = [];
  List selectedTimeList = [];
  DateTime? selectedDate;
  TimeOfDay time = TimeOfDay.now();
  List incomeAmountList = [];
  List expenseAmountList = [];
  List remarkList = [];
  List categoryIcons = [
    {"icon": Icons.book_online, 'value': 0},
    {"icon": Icons.local_activity, 'value': 1},
    {"icon": Icons.airplane_ticket, 'value': 2},
    {"icon": Icons.accessibility, 'value': 3},
    {"icon": Icons.production_quantity_limits, 'value': 4},
    {"icon": Icons.food_bank, 'value': 5},
    {"icon": Icons.card_travel, 'value': 6},
    {"icon": Icons.file_copy, 'value': 7},
    {"icon": Icons.phone, 'value': 8},
    {"icon": Icons.house_siding, 'value': 9},
    {"icon": Icons.sports_cricket, 'value': 10},
    {"icon": Icons.health_and_safety, 'value': 11},
    {"icon": Icons.cake, 'value': 12},
    {"icon": Icons.domain, 'value': 13},
    {"icon": Icons.luggage, 'value': 14},
    {"icon": Icons.emoji_food_beverage, 'value': 15},
    {"icon": Icons.add_moderator, 'value': 16},
    {"icon": Icons.post_add, 'value': 17},
    {"icon": Icons.weekend, 'value': 18},
    {"icon": Icons.auto_stories, 'value': 19},
  ];

  final introKey = GlobalKey<IntroductionScreenState>();

  AddCategoryBloc({required this.argumentData}) : super(AddCategoryInitialState()) {
    on<AddCategoryLoadEvent>(_onInitialState);
    on<GetCategoriesEvent>(_getCategories);
    on<ChangeDateAndTimeEvent>(_onChangeTimeAndDate);
    on<InsertIncomeEvent>(_onInsertIncome);
    on<InsertExpanseEvent>(_onInsertExpense);
    on<InsertCategoriesEvent>(_onInsertCategories);
    on<ChangeTabEvent>(_onTabChange);
  }

  _onInitialState(AddCategoryLoadEvent event, Emitter<AddCategoryState> emit) {
    emit(AddCategoryLoading());
    selectedDate = DateTime.now();
    PreferenceUtils.init();
    isLoaded = true;
  }

  _onTabChange(ChangeTabEvent event, Emitter<AddCategoryState> emit){
    emit(AddCategoryLoaded());
  }
  _onChangeTimeAndDate(ChangeDateAndTimeEvent event, Emitter<AddCategoryState> emit) {
    emit(AddCategoryLoaded());
  }

  _getCategories(GetCategoriesEvent event, Emitter<AddCategoryState> emit) async {
    expensesCategoryList.clear();
    incomeCategoryList.clear();
    expensesCategoryList.addAll(await dbHelper.queryStringRow(tableName: DatabaseHelper.tblCategory, query: '${DatabaseHelper.colCategoryType}=0'));
    expensesCategoryList.add({
      DatabaseHelper.colId: 100,
      DatabaseHelper.colName: "Add Category",
      DatabaseHelper.colCateIcon: "Add Category",
      DatabaseHelper.colCateColor: "#EB996E",
      DatabaseHelper.colCategoryType: 0
    });
    incomeCategoryList.addAll(await dbHelper.queryStringRow(tableName: DatabaseHelper.tblCategory, query: '${DatabaseHelper.colCategoryType}=1'));
    incomeCategoryList.add({
      DatabaseHelper.colId: 100,
      DatabaseHelper.colName: "Add Category",
      DatabaseHelper.colCateIcon: "Add Category",
      DatabaseHelper.colCateColor: "#EB996E",
      DatabaseHelper.colCategoryType: 0
    });
    emit(AddCategoryLoaded());
  }

  _onInsertIncome(InsertIncomeEvent event, Emitter<AddCategoryState> emit) async {
    isLoaded = false;
    for (var list = 0; list < selectedCatList.length; list++) {
      print("list  ${list.toString()}");
      print("Here Text Is  ${remarkList[list].toString()}");
      Map<String, dynamic> row = {
        DatabaseHelper.colAccId: 1,
        DatabaseHelper.colCategoryName: "${selectedCatList[list][DatabaseHelper.colName]}",
        DatabaseHelper.colCateId: "${selectedCatList[list][DatabaseHelper.colId]}",
        DatabaseHelper.colCateIcon: "${selectedCatList[list][DatabaseHelper.colCateIcon]}",
        DatabaseHelper.colCateColor: "${selectedCatList[list][DatabaseHelper.colCateColor]}",
        DatabaseHelper.colRemarks: remarkList[list].toString(),
        DatabaseHelper.colAmount: incomeAmountList[list].toString(),
        DatabaseHelper.colTime: selectedTimeList[list].toString(),
        DatabaseHelper.colDateCreated: selectedDateList[list].toString(),
      };
      print("insert data ... $row");
      final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblIncome);
      print('inserted row id: $id');
    }
    isLoaded = true;

    showToast("Yay! Income added");
    selectedCatList.clear();
    remarkList.clear();
    incomeAmountList.clear();
    selectedTimeList.clear();
    selectedDateList.clear();
    emit(AddCategoryLoaded());
  }

  _onInsertExpense(InsertExpanseEvent event, Emitter<AddCategoryState> emit) async {
    isLoaded = false;

    for (var list = 0; list < selectedCatList.length; list++) {
      print("list  ${list.toString()}");
      print("Here Text Is  ${remarkList[list].toString()}");
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
      print("insert data ... $row");
      final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblExpense);
      print('inserted row id: $id');
    }
    isLoaded = true;

    showToast("Yay! Expense added");
    selectedCatList.clear();
    remarkList.clear();
    expenseAmountList.clear();
    selectedTimeList.clear();
    selectedDateList.clear();
    emit(AddCategoryLoaded());
  }

  _onInsertCategories(InsertCategoriesEvent event, Emitter<AddCategoryState> emit) async {
    if (event.catName == "") {
      showToast("First enter category name");
    } else if (event.selectCatIcon == null) {
      showToast("Please Select Category Image");
    } else if (name.contains(event.catName)) {
      showToast("This category already added");
    } else {
      isLoaded = false;
      Map<String, dynamic> row = {
        DatabaseHelper.colName: event.catName,
        DatabaseHelper.colCateIcon: event.selectCatIcon['value'].toString(),
        DatabaseHelper.colCateColor: "#F47960",
        DatabaseHelper.colCategoryType: isExpenses ? 0 : 1,
      };
      final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblCategory);
      print('inserted row id: $id');
      Navigator.pop(event.context);

      isLoaded = true;
    }
  }
}
