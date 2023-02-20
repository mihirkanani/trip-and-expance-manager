import 'dart:convert';
import 'package:expense_manager/Bloc/Bloc/trip_info_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/trip_list_bloc.dart';
import 'package:expense_manager/Bloc/Event/trip_list_event.dart';
import 'package:expense_manager/Bloc/State/trip_list_state.dart';
import 'package:expense_manager/Page/trip_info_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TripListView extends StatelessWidget {
  const TripListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripListBloc, TripListState>(
      builder: (context, state) {
        if (state is TripListInitialState) {
          BlocProvider.of<TripListBloc>(context).add(TripListLoadEvent(context));
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, 'back');
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.black),
                backgroundColor: Colors.white,
                leading: InkWell(
                  onTap: () => Navigator.pop(context, 'back'),
                  child: Icon(
                    Icons.chevron_left_outlined,
                    size: 28,
                  ),
                ),
                title: Text(
                  "Trip List",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              body: Center(
                child: SpinKitDualRing(
                  color: ColorConstant.primaryColor,
                  size: 30,
                  lineWidth: 3,
                ),
              ),
            ),
          );
        }
        if (state is TripListDataLoaded) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              leading: InkWell(
                onTap: () => Navigator.pop(context, 'back'),
                child: Icon(
                  Icons.chevron_left_outlined,
                  size: 28,
                ),
              ),
              title: Text(
                "Trip List",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            body: Center(
              child: bodyView(context),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            leading: InkWell(
              onTap: () => Navigator.pop(context, 'back'),
              child: Icon(
                Icons.chevron_left_outlined,
                size: 28,
              ),
            ),
            title: Text(
              "Trip List",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
          body: Container(),
        );
      },
    );
  }

  Widget bodyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          context.read<TripListBloc>().group!
              ? Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.read<TripListBloc>().groupInformation[0]['${DatabaseHelper.colGroupName}'].toString() ?? "",
                        style: TextStyleConstant.blackRegular14.copyWith(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SvgPicture.asset(
                            ImageConstant.coinIcon,
                            height: 40,
                            width: 40,
                            color: ColorConstant.primaryColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Paid: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<TripListBloc>().groupUserPaid[0]['total'] == null ? 0 : context.read<TripListBloc>().groupUserPaid[0]['total']}",
                                    style: TextStyleConstant.blackRegular16.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    " (${context.read<TripListBloc>().personDiffe > 0 ? '+' : ''}${context.read<TripListBloc>().personDiffe.toStringAsFixed(2)})",
                                    style: TextStyleConstant.lightBlackRegular16.copyWith(
                                      fontSize: 13,
                                      color: context.read<TripListBloc>().personDiffe > 0 ? ColorConstant.greenColor : ColorConstant.redColor,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Per Head: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<TripListBloc>().totalPerHead.toStringAsFixed(2)}",
                                style: TextStyleConstant.blackRegular16.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                )
              : Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  elevation: 5,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: MemoryImage(
                            base64Decode(context.read<TripListBloc>().userInformation[0]["${DatabaseHelper.colUserProfile}"]),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${context.read<TripListBloc>().userInformation[0]["${DatabaseHelper.colUserName}"]}",
                                style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Paid: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<TripListBloc>().userExpense}",
                                    style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    " (${context.read<TripListBloc>().personDiffe > 0 ? '+' : ''}${context.read<TripListBloc>().personDiffe.toStringAsFixed(2)})",
                                    style: TextStyleConstant.lightBlackRegular16.copyWith(
                                        fontSize: 13,
                                        color: context.read<TripListBloc>().personDiffe > 0 ? ColorConstant.greenColor : ColorConstant.redColor),
                                  ),
                                ],
                              ),
                              Text(
                                "Per Head: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<TripListBloc>().totalPerHead.toStringAsFixed(2)}",
                                style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Expanded(
            child: ((context.read<TripListBloc>().onTripList.length > 0 && context.read<TripListBloc>().onTripList != null))
                ? userTripData(context)
                : Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No Trip Found!",
                            style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget userTripData(BuildContext context) {
    return ListView(padding: EdgeInsets.only(top: 0.0), children: [
      ...List.generate(context.read<TripListBloc>().onTripList.length, (index) {
        return InkWell(
          onTap: () {
            print(DateTime.fromMillisecondsSinceEpoch(
              context.read<TripListBloc>().onTripList[index]['${DatabaseHelper.colTripToDate}'],
            ).toString());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context2) => BlocProvider(
                  create: (_) => TripInfoBloc(
                    context.read<TripListBloc>().onTripList[index]['${DatabaseHelper.colId}'],
                  ),
                  child: const TripInfoView(),
                ),
              ),
            ).then((value) {
              BlocProvider.of<TripListBloc>(context).add(GetTripDataEvent(context));
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.read<TripListBloc>().onTripList[index]['${DatabaseHelper.colTripName}'],
                                style: TextStyleConstant.blackBold16.copyWith(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                parseDateRange(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          context.read<TripListBloc>().onTripList[index]['${DatabaseHelper.colTripFromDate}'])
                                      .toLocal(),
                                  DateTime.fromMillisecondsSinceEpoch(
                                          context.read<TripListBloc>().onTripList[index]['${DatabaseHelper.colTripToDate}'])
                                      .toLocal(),
                                ),
                                style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 4, top: 4, right: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Paid:",
                                      style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Text(
                                          "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<TripListBloc>().onPaidList[index]}",
                                          style: TextStyleConstant.blackBold14.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                                        ),
                                        Text(
                                          " (${context.read<TripListBloc>().diffe3[index] > 0 ? '+' : ''}${context.read<TripListBloc>().diffe3[index].toStringAsFixed(2)})",
                                          style: TextStyleConstant.lightBlackRegular16.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: context.read<TripListBloc>().diffe3[index] > 0 ? ColorConstant.greenColor : ColorConstant.redColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Per Head:",
                                      style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${PreferenceUtils.getString(key: selectedCurrency)} ${num.parse(context.read<TripListBloc>().perPersonList[index].toString()).toStringAsFixed(2)}",
                                      style: TextStyleConstant.blackBold14.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 24,
                  )
                ],
              ),
            ),
          ),
        );
      }),
    ]);
  }
}
