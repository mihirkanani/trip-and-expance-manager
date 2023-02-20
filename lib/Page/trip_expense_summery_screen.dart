import 'package:expense_manager/Bloc/Bloc/trip_expense_summery_bloc.dart';
import 'package:expense_manager/Bloc/Event/trip_expense_summery_event.dart';
import 'package:expense_manager/Bloc/State/trip_expense_summery_state.dart';
import 'package:expense_manager/Services/pdf_viewer.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';

class TripExpenseSummeryView extends StatelessWidget {
  const TripExpenseSummeryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripExpenseSummeryBloc, TripExpenseSummeryState>(
      builder: (context, state) {
        if (state is TripExpenseSummeryEmptyState) {
          BlocProvider.of<TripExpenseSummeryBloc>(context).add(TripExpenseSummeryLoadEvent(context));
          return Scaffold(
            appBar: appBar(context),
            body: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              lineWidth: 3,
            ),
          );
        }
        if (state is TripExpenseSummeryDataLoaded) {
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
          )),
      title: Text(
        "Expense Summary",
        style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
      ),
      actions: [
        IconButton(
          onPressed: () {
            PdfParagraphApi.generate(
              tripdata: context.read<TripExpenseSummeryBloc>().tripData,
              userlist:context.read<TripExpenseSummeryBloc>(). userList,
              totalEx: context.read<TripExpenseSummeryBloc>().totalTripExpense,
              totalUser: context.read<TripExpenseSummeryBloc>().totalUsers,
              expenseList:context.read<TripExpenseSummeryBloc>(). personExpenseList,
              cur: context.read<TripExpenseSummeryBloc>().currency,
              categoryList:context.read<TripExpenseSummeryBloc>(). categoryList,
              catWithSum: context.read<TripExpenseSummeryBloc>().catwithExpenseList,
            );
          },
          icon: Icon(
            Icons.picture_as_pdf,
            color: ColorConstant.primaryColor,
          ),
        )
      ],
    );
  }

  Widget bodyView(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 20,
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
              ),
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
                " ${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<TripExpenseSummeryBloc>().totalExpen}",
                style: TextStyleConstant.whiteBold16.copyWith(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        ...List.generate(
          context.read<TripExpenseSummeryBloc>().personExpenseList.length,
          (index) => SwipeActionCell(
            key: ValueKey(index),
            fullSwipeFactor: 0.90,
            editModeOffset: 30,
            normalAnimationDuration: 300,
            deleteAnimationDuration: 200,
            trailingActions: [
              SwipeAction(
                closeOnTap: true,
                forceAlignmentToBoundary: false,
                widthSpace: 80,
                color: Colors.transparent,
                content: _getIconButton(Colors.red, Icons.delete),
                onTap: (handler) async {
                  confirmDialog(
                    onConfirm: () async {
                      showLoader(context);
                      var del = await dbHelper.delete(
                          id: context.read<TripExpenseSummeryBloc>().personExpenseList[index]['${DatabaseHelper.colId}'],
                          tableName: DatabaseHelper.tblTripExpense);
                      print("$del ... deleted..");
                      BlocProvider.of<TripExpenseSummeryBloc>(context).add(GetDataEvent(context));
                      Navigator.pop(context);
                      Navigator.pop(context);
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
              child: expenseItem(context.read<TripExpenseSummeryBloc>().personExpenseList[index]),
            ),
          ),
        ),
      ],
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
                width: 8,
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Text(
                      DateFormat("dd, MMM yyyy").format(
                        DateTime.fromMillisecondsSinceEpoch(item['${DatabaseHelper.colDateCreated}']),
                      ),
                      style: TextStyleConstant.blackRegular14,
                    ),
                    Text(
                      ', ${item['${DatabaseHelper.colTripTime}']}',
                      style: TextStyleConstant.blackRegular14,
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
                width: 8,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item['${DatabaseHelper.colTripCategoryName}'],
                  style: TextStyleConstant.blackRegular14,
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
                width: 8,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item['${DatabaseHelper.colTripExpDesc}'],
                  style: TextStyleConstant.blackRegular14,
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
                  "Expense by:",
                  style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item['${DatabaseHelper.colTripUserName}'],
                  style: TextStyleConstant.blackRegular14,
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
                width: 8,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "${PreferenceUtils.getString(key: selectedCurrency)} ${item['${DatabaseHelper.colTripExpAmount}']}",
                  style: TextStyleConstant.blackRegular14,
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
