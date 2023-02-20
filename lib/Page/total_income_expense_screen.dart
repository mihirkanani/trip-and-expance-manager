import 'package:expense_manager/Bloc/Bloc/total_income_expense_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/view_edit_income_bloc.dart';
import 'package:expense_manager/Bloc/Event/total_income_expense_event.dart';
import 'package:expense_manager/Bloc/State/total_income_expense_state.dart';
import 'package:expense_manager/Page/view_edit_expense_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../Bloc/Bloc/view_edit_expense_bloc.dart';
import 'view_edit_income_screen.dart';

class TotalIncomeExpenseView extends StatelessWidget {
  const TotalIncomeExpenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: BlocBuilder<TotalIncomeExpenseBloc, TotalIncomeExpenseState>(builder: (context, state) {
        if (state is TotalIncomeExpenseInitialState) {
          context.read<TotalIncomeExpenseBloc>().add(GetDataLoadEvent(context));
          context.read<TotalIncomeExpenseBloc>().add(GetExpenseListEvent());
        }
        if (state is TotalIncomeExpenseDataLoading) {
          return Scaffold(
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
          );
        }
        if (state is TotalIncomeExpenseDataLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(20),
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImageConstant.totalIncomeExpenseImg), fit: BoxFit.fill)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<TotalIncomeExpenseBloc>().isExpenses ? context.read<TotalIncomeExpenseBloc>().totalExpense : context.read<TotalIncomeExpenseBloc>().totalIncome}",
                        style: TextStyleConstant.whiteRegular16.copyWith(fontSize: 25),
                      ),
                      Text(
                        context.read<TotalIncomeExpenseBloc>().isExpenses ? "Total Expenses" : "Total Income",
                        style: TextStyleConstant.whiteRegular16.copyWith(fontSize: 18),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: context.read<TotalIncomeExpenseBloc>().dataList.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.read<TotalIncomeExpenseBloc>().isExpenses ? " Total Expenses" : " Total Income",
                              style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: context.read<TotalIncomeExpenseBloc>().dataList.length,
                                padding: const EdgeInsets.only(top: 0),
                                itemBuilder: (BuildContext context2, int index) {
                                  return listItem(context.read<TotalIncomeExpenseBloc>().dataList[index], index, context);
                                },
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: context.read<TotalIncomeExpenseBloc>().isExpenses
                              ? Lottie.asset(ImageConstant.noIncome)
                              : Lottie.asset(ImageConstant.noIncome, height: 500),
                        ),
                )
              ],
            ),
          );
        }
        return Container();
      }),
    );
  }

  appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      title: Text(
        context.read<TotalIncomeExpenseBloc>().isExpenses ? "Total Expenses" : "Total Income",
        style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
      ),
    );
  }

  listItem(var item, var index, BuildContext context) {
    var dt = DateTime.fromMillisecondsSinceEpoch(item[DatabaseHelper.colDateCreated]);
    var date = DateFormat('dd MMM,yyyy').format(dt);

    return SwipeActionCell(
      key: ValueKey(index),
      trailingActions: [
        SwipeAction(
          closeOnTap: true,
          forceAlignmentToBoundary: true,
          color: Colors.transparent,
          content: _getIconButton(Colors.red, Icons.delete),
          onTap: (handler) async {
            deleteRecord(index, context);
          },
        ),
      ],
      child: InkWell(
        onTap: () {
          if (context.read<TotalIncomeExpenseBloc>().isExpenses) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => ViewEditExpenseBloc(selectedCat: item),
                  child: const ViewEditExpenseView(),
                ),
              ),
            ).then((value) {
              context.read<TotalIncomeExpenseBloc>().add(GetDataLoadEvent(context));
              context.read<TotalIncomeExpenseBloc>().add(GetExpenseListEvent());
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => ViewEditIncomeBloc(selectedCat: item),
                  child: const ViewEditIncomeView(),
                ),
              ),
            ).then((value) {
              context.read<TotalIncomeExpenseBloc>().add(GetDataLoadEvent(context));
              context.read<TotalIncomeExpenseBloc>().add(GetExpenseListEvent());
            });
          }
        },
        child: Card(
          elevation: 5,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // isExpenses
                //     ? categoryList[index][DatabaseHelper.colId] > 9 && categoryList[index][DatabaseHelper.colId] < 99
                //         ? Container(
                //             width: 40.sp,
                //             height: 40.sp,
                //             alignment: Alignment.center,
                //             decoration:
                //                 BoxDecoration(color: HexColor(item["${DatabaseHelper.colCateColor}"]), borderRadius: BorderRadius.circular(500.r)),
                //             child: showCategoryIcon(int.parse(item["${DatabaseHelper.colCateIcon}"])))
                //         : Container(
                //             width: 40.sp,
                //             height: 40.sp,
                //             alignment: Alignment.center,
                //             decoration:
                //                 BoxDecoration(color: HexColor(item["${DatabaseHelper.colCateColor}"]), borderRadius: BorderRadius.circular(500.r)),
                //             child: SvgPicture.asset(
                //               "assets/icons/category/${item["${DatabaseHelper.colCateIcon}"]}.svg",
                //               color: Colors.white,
                //             ),
                //           )
                //     : categoryList[index][DatabaseHelper.colId] >= 10 && categoryList[index][DatabaseHelper.colId] < 14 ||
                //             categoryList[index][DatabaseHelper.colId] == 100
                //         ? Container(
                //             width: 40.sp,
                //             height: 40.sp,
                //             alignment: Alignment.center,
                //             decoration:
                //                 BoxDecoration(color: HexColor(item["${DatabaseHelper.colCateColor}"]), borderRadius: BorderRadius.circular(500.r)),
                //             child: SvgPicture.asset(
                //               "assets/icons/category/${item["${DatabaseHelper.colCateIcon}"]}.svg",
                //               color: Colors.white,
                //             ),
                //           )
                //         : Container(
                //             width: 40.sp,
                //             height: 40.sp,
                //             alignment: Alignment.center,
                //             decoration:
                //                 BoxDecoration(color: HexColor(item["${DatabaseHelper.colCateColor}"]), borderRadius: BorderRadius.circular(500.r)),
                //             child: showCategoryIcon(
                //               int.parse(
                //                 item["${DatabaseHelper.colCateIcon}"],
                //               ),
                //             ),
                //           ),
                context.read<TotalIncomeExpenseBloc>().isExpenses
                    ? item[DatabaseHelper.colCateId] > 9 && item[DatabaseHelper.colCateId] < 99
                        ? Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: HexColor(item[DatabaseHelper.colCateColor]), borderRadius: BorderRadius.circular(500)),
                            child: showCategoryIcon(
                              int.parse(
                                item[DatabaseHelper.colCateIcon],
                              ),
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: HexColor(item[DatabaseHelper.colCateColor]), borderRadius: BorderRadius.circular(500)),
                            child: SvgPicture.asset(
                              "assets/icons/category/${item[DatabaseHelper.colCateIcon]}.svg",
                              color: Colors.white,
                            ),
                          )
                    : item[DatabaseHelper.colCateId] >= 10 && item[DatabaseHelper.colCateId] < 14 || item[DatabaseHelper.colCateId] == 100
                        ? Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: HexColor(item[DatabaseHelper.colCateColor]), borderRadius: BorderRadius.circular(500)),
                            child: SvgPicture.asset(
                              "assets/icons/category/${item[DatabaseHelper.colCateIcon]}.svg",
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: HexColor(item[DatabaseHelper.colCateColor]), borderRadius: BorderRadius.circular(500)),
                            child: showCategoryIcon(
                              int.parse(
                                item[DatabaseHelper.colCateIcon],
                              ),
                            ),
                          ),

                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item[DatabaseHelper.colCategoryName]}",
                        style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        date,
                        style: TextStyleConstant.blackRegular14.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${item[DatabaseHelper.colAmount]}",
                  style: TextStyleConstant.blackRegular14.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteRecord(index, BuildContext context) async {
    return showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext contexts) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
                      )),
                  alignment: Alignment.center,
                  child: Text(
                    "Delete Changes",
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: double.infinity,
                  child: Text(
                    "Do you really want to delete this record?",
                    textAlign: TextAlign.center,
                    style: TextStyleConstant.blackRegular14,
                  ),
                ),
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "No",
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
                          onTap: () async {
                            await dbHelper.delete(
                              id: context.read<TotalIncomeExpenseBloc>().dataList[index][DatabaseHelper.colId],
                              tableName: context.read<TotalIncomeExpenseBloc>().isExpenses ? DatabaseHelper.tblExpense : DatabaseHelper.tblIncome,
                            );
                            BlocProvider.of<TotalIncomeExpenseBloc>(context).add(GetDataLoadEvent(context));
                            BlocProvider.of<TotalIncomeExpenseBloc>(context).add(GetExpenseListEvent());
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
                              "Yes",
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

  Widget _getIconButton(color, icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        ///set you real bg color in your content
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
