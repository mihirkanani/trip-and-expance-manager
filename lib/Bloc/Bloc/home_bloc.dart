import 'package:expense_manager/Bloc/Event/home_event.dart';
import 'package:expense_manager/Bloc/State/home_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:intl/intl.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  bool isLoad = false;
  final controller = FadeInController(autoStart: true);
  AnimationController? animateController;
  Animation<double>? animation;
  bool isIncome = true;
  bool isExpense = false;
  bool isLoaded = false;
  int installedOn = 0;
  List<Color> gradientColors = [
    ColorConstant.primaryColor,
    Colors.amber.shade600,
    // Colors.amber[600],
  ];
  int selectedFilterIndex = 4;
  var selectedFilter = "";

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
  List filters = [];
  DateTime now = DateTime.now();
  DateTime? endDate, startDate;
  int? adId;

  // final InAppReview _inAppReview = InAppReview.instance;

  double? totalExpense;
  double? totalIncome;
  double? totalBalance;

  List? expenseDataList;
  List? transactionList;
  List? allExpenseList;
  List? expenseImageList;
  final dbHelper = DatabaseHelper.instance;

  HomeBloc() : super(HomeEmptyState()) {
    on<HomeDataLoadEvent>(_onDataLoadState);
    on<GetDataLoadEvent>(_getData);
  }

  void _onDataLoadState(HomeDataLoadEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoading());
    PreferenceUtils.init();
    filters = [
      {'title': 'All Expenses', 'desc': 'All records until now.'},
      // {'title': 'Today Expenses', 'desc': '${now.format(kDateRangeFormat)}'},
      {
        'title': 'Weekly Expenses',
        'desc': '${DateFormat("dd MMM yyyy").format(
          getDate(
            now.subtract(
              Duration(days: now.weekday - 1),
            ),
          ),
        )} to ${DateFormat("dd MMM yyyy").format(
          getDate(
            now.add(
              Duration(days: DateTime.daysPerWeek - now.weekday),
            ),
          ),
        )}'
      },
      {'title': 'Yearly Expenses', 'desc': '01 Jan ${DateTime.now().year} to 31 Dec ${DateTime.now().year}'},
      {'title': 'Custom Period', 'desc': 'All records between selected date range.'},
      {'title': 'Today', 'desc': 'All records of Today.'},
    ];
    selectedFilter = filters[selectedFilterIndex]['title'];
    installedOn = PreferenceUtils.getInt(key: installedDate);
    totalExpense = (await dbHelper.sumOfColumn(columnName: DatabaseHelper.colAmount, tableName: DatabaseHelper.tblExpense) ?? 00.00) as double?;
    totalIncome = (await dbHelper.sumOfColumn(columnName: DatabaseHelper.colAmount, tableName: DatabaseHelper.tblIncome) ?? 00.00) as double?;
    totalBalance = totalIncome! - totalExpense!;
    allExpenseList = await dbHelper.queryAllRows(tableName: DatabaseHelper.tblExpense);
    if (selectedFilterIndex == 0 || selectedFilterIndex == 4) {
      await _getAllExpenseList(0);
      emit(HomeDataLoaded());
    } else {
      await _getAllExpenseList(1, start: startDate!.millisecondsSinceEpoch, end: endDate!.millisecondsSinceEpoch);
      emit(HomeDataLoaded());
    }
  }

  _getData(GetDataLoadEvent event, Emitter<HomeState> emit) async {
    totalExpense = (await dbHelper.sumOfColumn(columnName: DatabaseHelper.colAmount, tableName: DatabaseHelper.tblExpense) ?? 00.00) as double?;
    totalIncome = (await dbHelper.sumOfColumn(columnName: DatabaseHelper.colAmount, tableName: DatabaseHelper.tblIncome) ?? 00.00) as double?;
    totalBalance = totalIncome! - totalExpense!;
    allExpenseList = await dbHelper.queryAllRows(tableName: DatabaseHelper.tblExpense);
    if (selectedFilterIndex == 0 || selectedFilterIndex == 4) {
      await _getAllExpenseList(0);
      emit(HomeDataLoaded());
    } else {
      print("selected index: $selectedFilterIndex");
      await _getAllExpenseList(1, start: startDate!.millisecondsSinceEpoch, end: endDate!.millisecondsSinceEpoch);
      emit(HomeDataLoaded());
    }
  }

  _getAllExpenseList(index, {start, end}) async {
    if (index == 0) {
      transactionList = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblExpense,
          query: '${DatabaseHelper.colDateCreated}> ${DateTime.now().subtract(const Duration(days: 1)).toLocal().millisecondsSinceEpoch}');
      expenseDataList = await dbHelper.queryAllRows(tableName: DatabaseHelper.tblExpense);

      if (expenseDataList!.isNotEmpty) {
        isExpense = true;
      }
    } else if (index == 4) {
      transactionList = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblExpense,
          query: '${DatabaseHelper.colDateCreated}> ${DateTime.now().subtract(const Duration(days: 1)).toLocal().millisecondsSinceEpoch}');
    } else {
      expenseDataList = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblExpense, query: "${DatabaseHelper.colDateCreated} > $start AND ${DatabaseHelper.colDateCreated} < $end");
      if (expenseDataList!.isNotEmpty) {
        isExpense = true;
      }
    }
  }
}
