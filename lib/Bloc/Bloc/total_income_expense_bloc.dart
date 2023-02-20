import 'package:expense_manager/Bloc/Event/total_income_expense_event.dart';
import 'package:expense_manager/Bloc/State/total_income_expense_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TotalIncomeExpenseBloc extends Bloc<TotalIncomeExpenseEvent, TotalIncomeExpenseState> {
  bool isExpenses = true;
  bool isLoaded = false;
  double totalExpense = 0.0;
  double totalIncome = 0.0;
  double? totalBalance;
  List categoryList = [];
  List dataList = [];

  TotalIncomeExpenseBloc({required bool isExpense})
      : isExpenses = isExpense,
        super(TotalIncomeExpenseInitialState()) {
    on<TotalIncomeExpenseLoadEvent>(_onDataLoadState);
    on<GetDataLoadEvent>(_getData);
    on<GetExpenseListEvent>(_getExpenseList);
  }

  void _onDataLoadState(TotalIncomeExpenseLoadEvent event, Emitter<TotalIncomeExpenseState> emit) async {
    _getData;
  }

  _getData(GetDataLoadEvent event, Emitter<TotalIncomeExpenseState> emit) async {
    emit(TotalIncomeExpenseDataLoading());
    PreferenceUtils.init();
    print("===--> $isExpenses");
    isLoaded = false;
    totalExpense = ((await dbHelper.sumOfColumn(columnName: DatabaseHelper.colAmount, tableName: DatabaseHelper.tblExpense) ?? 00.00) as double?)!;
    totalIncome = ((await dbHelper.sumOfColumn(columnName: DatabaseHelper.colAmount, tableName: DatabaseHelper.tblIncome) ?? 00.00) as double?)!;
    totalBalance = totalIncome - totalExpense;
    isLoaded = true;
  }

  _getExpenseList(GetExpenseListEvent event, Emitter<TotalIncomeExpenseState> emit) async {
    dataList.clear();
    categoryList.clear();
    if (isExpenses) {
      categoryList.addAll(await dbHelper.queryStringRow(tableName: DatabaseHelper.tblCategory, query: '${DatabaseHelper.colCategoryType}=0'));
      dataList.addAll(await dbHelper.queryAllRows(tableName: DatabaseHelper.tblExpense));
    } else {
      categoryList.addAll(await dbHelper.queryStringRow(tableName: DatabaseHelper.tblCategory, query: '${DatabaseHelper.colCategoryType}=1'));
      dataList.addAll(await dbHelper.queryAllRows(tableName: DatabaseHelper.tblIncome));
    }
    emit(TotalIncomeExpenseDataLoaded());
  }
}
