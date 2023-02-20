import 'dart:convert';
import 'package:expense_manager/Bloc/Bloc/group_list_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/user_list_bloc.dart';
import 'package:expense_manager/Bloc/Event/user_list_event.dart';
import 'package:expense_manager/Bloc/State/user_list_state.dart';
import 'package:expense_manager/Page/group_list_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class UserListView extends StatelessWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserListBloc, UserListState>(
      builder: (context, state) {
        if (state is UserListInitialState) {
          BlocProvider.of<UserListBloc>(context).add(UserListLoadEvent(context));
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
              child: addUserButton(context),
            ),
          );
        }
        if (state is UserListDataLoaded) {
          return Scaffold(
            body: Center(
              child: bodyView(context),
            ),
            bottomNavigationBar: Container(
              height: 86,
              child: addUserButton(context),
            ),
          );
        }
        return Scaffold(
          body: Container(),
          bottomNavigationBar: Container(
            height: 86,
            child: addUserButton(context),
          ),
        );
      },
    );
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
              "Person",
              style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
            ),
          ),
          Expanded(
            child: (context.read<UserListBloc>().onUsersList.length > 0)
                ? userListData(context)
                : Container(
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
          ),
        ],
      ),
    );
  }

  Widget userListData(BuildContext context) {
    return ListView(padding: EdgeInsets.only(top: 0.0), children: [
      ...List.generate(context.read<UserListBloc>().onUsersList.length, (index) {
        return SwipeActionCell(
          key: ValueKey(index),
          fullSwipeFactor: 0.90,
          editModeOffset: 30,
          index: index,
          normalAnimationDuration: 300,
          deleteAnimationDuration: 200,
          // performsFirstActionWithFullSwipe: false,
          trailingActions: [
            SwipeAction(
              closeOnTap: true,
              forceAlignmentToBoundary: true,
              widthSpace: 60,
              color: Colors.transparent,
              content: context.read<UserListBloc>().onUserDelete[index].toString() == '[]'
                  ? _getIconButton(Colors.red, Icons.delete)
                  : _getIconButton(Colors.grey, Icons.delete),
              onTap: (handler) async {
                if (context.read<UserListBloc>().onUserDelete[index].toString() != '[]') {
                  customDialog(
                    onConfirm: () async {
                      Navigator.pop(context);
                    },
                    context: context,
                    content: "Can't delete this person. Because this person is already on trip",
                    // "This person can not delete. Because this person is already In trip",
                    title: "Delete",
                  );
                } else {
                  confirmDialog(
                    onConfirm: () async {
                      await dbHelper.userDelete(
                          id: context.read<UserListBloc>().onUsersList[index]["${DatabaseHelper.colUserId}"], tableName: DatabaseHelper.tblUsers);
                      Navigator.pop(context);
                      BlocProvider.of<UserListBloc>(context).add(GetUserDataEvent(context));
                    },
                    context: context,
                    content: "Do you really want to delete this person?",
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
              onTap: (handler) async {
                showDialog(
                  context: context,
                  builder: (BuildContext context2) {
                    return showAddPersonDialog(context.read<UserListBloc>().onUsersList[index], context);
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
                    create: (_) => GroupListBloc(
                      userId: context.read<UserListBloc>().onUsersList[index]['${DatabaseHelper.colUserId}'],
                      userExpense: int.parse(context.read<UserListBloc>().onUserExpense[index].toStringAsFixed(0)),
                    ),
                    child: GroupListView(),
                  ),
                ),
              ).then((value) {
                BlocProvider.of<UserListBloc>(context).add(GetUserDataEvent(context));
              });
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              elevation: 5,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: double.infinity,
                // alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    context.read<UserListBloc>().onUsersList[index]["${DatabaseHelper.colUserProfile}"] != null
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: MemoryImage(
                              base64Decode(
                                context.read<UserListBloc>().onUsersList[index]["${DatabaseHelper.colUserProfile}"],
                              ),
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
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${context.read<UserListBloc>().onUsersList[index]["${DatabaseHelper.colUserName}"]}",
                            style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                          ),
                          Row(
                            children: [
                              Text(
                                "Paid: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<UserListBloc>().onUserExpense[index].toStringAsFixed(0)}",
                                style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                              ),
                              Text(
                                context.read<UserListBloc>().diffe3.length > 0
                                    ? " (${context.read<UserListBloc>().diffe3[index] > 0 ? '+' : ''}${context.read<UserListBloc>().diffe3[index].toStringAsFixed(2)})"
                                    : ' (0.0)',
                                style: TextStyleConstant.lightBlackRegular16.copyWith(
                                  fontSize: 13,
                                  color: context.read<UserListBloc>().diffe3.length > 0
                                      ? context.read<UserListBloc>().diffe3[index] > 0
                                          ? ColorConstant.greenColor
                                          : ColorConstant.redColor
                                      : ColorConstant.redColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Per Head: ${PreferenceUtils.getString(key: selectedCurrency)}${context.read<UserListBloc>().perHeadTrip1.length > 0 ? context.read<UserListBloc>().perHeadTrip1[index].toStringAsFixed(2) : 0.0}",
                            style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
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
          ),
        );
      }),
    ]);
  }

  Widget addUserButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context2) {
            return showAddPersonDialog(null, context);
          },
        );
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
          "+ Add New Person",
          style: TextStyleConstant.whiteBold16.copyWith(fontSize: 15),
        ),
      ),
    );
  }

  // Add User

  showAddPersonDialog(userList, BuildContext context) {
    TextEditingController personNameController =
        userList == null ? TextEditingController() : TextEditingController(text: userList["${DatabaseHelper.colUserName}"]);
    var imageByte = userList == null ? null : base64Decode(userList["${DatabaseHelper.colUserProfile}"]);
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView(
                        // mainAxisSize: MainAxisSize.min,
                        shrinkWrap: true,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: Text(
                              userList == null ? "Add Person" : "Update Person",
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
                                        showToast("First enter user name");
                                      } else {
                                        context.read<UserListBloc>().userName = personNameController.text;
                                        context.read<UserListBloc>().userProfile =
                                            imageByte != null ? base64Encode(imageByte!) : context.read<UserListBloc>().defaultImgBytes;

                                        userList == null
                                            ? BlocProvider.of<UserListBloc>(context).add(AddPersonEvent(context))
                                            : BlocProvider.of<UserListBloc>(context)
                                                .add(UpdatePersonEvent(context, userList["${DatabaseHelper.colUserId}"]));
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
                                        userList == null ? "Save" : "Update",
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
                                  backgroundImage: MemoryImage(imageByte!),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
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
                                                  topLeft: Radius.circular(18),
                                                  topRight: Radius.circular(18),
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
                                                getImage("2").then(
                                                  (value) {
                                                    imageByte = base64Decode(value);
                                                    setState(() {});
                                                  },
                                                );
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
        ));
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
