import 'package:expense_manager/Bloc/Bloc/group_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/user_expense_bloc.dart';
import 'package:expense_manager/Bloc/Event/group_event.dart';
import 'package:expense_manager/Bloc/State/group_state.dart';
import 'package:expense_manager/Page/user_expense_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class GroupView extends StatelessWidget {
  const GroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(builder: (context, state) {
      if (state is GroupInitialState) {
        BlocProvider.of<GroupBloc>(context).add(GroupLoadEvent(context));
        return Scaffold(
          body: Center(
            child: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              size: 30,
              lineWidth: 3,
            ),
          ),
          bottomNavigationBar: Container(
            height: 86,
            child: addGroupExpenseButton(context),
          ),
        );
      }
      if (state is GroupDataLoading) {
        return Scaffold(
          body: Center(
            child: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              size: 30,
              lineWidth: 3,
            ),
          ),
          bottomNavigationBar: Container(
            height: 86,
            child: addGroupExpenseButton(context),
          ),
        );
      }
      if (state is GroupDataLoaded) {
        return Scaffold(
          body: Center(
            child: bodyView(context),
          ),
          bottomNavigationBar: Container(
            height: 86,
            child: addGroupExpenseButton(context),
          ),
        );
      }
      return Scaffold(
        body: Center(),
        bottomNavigationBar: Container(
          height: 86,
          child: addGroupExpenseButton(context),
        ),
      );
    });
  }

  Widget bodyView(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            // color: Colors.amber,
            padding: EdgeInsets.all(15),
            child: Text(
              "Group",
              style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
            ),
          ),
          Expanded(
            child: (context.read<GroupBloc>().onGroupList.length > 0)
                ? groupListData(context)
                : Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: Image.asset(
                        ImageConstant.noGroupFound,
                        height: 200,
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget groupListData(BuildContext context) {
    return ListView(padding: EdgeInsets.only(top: 0.0), children: [
      ...List.generate(context.read<GroupBloc>().onGroupList.length, (index) {
        return SwipeActionCell(
          key: ValueKey(index),
          trailingActions: [
            SwipeAction(
              closeOnTap: true,
              widthSpace: 60,
              forceAlignmentToBoundary: true,
              color: Colors.transparent,
              content: context.read<GroupBloc>().onGroupDelete[index].toString() == '[]'
                  ? _getIconButton(Colors.red, Icons.delete)
                  : _getIconButton(Colors.grey, Icons.delete),
              onTap: (handler) async {
                if (context.read<GroupBloc>().onGroupDelete[index].toString() != '[]') {
                  customDialog(
                    onConfirm: () async {
                      Navigator.pop(context);
                    },
                    context: context,
                    content: "Can't delete this Group. Because this Group is already on trip",
                    // "This Group does not delete. Because this group is already In trip",
                    title: "Delete",
                  );
                } else {
                  confirmDialog(
                    onConfirm: () async {
                      var del = await dbHelper.groupDelete(
                        id: context.read<GroupBloc>().onGroupList[index]["${DatabaseHelper.colGroupId}"],
                        tableName: DatabaseHelper.tblGroupExpense,
                      );

                      print("$del... deleted..");
                      Navigator.pop(context);
                      BlocProvider.of<GroupBloc>(context).add(GroupLoadingEvent(context));
                      BlocProvider.of<GroupBloc>(context).add(GetGroupDataEvent(context));
                    },
                    context: context,
                    content: "Do you really want to delete this group?",
                    title: "Delete",
                  );
                }
              },
            ),
            SwipeAction(
              closeOnTap: true,
              forceAlignmentToBoundary: true,
              color: Colors.transparent,
              widthSpace: 60,
              content: _getIconButton(ColorConstant.primaryColor, Icons.edit),
              onTap: (handler) {
                showDialog(
                  context: context,
                  builder: (BuildContext context2) {
                    return addGroupExpenseDialog(context.read<GroupBloc>().onGroupList[index], context);
                  },
                );
              },
            ),
          ],
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context2) => BlocProvider(
                    create: (_) => UserExpenseBloc(
                      groupId: context.read<GroupBloc>().onGroupList[index]['${DatabaseHelper.colGroupId}'],
                      groupName: context.read<GroupBloc>().onGroupList[index]['${DatabaseHelper.colGroupName}'],
                    ),
                    child: const UserExpenseView(),
                  ),
                ),
              ).then((value) {
                BlocProvider.of<GroupBloc>(context).add(GetGroupDataEvent(context));
              });
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.read<GroupBloc>().onGroupList[index]['${DatabaseHelper.colGroupName}'] ?? "",
                          style: TextStyleConstant.blackRegular14.copyWith(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
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
                                  Text(
                                    "Total Expense: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<GroupBloc>().groupTrips[index]}",
                                    style: TextStyleConstant.blackRegular16.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.black,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ]);
  }

  Widget addGroupExpenseButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context2) {
            return addGroupExpenseDialog(null, context);
          },
        );
        // print("${DateTime.now().millisecondsSinceEpoch}");
        // pushNamed(
        //     route: rtAddTripScreen,
        //     thenFunc: (value) {
        //       isLoaded = false;
        //       setState(() {});
        //       getData();
        //     });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorConstant.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "+ Add New Group",
          style: TextStyleConstant.whiteBold16.copyWith(fontSize: 15),
        ),
      ),
    );
  }

  // Add Group Expense
  addGroupExpenseDialog(group, BuildContext context) {
    TextEditingController groupNameController =
        group == null ? TextEditingController() : TextEditingController(text: group['${DatabaseHelper.colGroupName}']);
    return Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context2, setState) {
            return Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                        color: ColorConstant.primaryColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        )),
                    alignment: Alignment.center,
                    child: Text(
                      group == null ? "Add Group" : "Update Group",
                      style: TextStyleConstant.whiteRegular16,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: groupNameController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                              hintText: "Enter Group Name",
                              isDense: true,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 5.0,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Cancel",
                                      style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (groupNameController.text == "") {
                                      showToast("First enter group name");
                                    } else {
                                      context.read<GroupBloc>().groupName = groupNameController.text;
                                      group == null
                                          ? BlocProvider.of<GroupBloc>(context).add(AddGroupExpenseEvent(context))
                                          : BlocProvider.of<GroupBloc>(context).add(UpdateGroupEvent(context, group['${DatabaseHelper.colGroupId}']));
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 5.0,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      group == null ? "Save" : "Update",
                                      style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ));
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
