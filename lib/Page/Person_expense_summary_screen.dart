import 'dart:convert';
import 'package:expense_manager/Bloc/Bloc/Person_expense_summary_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/add_trip_expense_bloc.dart';
import 'package:expense_manager/Bloc/Event/Person_expense_summary_event.dart';
import 'package:expense_manager/Bloc/State/Person_expense_summary_state.dart';
import 'package:expense_manager/Page/add_trip_expense_screen.dart';
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
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';

class PersonExpenseSummaryView extends StatelessWidget {
  const PersonExpenseSummaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonExpenseSummaryBloc, PersonExpenseSummaryState>(
      builder: (context, state) {
        if (state is PersonExpenseSummaryEmptyState) {
          BlocProvider.of<PersonExpenseSummaryBloc>(context).add(PersonExpenseSummaryLoadEvent(context));
          return Scaffold(
            appBar: appBar(context),
            body: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              lineWidth: 3,
            ),
          );
        }
        if (state is PersonExpenseSummaryDataLoaded) {
          return Scaffold(
            appBar: appBar(context),
            body: bodyView(context),
          );
        }
        return Container();
      },
    );
  }

  appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      title: Text(
        "Expense Summary",
        style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
      ),
    );
  }

  Widget bodyView(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 20,
        ),
        ...List.generate(
          context.read<PersonExpenseSummaryBloc>().userList.length,
          (index) => personItem(context.read<PersonExpenseSummaryBloc>().userList[index]['data'],
              context.read<PersonExpenseSummaryBloc>().userList[index]['expense'], context),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          decoration: BoxDecoration(
            color: ColorConstant.primaryColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                color: Colors.black12,
                spreadRadius: 2,
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Total Expense :",
                style: TextStyleConstant.whiteRegular16.copyWith(color: Colors.white, fontSize: 14),
              ),
              Text(
                " ${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<PersonExpenseSummaryBloc>().totalExpen}",
                style: TextStyleConstant.whiteBold16.copyWith(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        ...List.generate(
          context.read<PersonExpenseSummaryBloc>().personExpenseList.length,
          (index) => SwipeActionCell(
            key: ValueKey(index),
            trailingActions: [
              SwipeAction(
                closeOnTap: true,
                forceAlignmentToBoundary: false,
                color: Colors.transparent,
                content: _getIconButton(Colors.red, Icons.delete),
                onTap: (handler) async {
                  confirmDialog(
                    onConfirm: () async {
                      showLoader(context);
                      await dbHelper
                          .delete(
                              id: context.read<PersonExpenseSummaryBloc>().personExpenseList[index]['${DatabaseHelper.colId}'],
                              tableName: DatabaseHelper.tblTripExpense)
                          .then(
                        (value) {
                          print("$value ... deleted..");
                          BlocProvider.of<PersonExpenseSummaryBloc>(context).add(GetDataEvent(context));
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      );
                    },
                    context: context,
                    content: "Do you really want to delete this expense?",
                    title: "Delete",
                  );
                },
              ),
            ],
            child: InkWell(
              onTap: () {
                // pushNamedArg(
                //   route: rtEditTripExpensesScreen,
                //   args: {
                //     "userData": personExpenseList[index],
                //     '${DatabaseHelper.colTripFromDate}': _beginDate,
                //     '${DatabaseHelper.colTripToDate}': _endDate,
                //   },
                //   thenFunc: (value) {
                //     setState(() {
                //       isLoaded = false;
                //     });
                //     getData();
                //   },
                // );
              },
              child: expenseItem(context.read<PersonExpenseSummaryBloc>().personExpenseList[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget personItem(personData, expense, BuildContext context) {
    // double diff = double.parse(expense.toString()) - context.read<PersonExpenseSummaryBloc>().perHead!;
    var perHeadUser = (context.read<PersonExpenseSummaryBloc>().totalExpense! / context.read<PersonExpenseSummaryBloc>().sumofUserpart) *
        personData['${DatabaseHelper.colTripUserPart}'];
    double finalDiff = double.parse(expense.toString()) - perHeadUser;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      elevation: 5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            personData['${DatabaseHelper.colTripUserProfile}'] != ""
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: MemoryImage(
                      base64Decode(personData['${DatabaseHelper.colTripUserProfile}']),
                    ),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(ImageConstant.defaultPersonImg),
                  ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    personData['${DatabaseHelper.colTripUserName}'],
                    style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                  ),
                  Row(
                    children: [
                      Text(
                        "Paid: ${expense.toString()} ",
                        style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 14),
                      ),
                      Text(
                        "(${finalDiff > 0 ? '+' : ''}${finalDiff.toStringAsFixed(2)})",
                        style: TextStyleConstant.lightBlackRegular16
                            .copyWith(fontSize: 14, color: finalDiff > 0 ? ColorConstant.greenColor : ColorConstant.redColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context2) => BlocProvider(
                      create: (_) => AddTripExpenseBloc(
                        userData: {
                          '${DatabaseHelper.colTripId}': context.read<PersonExpenseSummaryBloc>().tripId,
                          '${DatabaseHelper.colTripUserId}': personData['${DatabaseHelper.colUserId}'],
                          '${DatabaseHelper.colUserId}': personData['${DatabaseHelper.colUserId}'],
                          '${DatabaseHelper.colGroupId}': personData['${DatabaseHelper.colGroupId}'],
                          '${DatabaseHelper.colTripUserName}': personData['${DatabaseHelper.colTripUserName}'],
                          '${DatabaseHelper.colTripFromDate}': context.read<PersonExpenseSummaryBloc>().tripData['${DatabaseHelper.colTripFromDate}'],
                          '${DatabaseHelper.colTripToDate}': context.read<PersonExpenseSummaryBloc>().tripData['${DatabaseHelper.colTripToDate}'],
                        },
                      ),
                      child: const AddTripExpenseView(),
                    ),
                  ),
                ).then((value) {
                  BlocProvider.of<PersonExpenseSummaryBloc>(context).add(GetDataEvent(context));
                });
              },
              child: Icon(
                Icons.add,
                color: ColorConstant.primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget expenseItem(var item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Date:",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(
                width: 14,
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Text(DateFormat("dd, MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(item['${DatabaseHelper.colDateCreated}'])),
                        style: TextStyleConstant.blackRegular16.copyWith(fontSize: 15)),
                    Text(
                      ', ${item['${DatabaseHelper.colTripTime}']}',
                      style: TextStyleConstant.blackRegular16.copyWith(fontSize: 15),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Category:",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(
                width: 14,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item['${DatabaseHelper.colTripCategoryName}'],
                  style: TextStyleConstant.blackRegular16.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Description:",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(
                width: 14,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item['${DatabaseHelper.colTripExpDesc}'],
                  style: TextStyleConstant.blackRegular16.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Amount:",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(
                width: 14,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "${PreferenceUtils.getString(key: selectedCurrency)} ${item['${DatabaseHelper.colTripExpAmount}']}",
                  style: TextStyleConstant.blackRegular16.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getIconButton(color, icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
