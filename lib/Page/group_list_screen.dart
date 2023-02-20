import 'dart:convert';

import 'package:expense_manager/Bloc/Bloc/group_list_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/trip_list_bloc.dart';
import 'package:expense_manager/Bloc/Event/group_list_event.dart';
import 'package:expense_manager/Bloc/State/group_list_state.dart';
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

class GroupListView extends StatelessWidget {
  const GroupListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupListBloc, GroupListState>(
      builder: (context, state) {
        if (state is GroupListInitialState) {
          BlocProvider.of<GroupListBloc>(context).add(GetGroupDataEvent(context));
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
                "Group List",
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
        if (state is GroupListDataLoaded) {
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
                "Group List",
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
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left_outlined,
                size: 28,
              ),
            ),
            title: Text(
              "Group List",
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            elevation: 5,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  context.read<GroupListBloc>().userInfo[0]["${DatabaseHelper.colUserProfile}"] != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: MemoryImage(
                            base64Decode(context.read<GroupListBloc>().userInfo[0]["${DatabaseHelper.colUserProfile}"]),
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
                          "${context.read<GroupListBloc>().userInfo[0]["${DatabaseHelper.colUserName}"]}",
                          style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                        ),
                        Row(
                          children: [
                            Text(
                              "Paid: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<GroupListBloc>().userTotalExpense}",
                              style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                            ),
                            Text(
                              " (${context.read<GroupListBloc>().personDiffe > 0 ? '+' : ''}${context.read<GroupListBloc>().personDiffe.toStringAsFixed(2)})",
                              style: TextStyleConstant.lightBlackRegular16.copyWith(
                                fontSize: 13,
                                color: context.read<GroupListBloc>().personDiffe > 0 ? ColorConstant.greenColor : ColorConstant.redColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Per Head: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<GroupListBloc>().totalperHead.toStringAsFixed(2)}",
                          style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          (context.read<GroupListBloc>().onGroupList.length > 0 && context.read<GroupListBloc>().onGroupList != null)
              ? Expanded(child: groupListData(context))
              : Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            ImageConstant.noGroupFound,
                            height: 200,
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

  Widget groupListData(BuildContext context) {
    return ListView(padding: EdgeInsets.only(top: 0.0), children: [
      ...List.generate(context.read<GroupListBloc>().onGroupList.length, (index) {
        final diffe = context.read<GroupListBloc>().paid[index] - context.read<GroupListBloc>().allAmountinPerHEad[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context2) => BlocProvider(
                  create: (_) => TripListBloc(
                    userId: context.read<GroupListBloc>().userId,
                    groupId: context.read<GroupListBloc>().onGroupList[index]['${DatabaseHelper.colGroupId}'],
                    groupUserId: context.read<GroupListBloc>().userInfo[0]["${DatabaseHelper.colUserId}"],
                    group: true,
                  ),
                  child: TripListView(),
                ),
              ),
            ).then((value) {
              context.read<GroupListBloc>().backOption = value;
              BlocProvider.of<GroupListBloc>(context).add(GetGroupDataEvent(context));
            });
          },
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
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
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.read<GroupListBloc>().onGroupList[index]['${DatabaseHelper.colGroupName}'] ?? "",
                        style: TextStyleConstant.blackRegular14.copyWith(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 8),
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
                                children: [
                                  Text(
                                    "Paid: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<GroupListBloc>().paid[index]}",
                                    style: TextStyleConstant.blackRegular16.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    " (${diffe > 0 ? '+' : ''}${diffe.toStringAsFixed(2)})",
                                    style: TextStyleConstant.lightBlackRegular16
                                        .copyWith(fontSize: 13, color: diffe > 0 ? ColorConstant.greenColor : ColorConstant.redColor),
                                  ),
                                ],
                              ),
                              Text(
                                "Per Head: ${PreferenceUtils.getString(key: selectedCurrency)}${num.parse(context.read<GroupListBloc>().allAmountinPerHEad[index].toString()).toStringAsFixed(2)}",
                                style: TextStyleConstant.blackRegular16.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      )
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
        );
      }),
    ]);
  }
}
