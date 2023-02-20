import 'dart:async';
import 'dart:developer';
import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:expense_manager/Bloc/Bloc/add_category_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/dash_board_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/diary_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/group_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/home_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/settings_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/trip_expense_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/user_list_bloc.dart';
import 'package:expense_manager/Bloc/Event/dash_board_event.dart';
import 'package:expense_manager/Bloc/State/dash_board_state.dart';
import 'package:expense_manager/Custom/collasiblesidebar_new.dart';
import 'package:expense_manager/Page/Trip_expense_screen.dart';
import 'package:expense_manager/Page/diary_screen.dart';
import 'package:expense_manager/Page/group_screen.dart';
import 'package:expense_manager/Page/settings_screen.dart';
import 'package:expense_manager/Page/user_guide_screen.dart';
import 'package:expense_manager/Page/user_list_screen.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../Custom/custom_show_case.dart';
import '../utils/toast.dart';
import 'add_category_screen.dart';
import 'home_screen.dart';

class DashBoardView extends StatelessWidget {
  const DashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: BlocProvider.of<DashBoardBloc>(context).scaffoldStateKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<DashBoardBloc, DashBoardState>(
        builder: (context, state) {
          if (state is DashBoardInitialState) {
            BlocProvider.of<DashBoardBloc>(context).add(DashBoardInitialEvent(context));
            return Container();
          }
          if (state is ShowCaseDashboardState) {
            return Container(
              color: Colors.white,
              child: ShowCaseWidget(
                autoPlay: false,
                onStart: (index, key) {
                  log('onStart: $index, $key');
                },
                onComplete: (index, key) async {
                  log('onComplete: $index, $key');
                  if (index == 8) {
                    BlocProvider.of<DashBoardBloc>(context).add(DashBoardShowCaseDoneEvent(context));
                  }
                },
                blurValue: 1,
                builder: Builder(
                  builder: (context) => InkWell(
                    onTap: () {},
                    child: CustomCollapsibleSidebar(
                      fitItemsToBottom: true,
                      items: BlocProvider.of<DashBoardBloc>(context).items,
                      minWidth: 60,
                      title: PreferenceUtils.getString(key: userName) == "" ? "User Name" : PreferenceUtils.getString(key: userName),
                      borderRadius: 0,
                      curve: Curves.easeIn,
                      screenPadding: 0,
                      iconSize: 30,
                      onTitleTap: () {
                        BlocProvider.of<DashBoardBloc>(context).add(DashBoardShowAccountEvent(context));
                      },
                      body: InkWell(
                        onTap: () {
                          BlocProvider.of<DashBoardBloc>(context).isCustomCollapsible =
                              !BlocProvider.of<DashBoardBloc>(context).isCustomCollapsible;
                        },
                        child: _body(size, context, context.read<DashBoardBloc>().headline.value),
                      ),
                      backgroundColor: ColorConstant.primaryColor,
                      selectedTextColor: Colors.white,
                      unselectedIconColor: Colors.white54,
                      unselectedTextColor: Colors.white54,
                      selectedIconColor: Colors.white,
                      selectedIconBox: Colors.transparent,
                      showToggleButton: true,
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      titleBack: true,
                      titleBackIcon: Icons.account_circle_outlined,
                      toggleTitle: "Expense Manager",
                      titleStyle: TextStyleConstant.whiteBold16,
                      toggleTitleStyle: TextStyleConstant.whiteBold16,
                      sidebarBoxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                autoPlayDelay: const Duration(seconds: 3),
                autoPlayLockEnable: false,
              ),
            );
          }
          if (state is WithoutShowCaseDashboardState) {
            return StatefulBuilder(builder: (context, setState) {
              return Container(
                color: Colors.white,
                child: CollapsibleSidebar(
                  fitItemsToBottom: true,
                  items: context.read<DashBoardBloc>().items,
                  minWidth: 60,
                  title: PreferenceUtils.getString(key: userName) == "" ? "User Name" : PreferenceUtils.getString(key: userName),
                  borderRadius: 0,
                  curve: Curves.easeIn,
                  screenPadding: 0,
                  iconSize: 30,
                  onTitleTap: () {
                    BlocProvider.of<DashBoardBloc>(context).add(DashBoardShowAccountEvent(context));
                  },
                  body: InkWell(
                    onTap: () {
                      BlocProvider.of<DashBoardBloc>(context).isCustomCollapsible = !BlocProvider.of<DashBoardBloc>(context).isCustomCollapsible;
                    },
                    child: ValueListenableBuilder(
                      valueListenable: context.read<DashBoardBloc>().headline,
                      builder: (BuildContext context, String counterValue, Widget? child) {
                        return _body(size, context, context.read<DashBoardBloc>().headline.value)!;
                      },
                    ),
                  ),
                  backgroundColor: ColorConstant.primaryColor,
                  selectedTextColor: Colors.white,
                  unselectedIconColor: Colors.white54,
                  unselectedTextColor: Colors.white54,
                  selectedIconColor: Colors.white,
                  selectedIconBox: Colors.transparent,
                  showToggleButton: true,
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  titleBack: true,
                  titleBackIcon: Icons.account_circle_outlined,
                  toggleTitle: "Expense Manager",
                  titleStyle: TextStyleConstant.whiteBold16,
                  toggleTitleStyle: TextStyleConstant.whiteBold16,
                  sidebarBoxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              );
            });
          }
          return Container();
        },
      ),
    );
  }

  Widget? _body(Size size, BuildContext context, String headline) {
    print("===> $headline");
    if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Dashboard") {
      return BlocProvider(
        create: (_) => HomeBloc(),
        child: const Home(),
      );
    } else if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Trip") {
      return BlocProvider(
        create: (_) => TripExpenseBloc(),
        child: const TripExpenseView(),
      );
    } else if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Users") {
      return BlocProvider(
        create: (_) => UserListBloc(),
        child: const UserListView(),
      );
    } else if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Group") {
      return  BlocProvider(
        create: (_) => GroupBloc(),
        child: const GroupView(),
      );
    } else if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Category") {
      return BlocProvider(
        create: (_) => AddCategoryBloc(argumentData: false),
        child: const AddCategoryView(),
      );
    } else if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Diary") {
      return BlocProvider(
        create: (_) => DiaryBloc(),
        child: const DiaryView(),
      );
    } else if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Setting") {
      return BlocProvider(
        create: (_) => SettingsBloc(),
        child: const SettingsView(),
      );
    } else if (BlocProvider.of<DashBoardBloc>(context).headline.value == "Guide") {
      return UserGuide();
    }
    return null;
  }
}
