import 'dart:convert';
import 'package:expense_manager/Bloc/Bloc/edit_trip_bloc.dart';
import 'package:expense_manager/Bloc/Event/edit_trip_event.dart';
import 'package:expense_manager/Bloc/State/edit_trip_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/center_button.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/common_textfield.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class EditTripView extends StatelessWidget {
  const EditTripView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTripBloc, EditTripState>(builder: (context, state) {
      if (state is EditTripEmptyState) {
        BlocProvider.of<EditTripBloc>(context).add(EditTripLoadEvent(context));
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
      if (state is EditTripDataLoaded) {
        return Scaffold(
          appBar: appBar(context),
          body: bodyView(context),
        );
      }
      return Container();
    });
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Edit Trip Info",
            style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget bodyView(BuildContext context) {
    return ListView(
      children: [
        InkWell(
          onTap: () {
            // selectImageTypeDialog();
          },
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              image: context.read<EditTripBloc>().tripImageData != null
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(context.read<EditTripBloc>().tripImageData)),
                      fit: BoxFit.fill,
                    )
                  : DecorationImage(
                      image: AssetImage(ImageConstant.tripImg),
                      fit: BoxFit.fill,
                    ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Add Your Trip Background Image",
                  style: TextStyleConstant.whiteBold14.copyWith(letterSpacing: 2),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFC4C4C4).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: SvgPicture.asset(
                    ImageConstant.addImageIcon,
                    height: 30,
                    width: 30,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SvgPicture.asset(ImageConstant.calendarIcon),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2015),
                        lastDate: DateTime(DateTime.now().year + 2),
                      ).then((value) {
                        if (value != null) {
                          context.read<EditTripBloc>().beginDate = value.start;
                          context.read<EditTripBloc>().endDate = value.end;
                          BlocProvider.of<EditTripBloc>(context).add(DataReload(context));
                        }
                      });
                    },
                    child: Text(
                      (context.read<EditTripBloc>().endDate != null && context.read<EditTripBloc>().beginDate != null)
                          ? parseDateRange(context.read<EditTripBloc>().beginDate!, context.read<EditTripBloc>().endDate!)
                          : "select dates",
                      style: TextStyleConstant.blackRegular14,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 1,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SvgPicture.asset(ImageConstant.tripIcon),
                  // SizedBox(width: 10.w,),
                  Expanded(child: CommonTextfield(controller: context.read<EditTripBloc>().tripNameController, hintText: "Trip Name"))
                ],
              ),
              Divider(
                height: 1,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SvgPicture.asset(ImageConstant.descriptionIcon),
                  Expanded(
                    child: CommonTextfield(controller: context.read<EditTripBloc>().placeDescriptionController, hintText: "Place Name"),
                  )
                ],
              ),
              Divider(
                height: 1,
              ),
              SizedBox(
                height: 25,
              ),
              (context.read<EditTripBloc>().selectedGroup == null && context.read<EditTripBloc>().onGroupList.length == 0)
                  ? Container()
                  : InkWell(
                      onTap: () {
                        if (context.read<EditTripBloc>().onGroupList != "" && context.read<EditTripBloc>().onGroupList.length != 0) {
                          FocusScope.of(context).unfocus();
                          showDialog(
                            context: context,
                            builder: (BuildContext context2) {
                              return selectGroupDialog(context);
                            },
                          ).then((value) {
                            BlocProvider.of<EditTripBloc>(context).add(DataReload(context));
                          });
                        } else {
                          FocusScope.of(context).unfocus();
                          showToast("First Add Group");
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.people_outline_outlined, color: ColorConstant.primaryColor, size: 26),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              context.read<EditTripBloc>().selectedGroup.toString() == 'null'
                                  ? "Select Group"
                                  : context.read<EditTripBloc>().selectedGroup['${DatabaseHelper.colGroupName}'],
                              style: TextStyleConstant.blackRegular14,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              showDialog(
                                context: context,
                                builder: (BuildContext context2) {
                                  return addGroupExpenseDialog(context);
                                },
                              );
                            },
                            child: Icon(
                              Icons.add,
                              color: ColorConstant.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 1,
              ),
              SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
                  if (context.read<EditTripBloc>().onUsersList.length != 0 && context.read<EditTripBloc>().onUsersList != '') {
                    FocusScope.of(context).unfocus();
                    showDialog(
                      context: context,
                      builder: (BuildContext context2) {
                        return selectUsersDialog(context);
                      },
                    ).then((value) {
                      BlocProvider.of<EditTripBloc>(context).add(DataReload(context));
                    });
                  } else {
                    FocusScope.of(context).unfocus();
                    showToast("Please Enter Person First");
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(ImageConstant.personDetailIcon),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                            child: Text(
                          "Person Detail",
                          style: TextStyleConstant.blackRegular14,
                        )),
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            showDialog(
                              context: context,
                              builder: (BuildContext context2) {
                                return showAddPersonDialog(context);
                              },
                            );
                          },
                          child: Icon(
                            Icons.add,
                            color: ColorConstant.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 34,
                        ),
                        Text(
                          "Tap here to select persons",
                          style: TextStyleConstant.blackRegular14.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF888888),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 1,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        context.read<EditTripBloc>().editPersonList.length > 0
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: context.read<EditTripBloc>().editPersonList.length,
                padding: EdgeInsets.only(top: 0),
                itemBuilder: (BuildContext context, int index) {
                  print("Person Expense Total is ${context.read<EditTripBloc>().editPersonList[index]['expense']}");
                  return SwipeActionCell(
                    key: ValueKey(index),
                    trailingActions: [
                      SwipeAction(
                        closeOnTap: true,
                        forceAlignmentToBoundary: true,
                        color: Colors.transparent,
                        content: context.read<EditTripBloc>().editPersonList[index]['expense'] == '0'
                            ? _getIconButton(Colors.red, Icons.delete)
                            : _getIconButton(Colors.grey, Icons.delete),
                        onTap: (handler) async {
                          print("Edit Expoense ${context.read<EditTripBloc>().editPersonList[index]['expense']}");
                          if (context.read<EditTripBloc>().editPersonList[index]['expense'] != '0') {
                            customDialog(
                              onConfirm: () async {
                                context.read<EditTripBloc>().userDataList.remove(context.read<EditTripBloc>().userDataList[index]);
                                context.read<EditTripBloc>().userPart.remove(index);
                                BlocProvider.of<EditTripBloc>(context).add(DataReload(context));
                                Navigator.pop(context);
                              },
                              context: context,
                              content: "This person can't be removed. because this person has already spent on the trip",
                              title: "Delete",
                            );
                          } else {
                            confirmDialog(
                                onConfirm: () async {
                                  print("Trip User Id ${context.read<EditTripBloc>().editPersonList[index]["${DatabaseHelper.colUserId}"]}");
                                  print("Trip User Id 2 ${context.read<EditTripBloc>().tripID}");
                                  var del = await dbHelper.tripUserDelete(
                                      tableName: '${DatabaseHelper.tblTripUsers}',
                                      id: context.read<EditTripBloc>().editPersonList[index]["${DatabaseHelper.colUserId}"],
                                      tripId: context.read<EditTripBloc>().tripID);
                                  context.read<EditTripBloc>().editPersonList.removeAt(index);
                                  print("$del... deleted..");
                                  print("deleted trip user.. ${context.read<EditTripBloc>().onUsersList}");
                                  BlocProvider.of<EditTripBloc>(context).add(DataReload(context));
                                  Navigator.pop(context);
                                },
                                context: context,
                                content: "Do you really want to delete this person?",
                                title: "Delete");
                          }
                        },
                      ),
                    ],
                    child: listEditPersonItem(context.read<EditTripBloc>().editPersonList[index], index),
                  );
                },
              )
            : Container(),
        context.read<EditTripBloc>().userDataList.length > 0
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: context.read<EditTripBloc>().userDataList.length,
                padding: EdgeInsets.only(top: 0),
                itemBuilder: (BuildContext context, int index) {
                  return SwipeActionCell(
                    key: ValueKey(index),
                    trailingActions: [
                      SwipeAction(
                        closeOnTap: true,
                        forceAlignmentToBoundary: true,
                        color: Colors.transparent,
                        content: _getIconButton(Colors.red, Icons.delete),
                        onTap: (handler) async {
                          confirmDialog(
                              onConfirm: () async {
                                context.read<EditTripBloc>().userDataList.remove(context.read<EditTripBloc>().userDataList[index]);
                                Navigator.pop(context);
                              },
                              context: context,
                              content: "Do you really want to delete this person?",
                              title: "Delete");
                        },
                      ),
                    ],
                    child: listItem(context.read<EditTripBloc>().userDataList[index], index, context),
                  );
                },
              )
            : Container(),
        SizedBox(
          height: 15,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: GestureDetector(
            onTap: () {
              if (context.read<EditTripBloc>().beginDate == null || context.read<EditTripBloc>().endDate == null) {
                showToast("Select date range");
              } else if (context.read<EditTripBloc>().tripNameController.text == "") {
                showToast("Enter trip name");
              } else if (context.read<EditTripBloc>().placeDescriptionController.text == "") {
                showToast("Enter place name");
              } else {
                BlocProvider.of<EditTripBloc>(context).add(UpdateTripEvent(context));
                showToast("Update Successfully");
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xffFE7317),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 2,
                      color: Colors.black12,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Update Trip",
                  style: TextStyleConstant.whiteBold16.copyWith(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  selectGroupDialog(BuildContext context) {
    return Dialog(
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
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 45,
                  decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      )),
                  alignment: Alignment.center,
                  child: Text(
                    "Group List",
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                ConstrainedBox(
                  constraints: new BoxConstraints(
                    minHeight: 0,
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: context.read<EditTripBloc>().onGroupList.length,
                    itemBuilder: (BuildContext context2, int index) {
                      return GestureDetector(
                        onTap: () async {
                          context.read<EditTripBloc>().selectedGroup = await context.read<EditTripBloc>().onGroupList[index];
                          setState(() {});
                          print("Group Selected ${context.read<EditTripBloc>().selectedGroup['${DatabaseHelper.colGroupName}']}");
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: context.read<EditTripBloc>().selectedGroup['${DatabaseHelper.colGroupId}'] ==
                                    context.read<EditTripBloc>().onGroupList[index]['${DatabaseHelper.colGroupId}']
                                ? ColorConstant.primaryColor
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.read<EditTripBloc>().onGroupList[index]["${DatabaseHelper.colGroupName}"],
                            style: TextStyleConstant.blackRegular14.copyWith(
                              color: context.read<EditTripBloc>().selectedGroup['${DatabaseHelper.colGroupId}'] !=
                                      context.read<EditTripBloc>().onGroupList[index]['${DatabaseHelper.colGroupId}']
                                  ? ColorConstant.primaryColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Add Group Expense
  addGroupExpenseDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();
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
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Add Group",
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
                                    context.read<EditTripBloc>().groupName = groupNameController.text;
                                    BlocProvider.of<EditTripBloc>(context).add(AddGroupExpansesEvent(context));
                                    setState(() {});
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
                                    "Save",
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
      ),
    );
  }

  selectUsersDialog(BuildContext context) {
    return Dialog(
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
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 45,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Person List",
                        style: TextStyleConstant.whiteBold16,
                      ),
                      InkWell(
                        onTap: () {
                          context.read<EditTripBloc>().userDataList = context.read<EditTripBloc>().selectedUsers;
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                // ignore: missing_return
                ConstrainedBox(
                  constraints: new BoxConstraints(
                    minHeight: 0,
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: context.read<EditTripBloc>().onUsersList.length,
                    itemBuilder: (BuildContext context2, int index) {
                      print("Selected User ${context.read<EditTripBloc>().selectedUsers.contains(context.read<EditTripBloc>().onUsersList[index])}");
                      return GestureDetector(
                        onTap: () {
                          if (context.read<EditTripBloc>().selectedUsers.contains(context.read<EditTripBloc>().onUsersList[index])) {
                            print("Removed");
                            context.read<EditTripBloc>().selectedIndex.remove(index);
                            context.read<EditTripBloc>().selectedUsers.removeWhere(
                                  (element) =>
                                      element["${DatabaseHelper.colUserName}"] ==
                                      context.read<EditTripBloc>().onUsersList[index]["${DatabaseHelper.colUserName}"],
                                );
                            print("Removed Success");
                          } else {
                            print("Added");
                            context.read<EditTripBloc>().selectedUsers.add(context.read<EditTripBloc>().onUsersList[index]);
                            context.read<EditTripBloc>().selectedIndex.add(index);
                            print("Added Success");
                            context.read<EditTripBloc>().userPart.add(1.0);
                          }
                          print("${context.read<EditTripBloc>().selectedUsers.length}");
                          print("${context.read<EditTripBloc>().selectedUsers}");
                          setState(() {});
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: context.read<EditTripBloc>().selectedUsers.contains(context.read<EditTripBloc>().onUsersList[index])
                                ? ColorConstant.primaryColor
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.read<EditTripBloc>().onUsersList[index]["${DatabaseHelper.colUserName}"],
                            style: TextStyleConstant.blackRegular14.copyWith(
                              color: context.read<EditTripBloc>().selectedUsers.contains(context.read<EditTripBloc>().onUsersList[index])
                                  ? Colors.white
                                  : ColorConstant.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  showAddPersonDialog(BuildContext context) {
    TextEditingController personNameController = TextEditingController();
    var imageByte;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context2, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: ListView(
                      // mainAxisSize: MainAxisSize.min,
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: Text(
                            "Add Person",
                            style: TextStyleConstant.blackBold16.copyWith(letterSpacing: 0.5, fontSize: 16),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                            controller: personNameController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                              hintText: "Enter person name",
                              isDense: true,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
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
                                    if (personNameController.text == "") {
                                      showToast("First enter person name");
                                    } else {
                                      context.read<EditTripBloc>().userName = personNameController.text;
                                      context.read<EditTripBloc>().userProfile =
                                          imageByte != null ? base64Encode(imageByte) : context.read<EditTripBloc>().defaultImgBytes;
                                      context.read<EditTripBloc>().userPart.add(1);
                                      BlocProvider.of<EditTripBloc>(context).add(AddUserEvent(context));
                                      setState(() {});
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
                                      "Save",
                                      style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                  Center(
                    child: Stack(
                      children: [
                        imageByte != null
                            ? CircleAvatar(
                                radius: 45,
                                backgroundImage: MemoryImage(imageByte),
                              )
                            : CircleAvatar(
                                radius: 45,
                                backgroundImage: AssetImage(ImageConstant.defaultPersonImg),
                              ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                    contentPadding: EdgeInsets.zero,
                                    content: Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              color: ColorConstant.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  "Select Image Type",
                                                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              getImage("2").then((value) {
                                                imageByte = base64Decode(value);
                                                setState(() {});
                                              });
                                            },
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Camera",
                                                      style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              getImage("1").then((value) {
                                                imageByte = base64Decode(value);
                                                setState(() {});
                                              });
                                            },
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Gallery",
                                                      style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: SvgPicture.asset(
                                ImageConstant.addImageIcon,
                                height: 15,
                                width: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          );
        },
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

  listEditPersonItem(var item, var index) {
    return InkWell(
      onTap: () {},
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
              item["${DatabaseHelper.colTripUserProfile}"] != null && item["${DatabaseHelper.colTripUserProfile}"] != ""
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: MemoryImage(
                        base64Decode(item["${DatabaseHelper.colTripUserProfile}"]),
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
                      "${item["${DatabaseHelper.colTripUserName}"]}",
                      style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              StatefulBuilder(
                builder: (context, stateFull) {
                  return Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (item["${DatabaseHelper.colTripUserPart}"] <= 0) {
                            // showToast("Please Enter Valid Value");
                          } else {
                            stateFull(() {
                              item["${DatabaseHelper.colTripUserPart}"] -= 0.5;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorConstant.primaryColor.withOpacity(0.8),
                          ),
                          child: Icon(Icons.remove, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        item["${DatabaseHelper.colTripUserPart}"].toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        onTap: () {
                          stateFull(() {
                            item["${DatabaseHelper.colTripUserPart}"] += 0.5;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorConstant.primaryColor.withOpacity(0.8),
                          ),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  listItem(var item, var index, BuildContext context) {
    return StatefulBuilder(builder: (context2, setState) {
      return InkWell(
        onTap: () {},
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
                item["${DatabaseHelper.colUserProfile}"] != null && item["${DatabaseHelper.colUserProfile}"] != ""
                    ? CircleAvatar(
                        radius: 25,
                        backgroundImage: MemoryImage(
                          base64Decode(item["${DatabaseHelper.colUserProfile}"]),
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
                        "${item["${DatabaseHelper.colUserName}"]}",
                        style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (context.read<EditTripBloc>().userPart[index] <= 0) {
                          showToast("Please Enter Valid Value");
                        } else {
                          context.read<EditTripBloc>().userPart[index] -= 0.5;
                          setState(() {});
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: ColorConstant.primaryColor.withOpacity(0.8),
                        ),
                        child: Icon(Icons.remove, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(context.read<EditTripBloc>().userPart[index].toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 16,
                    ),
                    InkWell(
                      onTap: () {
                        context.read<EditTripBloc>().userPart[index] += 0.5;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: ColorConstant.primaryColor.withOpacity(0.8),
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
