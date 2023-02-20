import 'package:expense_manager/Bloc/Bloc/add_expenses_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/add_income_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/dash_board_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/info_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/language_selection_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/total_income_expense_bloc.dart';
import 'package:expense_manager/Custom/ticker.dart';
import 'package:expense_manager/Page/add_expenses_screen.dart';
import 'package:expense_manager/Page/dash_board_screen.dart';
import 'package:expense_manager/Page/info_screen.dart';
import 'package:expense_manager/Page/language_selection_screen.dart';
import 'package:expense_manager/Page/splash_screen.dart';
import 'package:expense_manager/Page/total_income_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Bloc/Bloc/splash_bloc.dart';
import '../Bloc/Bloc/view_edit_expense_bloc.dart';
import '../Page/add_income_screen.dart';
import '../main.dart';

class Routes {
  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/splash":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => SplashBloc(),
            child: const SplashView(),
          ),
        );
      case "/select_language":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => LanguageSelectionBloc(),
            child: const LanguageSelectionView(),
          ),
        );
      case "/introduction":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => InfoBloc(),
            child: const InfoView(),
          ),
        );
      case "/dashboard":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => DashBoardBloc(),
            child: const DashBoardView(),
          ),
        );
      case "/addIncomeScreen":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => AddIncomeBloc(),
            child: const AddIncomeView(),
          ),
        );
      case "/addExpensesScreen":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => AddExpensesBloc(),
            child: const AddExpensesView(),
          ),
        );
      case "/TotalIncomeDetailsScreen":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => TotalIncomeExpenseBloc(isExpense: false),
            child: const TotalIncomeExpenseView(),
          ),
        );
      case "/TotalExpenseDetailsScreen":
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => TotalIncomeExpenseBloc(isExpense: true),
            child: const TotalIncomeExpenseView(),
          ),
        );
    }
    return null;
  }
}