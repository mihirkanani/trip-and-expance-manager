import 'package:expense_manager/Bloc/Bloc/home_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/view_edit_expense_bloc.dart';
import 'package:expense_manager/Bloc/Event/home_event.dart';
import 'package:expense_manager/Bloc/State/home_state.dart';
import 'package:expense_manager/Page/view_edit_expense_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/language/app_translations.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeEmptyState) {
          context.read<HomeBloc>().add(HomeDataLoadEvent(context));
        }
        if (state is HomeDataLoading) {
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
        if (state is HomeDataLoaded) {
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(15),
                    // color: Colors.white,
                    child: Text(
                      "${AppTranslations.of(context)!.text("_DASHBOARD_")}",
                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                    ),
                  ),
                  totalExpenseCard(context),
                  const SizedBox(
                    height: 15,
                  ),
                  buttonCard(context),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Transactions",
                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                    ),
                  ),
                  transactionCard(
                    context.read<HomeBloc>().selectedFilterIndex == 4
                        ? context.read<HomeBloc>().transactionList
                        : context.read<HomeBloc>().expenseDataList,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  // Container(
                  //   alignment: Alignment.centerLeft,
                  //   padding: const EdgeInsets.all(10),
                  //   // color: Colors.white,
                  //   child: Text(
                  //     "Expense Analysis",
                  //     style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                  //   ),
                  // ),
                  // context.read<HomeBloc>().installedOn < DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch ||
                  //         context.read<HomeBloc>().allExpenseList!.isNotEmpty
                  //     ? Column(
                  //         children: [
                  //           context.read<HomeBloc>().allExpenseList!.isNotEmpty
                  //               // ? graph(context)
                  //               ? Container()
                  //               : Center(
                  //                   child: Lottie.asset(
                  //                     ImageConstant.noChart,
                  //                     height: 200,
                  //                     alignment: Alignment.center,
                  //                   ),
                  //                 ),
                  //         ],
                  //       )
                  //     : Center(
                  //         child: Lottie.asset(
                  //           ImageConstant.noChart,
                  //           height: 200,
                  //           alignment: Alignment.center,
                  //         ),
                  //       ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Container(),
        );
      },
    );
  }

  Widget totalExpenseCard(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return Card(
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black38),
                ),
              ),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    "Total Balance",
                    style: TextStyleConstant.lightBlackBold16,
                  ),
                  Text(
                    "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<HomeBloc>().totalBalance}",
                    style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/TotalIncomeDetailsScreen").then((value) {
                              BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: ColorConstant.lightGreyColor,
                                radius: 20,
                                child: Icon(
                                  Icons.arrow_downward_rounded,
                                  color: ColorConstant.greenColor,
                                  size: 30,
                                ),
                              ),
                              Text(
                                "Income",
                                style: TextStyleConstant.blackRegular16,
                              ),
                              Text(
                                "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<HomeBloc>().totalIncome}",
                                style: TextStyleConstant.whiteRegular14.copyWith(color: ColorConstant.greenColor),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/TotalExpenseDetailsScreen").then((value) {
                              BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                backgroundColor: ColorConstant.lightGreyColor,
                                radius: 20,
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: ColorConstant.redColor,
                                  size: 30,
                                ),
                              ),
                              Text(
                                "Expenses",
                                style: TextStyleConstant.blackRegular16,
                              ),
                              Text(
                                "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<HomeBloc>().totalExpense}",
                                style: TextStyleConstant.whiteRegular14.copyWith(color: ColorConstant.redColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context2) {
                      return filterDialog(context);
                    });
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        context.read<HomeBloc>().selectedFilter,
                        style: TextStyleConstant.blackRegular16,
                      ),
                    ),
                    const Icon(Icons.sort),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  Widget buttonCard(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/addIncomeScreen").then((value) {
                    context.read<HomeBloc>().add(HomeDataLoadEvent(context));
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: ColorConstant.primaryColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "Add Income",
                    style: TextStyleConstant.whiteRegular16.copyWith(fontSize: 15),
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
                  Navigator.pushNamed(context, "/addExpensesScreen").then((value) {
                    context.read<HomeBloc>().add(HomeDataLoadEvent(context));
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Add Expense",
                    style: TextStyleConstant.whiteRegular16.copyWith(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionCard(transList) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return transList.length > 0 && transList != null
          ? ListView.builder(
              padding: EdgeInsets.zero,
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: transList.length> 3 ? 3:transList.length,
              itemBuilder: (BuildContext context, int index) {
                return transactionWidget(
                  iconPath: transList[index][DatabaseHelper.colCateId] > 9 && transList[index][DatabaseHelper.colCateId] < 99
                      ? transList[index][DatabaseHelper.colCateIcon]
                      : "assets/icons/category/${transList[index][DatabaseHelper.colCategoryName]}.svg",
                  amount: transList[index][DatabaseHelper.colAmount],
                  category: transList[index][DatabaseHelper.colCategoryName],
                  iconColor: transList[index][DatabaseHelper.colCateColor],
                  remark: transList[index][DatabaseHelper.colRemarks],
                  timeStamp: transList[index][DatabaseHelper.colDateCreated],
                  time: transList[index][DatabaseHelper.colTime],
                  imageId: transList[index][DatabaseHelper.colType],
                  imageList: context.read<HomeBloc>().expenseImageList,
                  expenseData: transList[index],
                  catId: transList[index][DatabaseHelper.colCateId],
                  context: context,
                );
              },
            )
          : Center(
              child: SvgPicture.asset(
                ImageConstant.imgNoData,
                height: 160,
                fit: BoxFit.fitHeight,
              ),
            );
    });
  }

  Widget transactionWidget({iconPath, imageId, imageList, timeStamp, time, iconColor, category, amount, expenseData, remark, catId, context}) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    var d12 = DateFormat('dd MMM,yyyy ').format(dt);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => ViewEditExpenseBloc(selectedCat: expenseData),
              child: const ViewEditExpenseView(),
            ),
          ),
        ).then((value) {
          BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
        });
      },
      child: Card(
        elevation: 5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26.0,
                    backgroundColor: HexColor(iconColor),
                    child: CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.white,
                      child: (int.parse(catId.toString()) > 9 && int.parse(catId.toString()) < 99)
                          ? Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: HexColor(iconColor),
                                borderRadius: BorderRadius.circular(500),
                              ),
                              child: showCategoryIcon(
                                int.parse(
                                  catId.toString(),
                                ),
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: HexColor(iconColor),
                                borderRadius: BorderRadius.circular(500),
                              ),
                              child: SvgPicture.asset(
                                iconPath,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category ?? "",
                          style: TextStyleConstant.blackBold14,
                        ),
                        Text(
                          remark ?? "",
                          style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${PreferenceUtils.getString(key: selectedCurrency)} $amount",
                    style: TextStyleConstant.blackRegular14,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        d12,
                        style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 14),
                      ),
                      Text(
                        '$time',
                        // _time.format(context),
                        style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context2) {
                          return confirmDialog(
                            onConfirm: () async {
                              var del = await dbHelper.delete(id: expenseData[DatabaseHelper.colId], tableName: DatabaseHelper.tblExpense);
                              Navigator.pop(context);
                              showToast("Record deleted");
                              BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
                            },
                            context: context,
                            content: "Do you really want to delete this entry?",
                            title: "Delete Changes",
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: ColorConstant.lightBlackColor,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  filterDialog(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context2, setState) {
          return Container(
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
                      )),
                  alignment: Alignment.center,
                  child: Text(
                    "Filter By",
                    style: TextStyleConstant.whiteBold16.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ...List.generate(
                  context.read<HomeBloc>().filters.length,
                  (index) => GestureDetector(
                    onTap: () {
                      if (index == 1) {
                        context.read<HomeBloc>().startDate = context.read<HomeBloc>().getDate(
                              context.read<HomeBloc>().now.subtract(
                                    Duration(days: context.read<HomeBloc>().now.weekday - 1),
                                  ),
                            );

                        context.read<HomeBloc>().endDate = context.read<HomeBloc>().getDate(
                              context.read<HomeBloc>().now.add(
                                    Duration(days: DateTime.daysPerWeek - context.read<HomeBloc>().now.weekday),
                                  ),
                            );
                        setState(() {
                          context.read<HomeBloc>().selectedFilterIndex = index;
                          context.read<HomeBloc>().selectedFilter = context.read<HomeBloc>().filters[index]['title'];
                        });
                        Navigator.pop(context);
                        BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
                      } else if (index == 2) {
                        context.read<HomeBloc>().startDate = DateTime(DateTime.now().year);
                        context.read<HomeBloc>().endDate = DateTime(DateTime.now().year, DateTime.december, 1);
                        setState(() {
                          context.read<HomeBloc>().selectedFilterIndex = index;
                          context.read<HomeBloc>().selectedFilter = context.read<HomeBloc>().filters[index]['title'];
                        });
                        Navigator.pop(context);
                        BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
                      } else if (index == 3) {
                        var pickedDateList = pickedDate(context, setState, index);
                      } else if (index == 0) {
                        setState(() {
                          context.read<HomeBloc>().selectedFilterIndex = index;
                          context.read<HomeBloc>().selectedFilter = context.read<HomeBloc>().filters[index]['title'];
                        });
                        Navigator.pop(context);
                        BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
                      } else if (index == 4) {
                        setState(() {
                          context.read<HomeBloc>().selectedFilterIndex = index;
                          context.read<HomeBloc>().selectedFilter = context.read<HomeBloc>().filters[index]['title'];
                        });
                        Navigator.pop(context);
                        BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3.0,
                          ),
                        ],
                        border: index == context.read<HomeBloc>().selectedFilterIndex
                            ? Border.all(
                                color: ColorConstant.primaryColor.withOpacity(0.5),
                              )
                            : const Border(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.read<HomeBloc>().filters[index]['title'],
                            style: TextStyleConstant.blackRegular16.copyWith(color: ColorConstant.primaryColor),
                          ),
                          Text(
                            context.read<HomeBloc>().filters[index]['desc'],
                            style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  confirmDialog({onConfirm, title, content, context}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context2, setState) {
          return Container(
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
                    title,
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: double.infinity,
                  child: Text(
                    content,
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
                                borderRadius: BorderRadius.circular(10)),
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
                          onTap: onConfirm,
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
          );
        },
      ),
    );
  }

  pickedDate(BuildContext context, StateSetter setState, int index) async {
    await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(DateTime.now().year + 2),
    ).then((value) {
      if (value != null) {
        final List<DateTime> picked = [value.start, value.end];
        if (picked != null && picked.length == 2) {
          context.read<HomeBloc>().startDate = picked.first.subtract(
            const Duration(days: 1),
          );
          context.read<HomeBloc>().endDate = picked.last.add(
            const Duration(days: 1),
          );
          setState(() {});
          BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
        }
        setState(() {
          context.read<HomeBloc>().selectedFilterIndex = index;
          context.read<HomeBloc>().selectedFilter = context.read<HomeBloc>().filters[index]['title'];
        });
        Navigator.pop(context);
        BlocProvider.of<HomeBloc>(context).add(GetDataLoadEvent());
      }
    });
  }
// Widget graph(BuildContext context) {
//   final fromDate = DateTime.fromMillisecondsSinceEpoch(allExpenseList[0]['${DatabaseHelper.colDateCreated}']);
//
//   final toDate = DateTime.now();
//   final date1 = DateTime.now().subtract(Duration(days: 2));
//   final date2 = DateTime.now().subtract(Duration(days: 3));
//   final date3 = DateTime.now().subtract(Duration(days: 4));
//
//   return Card(
//     elevation: 5,
//     shadowColor: Colors.black26,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//     child: Container(
//       height: 200,
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
//       // height: MediaQuery.of(context).size.height / 2,
//       width: MediaQuery.of(context).size.width,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10.r),
//         child: BezierChart(
//           fromDate: fromDate,
//           //  DateTime.fromMillisecondsSinceEpoch(
//           //     PreferenceUtils.getInt(key: installedDate)),
//           bezierChartScale: BezierChartScale.WEEKLY,
//
//           onValueSelected: (value) {
//             print(value);
//           },
//           toDate: toDate,
//           selectedDate: toDate,
//           series: [
//             BezierLine(
//               label: "${PreferenceUtils.getString(key: selectedCurrency)}",
//               lineColor: primaryColor,
//               lineStrokeWidth: 5,
//               onMissingValue: (dateTime) {
//                 if (dateTime.day.isEven) {
//                   return 0.0;
//                 }
//                 return 0.0;
//               },
//               data: [
//                 ...List.generate(
//                     allExpenseList.length,
//                         (index) => DataPoint<DateTime>(
//                         value: allExpenseList[index]['${DatabaseHelper.colAmount}'],
//                         xAxis: DateTime.fromMillisecondsSinceEpoch(allExpenseList[index]['${DatabaseHelper.colDateCreated}']))),
//                 // DataPoint<DateTime>(value: 10, xAxis: date1),
//                 // DataPoint<DateTime>(value: 5, xAxis: date1),
//                 // DataPoint<DateTime>(value: 15, xAxis: date1),
//                 // DataPoint<DateTime>(value: 50, xAxis: date2),
//               ],
//             ),
//           ],
//           config: BezierChartConfig(
//             verticalIndicatorStrokeWidth: 3.0,
//             verticalIndicatorColor: primaryColor.withOpacity(0.5),
//             displayDataPointWhenNoValue: false,
//             // showDataPoints: false,
//             showVerticalIndicator: true,
//             verticalIndicatorFixedPosition: false,
//             bubbleIndicatorColor: Colors.white,
//             snap: true,
//             displayLinesXAxis: true,
//             backgroundGradient: LinearGradient(colors: [primaryColor.withOpacity(0.4), Colors.amber[200]]),
//             startYAxisFromNonZeroValue: true,
//             xLinesColor: primaryColor,
//             updatePositionOnTap: true,
//             backgroundColor: Colors.transparent,
//             xAxisTextStyle: TextStyle(color: Colors.black, fontSize: 12.sp),
//             footerHeight: 55.0,
//             pinchZoom: true,
//           ),
//         ),
//       ),
//     ),
//   );
// }
}
