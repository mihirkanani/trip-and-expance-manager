import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:expense_manager/Bloc/Event/dash_board_event.dart';
import 'package:expense_manager/Bloc/State/dash_board_state.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashBoardBloc extends Bloc<DashBoardEvent, DashBoardState> {
  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();
  TextEditingController usernameController = TextEditingController();
  List<CollapsibleItem> items = [];
  ValueNotifier<String> headline = ValueNotifier("");

  // String headline = "";
  int callBack = 0;
  bool findGuidValue = false;
  bool isCustomCollapsible = true;

  List<CollapsibleItem> get _generateItems {
    return [
      CollapsibleItem(
        text: 'Dashboard',
        icon: Icons.assessment_outlined,
        onPressed: () async {
          headline.value = 'Dashboard';
        },
        isSelected: true,
      ),
      CollapsibleItem(
        text: 'Category',
        icon: Icons.widgets_outlined,
        onPressed: () {
          headline.value = 'Category';
        },
      ),
      CollapsibleItem(
        text: 'Trip Expense',
        icon: Icons.flight_outlined,
        onPressed: () => headline.value = 'Trip',
      ),
      CollapsibleItem(
        text: "Person",
        icon: Icons.person_add_alt_1_outlined,
        onPressed: () => headline.value = 'Users',
      ),
      CollapsibleItem(
        text: 'Group',
        icon: Icons.people_outline,
        onPressed: () => headline.value = 'Group',
      ),
      CollapsibleItem(
        text: 'Expense Diary',
        icon: Icons.book_outlined,
        onPressed: () => headline.value = 'Diary',
      ),
      CollapsibleItem(
        text: 'Setting',
        icon: Icons.settings_outlined,
        onPressed: () => headline.value = 'Setting',
      ),
      CollapsibleItem(
        text: 'User Guide',
        icon: Icons.help_outline_outlined,
        onPressed: () => headline.value = 'Guide',
      ),
    ];
  }

  DashBoardBloc() : super(DashBoardInitialState()) {
    on<DashBoardInitialEvent>(_onInitialState);
    on<DashBoardShowAccountEvent>(_showDialog);
    on<DashBoardShowCaseDoneEvent>(_onShowCaseDone);
    // on<DashBoardTabChangeEvent>(_onTabChange);
  }

  void _onInitialState(DashBoardInitialEvent event, Emitter<DashBoardState> emit) {
    PreferenceUtils.init();
    usernameController.text = PreferenceUtils.getString(key: userName);
    if (!PreferenceUtils.getBool(key: isCurrencySelected)) {
      PreferenceUtils.setString(key: selectedCurrency, value: "€");
    }
    findGuidValue = PreferenceUtils.getBool(key: guidView);
    // if (PreferenceUtils.getBool(key: guidView)) {
    //   if (!PreferenceUtils.getBool(key: isCurrencySelected)) {
    //     showCurrencyPicker(
    //       context: event.context,
    //       showFlag: true,
    //       showCurrencyName: true,
    //       showCurrencyCode: true,
    //       onSelect: (Currency currency) {
    //         PreferenceUtils.setBool(key: isCurrencySelected, value: true);
    //         PreferenceUtils.setString(key: selectedCurrency, value: currency.symbol);
    //         if (kDebugMode) {
    //           print('Select currency: ${currency.name} ${currency.symbol} ${currency.flag}');
    //         }
    //       },
    //     );
    //   }
    // }
    items = _generateItems;
    headline.value = items.firstWhere((item) => item.isSelected).text;
    if (findGuidValue) {
      emit(WithoutShowCaseDashboardState());
    } else {
      emit(ShowCaseDashboardState());
    }
  }

  void _showDialog(DashBoardShowAccountEvent event, Emitter<DashBoardState> emit) {
    showDialog(
      context: event.context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Account Detail",
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User Name:",
                          textAlign: TextAlign.center,
                          style: TextStyleConstant.blackRegular14,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: usernameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                              hintText: "Set username",
                              isDense: true,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: Text(
                              "Cancel",
                              style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            PreferenceUtils.setString(key: userName, value: usernameController.text);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Update",
                              style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onShowCaseDone(DashBoardShowCaseDoneEvent event, Emitter<DashBoardState> emit) {
    PreferenceUtils.setBool(key: guidView, value: true);
    BlocProvider.of<DashBoardBloc>(event.context).findGuidValue = true;
     emit(WithoutShowCaseDashboardState());
    if (PreferenceUtils.getBool(key: guidView)) {
      if (!PreferenceUtils.getBool(key: isCurrencySelected)) {
        showCurrencyPicker(
          context: event.context,
          showFlag: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) {
            PreferenceUtils.setBool(key: isCurrencySelected, value: true);
            PreferenceUtils.setString(key: selectedCurrency, value: currency.symbol);
            if (kDebugMode) {
              print('Select currency: ${currency.name} ${currency.symbol} ${currency.flag}');
            }
          },
        );
      }
    }
  }

  // _onTabChange(DashBoardTabChangeEvent event, Emitter<DashBoardState> emit) {
  //   // emit(WithoutShowCaseDashboardState());
  // }
}
