import 'dart:convert';

import 'package:expense_manager/Bloc/Bloc/Person_expense_summary_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/add_trip_expense_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/edit_trip_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/trip_expense_summery_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/trip_info_bloc.dart';
import 'package:expense_manager/Bloc/Event/trip_info_event.dart';
import 'package:expense_manager/Bloc/State/trip_info_state.dart';
import 'package:expense_manager/Page/Person_expense_summary_screen.dart';
import 'package:expense_manager/Page/add_trip_expense_screen.dart';
import 'package:expense_manager/Page/edit_trip_screen.dart';
import 'package:expense_manager/Page/trip_expense_summery_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:collection/collection.dart';

class TripInfoView extends StatelessWidget {
  const TripInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripInfoBloc, TripInfoState>(
      builder: (context, state) {
        if (state is TripInfoEmptyState) {
          BlocProvider.of<TripInfoBloc>(context).add(EditTripInfoDataLoadEvent());
          return Scaffold(
            appBar: appBar(context),
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
          );
        }
        if (state is TripInfoLoaded) {
          return Scaffold(
            appBar: appBar(context),
            body: bodyView(context),
          );
        }
        return Scaffold(
          body: Container(),
        );
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
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      title: Text(
        "Trip Info",
        style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context2) => BlocProvider(
                  create: (_) => EditTripBloc(
                    selectedData: {"userList": context.read<TripInfoBloc>().userList, "tripData": context.read<TripInfoBloc>().tripData},
                  ),
                  child: const EditTripView(),
                ),
              ),
            ).then((value) {
              BlocProvider.of<TripInfoBloc>(context).add(EditTripInfoDataLoadEvent());
            });
            // pushNamedArg(
            //     route: rtEditTripScreen,
            //     args: {"userList": userList, "tripData": tripData},
            //     thenFunc: (value) {
            //       isLoaded = false;
            //       setState(() {});
            //       getData();
            //     });
          },
          icon: const Icon(
            Icons.edit_outlined,
            size: 28,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: () async {
            confirmDialog(
              onConfirm: () async {
                var del = await dbHelper.delete(id: context.read<TripInfoBloc>().tripId, tableName: DatabaseHelper.tblTrip);
                var del1 = await dbHelper.deleteTripExpense(
                    tripid: DatabaseHelper.colTripId, id: context.read<TripInfoBloc>().tripId, tableName: DatabaseHelper.tblTripExpense);
                var del2 = await dbHelper.deleteTripExpense(
                    tripid: DatabaseHelper.colTripId, id: context.read<TripInfoBloc>().tripId, tableName: DatabaseHelper.tblTripUsers);
                print("$del  $del1 $del2... deleted..");
                Navigator.pop(context);
                Navigator.pop(context);
              },
              context: context,
              content: "Do you really want to delete this trip?",
              title: "Delete Changes",
            );
          },
          icon: const Icon(
            Icons.delete_outline,
            size: 28,
            color: Colors.black,
          ),
        )
      ],
    );
  }

  Widget bodyView(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
          height: 15,
        ),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  base64Decode(context.read<TripInfoBloc>().tripData[DatabaseHelper.colTripImage]),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.read<TripInfoBloc>().tripData[DatabaseHelper.colTripName] ?? "",
                      style: TextStyleConstant.blackRegular14,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: ColorConstant.primaryColor,
                        ),
                        Text(
                          context.read<TripInfoBloc>().tripData[DatabaseHelper.colTripPlaceDesc] ?? "",
                          style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                parseDateRange(
                  DateTime.fromMillisecondsSinceEpoch(context.read<TripInfoBloc>().tripData[DatabaseHelper.colTripFromDate]).toLocal(),
                  DateTime.fromMillisecondsSinceEpoch(
                    context.read<TripInfoBloc>().tripData[DatabaseHelper.colTripToDate],
                  ).toLocal(),
                ),
                style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 5,
        ),
        ...List.generate(
          context.read<TripInfoBloc>().userList.length,
          (index) => SwipeActionCell(
            key: ValueKey(index),
            trailingActions: [
              SwipeAction(
                closeOnTap: true,
                forceAlignmentToBoundary: true,
                color: Colors.transparent,
                content: context.read<TripInfoBloc>().userList[index]['expense'] == 0
                    ? _getIconButton(Colors.red, Icons.delete)
                    : _getIconButton(Colors.grey, Icons.delete),
                onTap: (handler) async {
                  if (context.read<TripInfoBloc>().userList[index]['expense'] != 0) {
                    customDialog(
                      onConfirm: () async {
                        Navigator.pop(context);
                      },
                      context: context,
                      content: "This person can't be removed. because this person has already spent on the trip",
                      title: "Delete",
                    );
                  } else {
                    confirmDialog(
                      onConfirm: () async {
                        print("TRip ID ${context.read<TripInfoBloc>().userList[index]['data'][DatabaseHelper.colTripId]}");
                        print("User ID ${context.read<TripInfoBloc>().userList[index]['data'][DatabaseHelper.colUserId]}");
                        var del = await dbHelper.tripUserDelete(
                          tableName: DatabaseHelper.tblTripUsers,
                          id: context.read<TripInfoBloc>().userList[index]['data'][DatabaseHelper.colUserId],
                          tripId: context.read<TripInfoBloc>().userList[index]['data'][DatabaseHelper.colTripId],
                        );
                        Navigator.pop(context);
                        BlocProvider.of<TripInfoBloc>(context).add(EditTripInfoDataLoadEvent());
                      },
                      context: context,
                      content: "Do you really want to delete this person?",
                      title: "Delete",
                    );
                  }
                },
              ),
            ],
            child: personItem(
              context.read<TripInfoBloc>().userList[index]['data'],
              context.read<TripInfoBloc>().userList[index]['expense'],
              context,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        expenseSummary(context),
      ],
    );
  }

  Widget personItem(personData, expense, BuildContext context) {
    double diff = double.parse(expense.toString()) - context.read<TripInfoBloc>().perHead!;
    var perHeadUser =
        (context.read<TripInfoBloc>().totalExpense! / context.read<TripInfoBloc>().sumofUserpart) * personData['${DatabaseHelper.colTripUserPart}'];
    double finalDiff = double.parse(expense.toString()) - perHeadUser;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context2) => BlocProvider(
              create: (_) => PersonExpenseSummaryBloc(
                selectedData: {
                  "personId": personData['${DatabaseHelper.colUserId}'],
                  "tripId": context.read<TripInfoBloc>().tripId,
                  "personName": personData['${DatabaseHelper.colTripUserName}'],
                  "userId": personData['${DatabaseHelper.colUserId}'],
                  "paid": expense.toString(),
                  '${DatabaseHelper.colTripFromDate}': context.read<TripInfoBloc>().tripData['${DatabaseHelper.colTripFromDate}'],
                  '${DatabaseHelper.colTripToDate}': context.read<TripInfoBloc>().tripData['${DatabaseHelper.colTripToDate}'],
                },
              ),
              child: const PersonExpenseSummaryView(),
            ),
          ),
        ).then((value) {
          BlocProvider.of<TripInfoBloc>(context).add(EditTripInfoDataLoadEvent());
        });
      },
      child: Card(
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
                          style: TextStyleConstant.lightBlackRegular16.copyWith(
                            fontSize: 14,
                            color: finalDiff > 0 ? ColorConstant.greenColor : ColorConstant.redColor,
                          ),
                        ),
                      ],
                    ),
                    context.read<TripInfoBloc>().userPart1.sum == 0
                        ? Container()
                        : Text(
                            "Per Head: ${perHeadUser.toStringAsFixed(2)}",
                            style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 14),
                          )
                    // : Container(),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context2) => BlocProvider(
                            create: (_) => AddTripExpenseBloc(
                              userData: {
                                '${DatabaseHelper.colTripId}': context.read<TripInfoBloc>().tripId,
                                '${DatabaseHelper.colTripUserId}': personData['${DatabaseHelper.colUserId}'],
                                '${DatabaseHelper.colUserId}': personData['${DatabaseHelper.colUserId}'],
                                '${DatabaseHelper.colGroupId}': personData['${DatabaseHelper.colGroupId}'],
                                '${DatabaseHelper.colTripUserName}': personData['${DatabaseHelper.colTripUserName}'],
                                '${DatabaseHelper.colTripFromDate}': context.read<TripInfoBloc>().tripData['${DatabaseHelper.colTripFromDate}'],
                                '${DatabaseHelper.colTripToDate}': context.read<TripInfoBloc>().tripData['${DatabaseHelper.colTripToDate}'],
                              },
                            ),
                            child: const AddTripExpenseView(),
                          ),
                        ),
                      ).then((value) {
                        BlocProvider.of<TripInfoBloc>(context).add(EditTripInfoDataLoadEvent());
                      });
                    },
                    child: Icon(
                      Icons.add,
                      color: ColorConstant.primaryColor,
                      size: 28,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
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

  Widget expenseSummary(BuildContext context) {
    return InkWell(
      onTap: () async {
        showLoader(context);
        await Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context2) => BlocProvider(
              create: (_) => TripExpenseSummeryBloc(
                selectedData: {
                  "tripId": context.read<TripInfoBloc>().tripId,
                  "total_expense": context.read<TripInfoBloc>().totalExpense,
                  '${DatabaseHelper.colTripFromDate}': context.read<TripInfoBloc>().tripData['${DatabaseHelper.colTripFromDate}'],
                  '${DatabaseHelper.colTripToDate}': context.read<TripInfoBloc>().tripData['${DatabaseHelper.colTripToDate}'],
                },
              ),
              child: const TripExpenseSummeryView(),
            ),
          ),
        ).then((value) {
          BlocProvider.of<TripInfoBloc>(context).add(EditTripInfoDataLoadEvent());
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        elevation: 5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 30,
                color: ColorConstant.primaryColor,
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Expense Summary",
                      style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: ColorConstant.primaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
