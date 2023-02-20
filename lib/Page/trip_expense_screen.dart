import 'dart:convert';
import 'package:expense_manager/Bloc/Bloc/add_expenses_with_home_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/add_trip_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/trip_expense_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/trip_info_bloc.dart';
import 'package:expense_manager/Bloc/State/trip_expense_state.dart';
import 'package:expense_manager/Page/add_expenses_with_home_screen.dart';
import 'package:expense_manager/Page/add_trip_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../Bloc/Event/trip_expense_event.dart';
import 'trip_info_screen.dart';

class TripExpenseView extends StatelessWidget {
  const TripExpenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripExpenseBloc, TripExpenseState>(
      builder: (context, state) {
        if (state is TripExpenseInitialState) {
          BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
          return Scaffold(
            bottomNavigationBar: SizedBox(
              height: 86,
              child: addTripButton(context),
            ),
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
          );
        }
        if (state is TripExpenseLoaded) {
          return Scaffold(
            bottomNavigationBar: SizedBox(
              height: 86,
              child: addTripButton(context),
            ),
            backgroundColor: Colors.white,
            body: bodyView(context),
          );
        }
        return Container();
      },
    );
  }

  bodyView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          // color: Colors.amber,
          padding: const EdgeInsets.all(15),
          child: Text(
            "Trip Expense",
            style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ((context.read<TripExpenseBloc>().onGoingTrips.isNotEmpty) ||
                        (context.read<TripExpenseBloc>().pastTrips.isNotEmpty) ||
                        (context.read<TripExpenseBloc>().upComingTrips.isNotEmpty))
                    ? Column(
                        children: [
                          ongoingTrip(context),
                          context.read<TripExpenseBloc>().upComingTrips.isNotEmpty ? upComingTrip(context) : Container(),
                          pastTrip(context),
                        ],
                      )
                    : emptyWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget ongoingTrip(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "OnGoing Trip",
            textAlign: TextAlign.left,
            style: TextStyleConstant.blackBold14,
          ),
        ),
        context.read<TripExpenseBloc>().onGoingTrips.isNotEmpty
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...List.generate(context.read<TripExpenseBloc>().onGoingTrips.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context2) => BlocProvider(
                                create: (_) => TripInfoBloc(
                                  context.read<TripExpenseBloc>().onGoingTrips[index]['${DatabaseHelper.colId}'],
                                ),
                                child: const TripInfoView(),
                              ),
                            ),
                          ).then((value) {
                            BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
                          });
                        },
                        child: Container(
                          width: 320,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    base64Decode(context.read<TripExpenseBloc>().onGoingTrips[index][DatabaseHelper.colTripImage]),
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        context.read<TripExpenseBloc>().onGoingTrips[index][DatabaseHelper.colTripName] ?? "",
                                        style: TextStyleConstant.blackRegular14,
                                      ),
                                    ),
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: ColorConstant.primaryColor,
                                    ),
                                    Text(
                                      context.read<TripExpenseBloc>().onGoingTrips[index][DatabaseHelper.colTripPlaceDesc] ?? "",
                                      style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Text(
                                  parseDateRange(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      context.read<TripExpenseBloc>().onGoingTrips[index][DatabaseHelper.colTripFromDate],
                                    ),
                                    DateTime.fromMillisecondsSinceEpoch(
                                      context.read<TripExpenseBloc>().onGoingTrips[index][DatabaseHelper.colTripToDate],
                                    ),
                                  ),
                                  style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // pushNamedArg(
                                  //     route: rtAddTripExpensesWithHomeScreen,
                                  //     args: {
                                  //       '${DatabaseHelper.colTripId}': onGoingTrips[index]['${DatabaseHelper.colId}'],
                                  //       '${DatabaseHelper.colGroupId}': onGoingTrips[index]['${DatabaseHelper.colGroupId}'],
                                  //       '${DatabaseHelper.colTripFromDate}': onGoingTrips[index]['${DatabaseHelper.colTripFromDate}'],
                                  //       '${DatabaseHelper.colTripToDate}': onGoingTrips[index]['${DatabaseHelper.colTripToDate}'],
                                  //     },
                                  //     thenFunc: (value) {
                                  //       setState(() {
                                  //         getData();
                                  //       });
                                  //     });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context2) => BlocProvider(
                                        create: (_) => AddExpensesWithHomeBloc(
                                          userData: {
                                            '${DatabaseHelper.colTripId}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                                ['${DatabaseHelper.colId}'],
                                            '${DatabaseHelper.colGroupId}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                                ['${DatabaseHelper.colGroupId}'],
                                            '${DatabaseHelper.colTripFromDate}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                                ['${DatabaseHelper.colTripFromDate}'],
                                            '${DatabaseHelper.colTripToDate}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                                ['${DatabaseHelper.colTripToDate}'],
                                          },
                                        ),
                                        child: const AddExpenseWithHomeView(),
                                      ),
                                    ),
                                  ).then((value) {
                                    BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ],
                                    color: ColorConstant.primaryColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Add Expense",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              )
            : Column(
                children: [
                  Image.asset(
                    ImageConstant.noTripImg,
                  ),
                  const Text("No ongoing trip available")
                ],
              ),
        context.read<TripExpenseBloc>().onGoingTrips.length > 1
            ? const SizedBox(
                height: 6,
              )
            : Container(),
        context.read<TripExpenseBloc>().onGoingTrips.length > 1
            ? Row(
                children: const [
                  Expanded(
                    child: Text(
                      "Swipe the screen to see your other trip",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget pastTrip(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Past Trip",
            textAlign: TextAlign.left,
            style: TextStyleConstant.blackBold14,
          ),
        ),
        context.read<TripExpenseBloc>().pastTrips.isNotEmpty
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ...List.generate(context.read<TripExpenseBloc>().pastTrips.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context2) => BlocProvider(
                                create: (_) => TripInfoBloc(
                                  context.read<TripExpenseBloc>().pastTrips[index]['${DatabaseHelper.colId}'],
                                ),
                                child: const TripInfoView(),
                              ),
                            ),
                          ).then((value) {
                            BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.memory(
                                  base64Decode(context.read<TripExpenseBloc>().pastTrips[index][DatabaseHelper.colTripImage]),
                                  height: 125,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.read<TripExpenseBloc>().pastTrips[index][DatabaseHelper.colTripName] ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyleConstant.blackRegular14.copyWith(),
                                    ),
                                    Text(
                                      timeago.format(DateTime.fromMillisecondsSinceEpoch(
                                          context.read<TripExpenseBloc>().pastTrips[index][DatabaseHelper.colTripToDate])),
                                      // "2 Month ago",
                                      style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // pushNamedArg(
                                  //     route: rtAddTripExpensesWithHomeScreen,
                                  //     args: {
                                  //       '${DatabaseHelper.colTripId}': pastTrips[index]['${DatabaseHelper.colId}'],
                                  //       '${DatabaseHelper.colGroupId}': pastTrips[index]['${DatabaseHelper.colGroupId}'],
                                  //       '${DatabaseHelper.colTripFromDate}': pastTrips[index]['${DatabaseHelper.colTripFromDate}'],
                                  //       '${DatabaseHelper.colTripToDate}': pastTrips[index]['${DatabaseHelper.colTripToDate}'],
                                  //     },
                                  //     thenFunc: (value) {
                                  //       setState(() {
                                  //         getData();
                                  //       });
                                  //     });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context2) => BlocProvider(
                                        create: (_) => AddExpensesWithHomeBloc(
                                          userData: {
                                            '${DatabaseHelper.colTripId}': context.read<TripExpenseBloc>().pastTrips[index]
                                            ['${DatabaseHelper.colId}'],
                                            '${DatabaseHelper.colGroupId}': context.read<TripExpenseBloc>().pastTrips[index]
                                            ['${DatabaseHelper.colGroupId}'],
                                            '${DatabaseHelper.colTripFromDate}': context.read<TripExpenseBloc>().pastTrips[index]
                                            ['${DatabaseHelper.colTripFromDate}'],
                                            '${DatabaseHelper.colTripToDate}': context.read<TripExpenseBloc>().pastTrips[index]
                                            ['${DatabaseHelper.colTripToDate}'],
                                          },
                                        ),
                                        child: const AddExpenseWithHomeView(),
                                      ),
                                    ),
                                  ).then((value) {
                                    BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(6.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ],
                                    color: ColorConstant.primaryColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Add Expense",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              )
            : Column(
                children: [
                  Image.asset(
                    ImageConstant.noTripImg,
                  ),
                  const Text("No past trip available")
                ],
              ),
        context.read<TripExpenseBloc>().pastTrips.length > 2
            ? const SizedBox(
                height: 6,
              )
            : Container(),
        context.read<TripExpenseBloc>().pastTrips.length > 2
            ? Row(
                children: const [
                  Expanded(
                    child: Text(
                      "Swipe the screen to see your other trip",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget upComingTrip(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "UpComing Trip",
            textAlign: TextAlign.left,
            style: TextStyleConstant.blackBold14,
          ),
        ),
        context.read<TripExpenseBloc>().upComingTrips.isNotEmpty
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ...List.generate(context.read<TripExpenseBloc>().upComingTrips.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context2) => BlocProvider(
                                create: (_) => TripInfoBloc(context.read<TripExpenseBloc>().upComingTrips[index]['${DatabaseHelper.colId}']),
                                child: const TripInfoView(),
                              ),
                            ),
                          ).then((value) {
                            BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          width: 140,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.memory(
                                  base64Decode(context.read<TripExpenseBloc>().upComingTrips[index][DatabaseHelper.colTripImage]),
                                  height: 125,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.read<TripExpenseBloc>().upComingTrips[index][DatabaseHelper.colTripName] ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyleConstant.blackRegular14,
                                    ),
                                    Text(
                                      timeago.format(DateTime.fromMillisecondsSinceEpoch(
                                          context.read<TripExpenseBloc>().upComingTrips[index][DatabaseHelper.colTripToDate])),
                                      // "2 Month ago",
                                      style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // pushNamedArg(
                                  //     route: rtAddTripExpensesWithHomeScreen,
                                  //     args: {
                                  //       '${DatabaseHelper.colTripId}': upComingTrips[index]['${DatabaseHelper.colId}'],
                                  //       '${DatabaseHelper.colGroupId}': upComingTrips[index]['${DatabaseHelper.colGroupId}'],
                                  //       '${DatabaseHelper.colTripFromDate}': upComingTrips[index]['${DatabaseHelper.colTripFromDate}'],
                                  //       '${DatabaseHelper.colTripToDate}': upComingTrips[index]['${DatabaseHelper.colTripToDate}'],
                                  //     },
                                  //     thenFunc: (value) {
                                  //       setState(() {
                                  //         getData();
                                  //       });
                                  //     });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context2) => BlocProvider(
                                        create: (_) => AddExpensesWithHomeBloc(
                                          userData: {
                                            '${DatabaseHelper.colTripId}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                            ['${DatabaseHelper.colId}'],
                                            '${DatabaseHelper.colGroupId}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                            ['${DatabaseHelper.colGroupId}'],
                                            '${DatabaseHelper.colTripFromDate}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                            ['${DatabaseHelper.colTripFromDate}'],
                                            '${DatabaseHelper.colTripToDate}': context.read<TripExpenseBloc>().onGoingTrips[index]
                                            ['${DatabaseHelper.colTripToDate}'],
                                          },
                                        ),
                                        child: const AddExpenseWithHomeView(),
                                      ),
                                    ),
                                  ).then((value) {
                                    BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(6.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ],
                                    color: ColorConstant.primaryColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Add Expense",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              )
            : Column(
                children: [
                  Image.asset(
                    ImageConstant.noTripImg,
                  ),
                  const Text("No past trip available")
                ],
              ),
        context.read<TripExpenseBloc>().upComingTrips.length > 2 ? const SizedBox(height: 6) : Container(),
        context.read<TripExpenseBloc>().upComingTrips.length > 2
            ? Row(
                children: const [
                  Expanded(
                    child: Text(
                      "Swipe the screen to see your other trip",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget addTripButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("${DateTime.now().millisecondsSinceEpoch}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => AddTripBloc(),
              child: const AddTripView(),
            ),
          ),
        ).then((value) {
          BlocProvider.of<TripExpenseBloc>(context).add(GetDataLoadEvent());
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorConstant.primaryColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "+ Create New Trip",
          style: TextStyleConstant.whiteBold16.copyWith(fontSize: 15),
        ),
      ),
    );
  }

  Widget emptyWidget() {
    return Column(
      children: [
        const SizedBox(
          height: 0.15,
        ),
        Image.asset(
          ImageConstant.noTripImg,
        ),
        Text(
          "Welcome to trip expense manager\nTap on (+) Button to add your new trip.",
          textAlign: TextAlign.center,
          style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}
