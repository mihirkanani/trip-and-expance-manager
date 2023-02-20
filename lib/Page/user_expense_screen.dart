import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:expense_manager/Bloc/Bloc/trip_list_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/user_expense_bloc.dart';
import 'package:expense_manager/Bloc/Event/user_expense_event.dart';
import 'package:expense_manager/Bloc/State/user_expense_state.dart';
import 'package:expense_manager/Page/trip_list_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserExpenseView extends StatelessWidget {
  const UserExpenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserExpenseBloc, UserExpenseState>(
      builder: (context, state) {
        if (state is UserExpenseInitialState) {
          BlocProvider.of<UserExpenseBloc>(context).add(UserExpenseLoadEvent(context));
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.chevron_left_outlined,
                  size: 28,
                ),
              ),
              title: Text(
                "Person List",
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
          );
        }
        if (state is UserExpenseDataLoaded) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.chevron_left_outlined,
                  size: 28,
                ),
              ),
              title: Text(
                "Person List",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            body: bodyView(context),
          );
        }
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left_outlined,
                size: 28,
              ),
            ),
            title: Text(
              "Person List",
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
        );
      },
    );
  }

  Widget bodyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),
              width: double.infinity,
              // width: 0.35.sw,
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
                    context.read<UserExpenseBloc>().groupName ?? "",
                    style: TextStyleConstant.blackRegular14.copyWith(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SvgPicture.asset(
                        ImageConstant.coinIcon,
                        height: 30,
                        width: 30,
                        color: ColorConstant.primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Total Expense: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<UserExpenseBloc>().onSumList.sum}",
                                style: TextStyleConstant.blackRegular16.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            (context.read<UserExpenseBloc>().onUserList.length > 0)
                ? Expanded(child: userListData(context))
                : Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              ImageConstant.noUserFound,
                              height: 200,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "No Person Found!",
                              style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget userListData(BuildContext context) {
    return ListView(padding: EdgeInsets.only(top: 0.0), children: [
      ...List.generate(context.read<UserExpenseBloc>().onUserList.length, (index) {
        var diff1 = double.parse(context.read<UserExpenseBloc>().onSumList.sum.toString()) - context.read<UserExpenseBloc>().perHead;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context2) => BlocProvider(
                  create: (_) => TripListBloc(
                    groupId: context.read<UserExpenseBloc>().groupId,
                    userId: context.read<UserExpenseBloc>().onUserList[index]['${DatabaseHelper.colUserId}'],
                    groupUserId: 0,
                    group: false,
                  ),
                  child: TripListView(),
                ),
              ),
            ).then((value) {
              BlocProvider.of<UserExpenseBloc>(context).add(GetUserExpenseDataEvent(context));
            });
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => TripList(
            //       groupId: widget.groupId,
            //       userId: onUserList[index]['${DatabaseHelper.colUserId}'],
            //       groupUserId: 0,
            //       group: false,
            //     ),
            //   ),
            // ).then((value) async {
            //   await getUserData();
            // });
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
                  context.read<UserExpenseBloc>().onUserProfile[index]["${DatabaseHelper.colUserProfile}"] != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: MemoryImage(
                            base64Decode(context.read<UserExpenseBloc>().onUserProfile[index]["${DatabaseHelper.colUserProfile}"]),
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
                          "${context.read<UserExpenseBloc>().onUserList[index]["${DatabaseHelper.colTripUserName}"]}",
                          style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Paid: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<UserExpenseBloc>().onSumList[index]}",
                              style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                            ),
                            Text(
                              " (${context.read<UserExpenseBloc>().personDiffe[index] > 0 ? '+' : ''}${context.read<UserExpenseBloc>().personDiffe[index].toStringAsFixed(2)})",
                              style: TextStyleConstant.lightBlackRegular16.copyWith(
                                  fontSize: 13,
                                  color: context.read<UserExpenseBloc>().personDiffe[index] > 0 ? ColorConstant.greenColor : ColorConstant.redColor),
                            ),
                          ],
                        ),
                        Text(
                          "Per Head: ${PreferenceUtils.getString(key: selectedCurrency)}${num.parse(context.read<UserExpenseBloc>().perHeadTrip[index].toString()).toStringAsFixed(2)}",
                          style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_outlined,
                    color: Colors.black,
                    size: 28,
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
