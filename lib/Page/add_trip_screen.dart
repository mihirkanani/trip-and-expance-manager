import 'dart:convert';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/Bloc/Bloc/add_trip_bloc.dart';
import 'package:expense_manager/Bloc/Event/add_trip_event.dart';
import 'package:expense_manager/Bloc/State/add_trip_state.dart';
import 'package:expense_manager/utils/app_utils.dart';
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

class AddTripView extends StatelessWidget {
  const AddTripView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddTripBloc, AddTripState>(builder: (context, state) {
      if (state is AddTripEmptyState) {
        BlocProvider.of<AddTripBloc>(context).add(AddTripLoadEvent(context));
        return Scaffold(
          body: SpinKitDualRing(
            color: ColorConstant.primaryColor,
            lineWidth: 3,
          ),
        );
      }
      if (state is AddTripDataLoaded) {
        return WillPopScope(
          onWillPop: () {
            Future.value(false);
            return confirmDialog(
              onConfirm: () async {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              context: context,
              content: "Are you sure exit without save trip?",
              title: "Exit",
            );
          },
          child: Scaffold(
            appBar: appBar(context),
            body: bodyView(context),
          ),
        );
      }
      return Scaffold(
        body: Container(),
      );
    });
  }

  appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: InkWell(
        onTap: () {
          confirmDialog(
            onConfirm: () async {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            context: context,
            content: "Are you sure exit without save trip?",
            title: "Exit",
          );
          // popNavigation();
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Trip Info",
            style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  bodyView(BuildContext context) {
    return ListView(
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context2) {
                return selectImageTypeDialog(context);
              },
            );
          },
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              image: context.read<AddTripBloc>().tripImageData != null
                  ? DecorationImage(
                      image: MemoryImage(
                        base64Decode(context.read<AddTripBloc>().tripImageData),
                      ),
                      fit: BoxFit.fill,
                    )
                  : DecorationImage(
                      image: AssetImage(ImageConstant.tripImg),
                      fit: BoxFit.fill,
                    ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Add Your Trip Background Image",
                  style: TextStyleConstant.whiteBold14.copyWith(letterSpacing: 2),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4C4C4).withOpacity(0.5),
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
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SvgPicture.asset(ImageConstant.calendarIcon),
                  const SizedBox(
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
                          context.read<AddTripBloc>().beginDate = value.start;
                          context.read<AddTripBloc>().endDate = value.end;
                          BlocProvider.of<AddTripBloc>(context).add(DataFillChangeEvent());
                        }
                      });
                    },
                    child: Text(
                      (context.read<AddTripBloc>().endDate != null && context.read<AddTripBloc>().beginDate != null)
                          ? parseDateRange(context.read<AddTripBloc>().beginDate!, context.read<AddTripBloc>().endDate!)
                          : "select dates",
                      style: TextStyleConstant.blackRegular14,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SvgPicture.asset(ImageConstant.tripIcon),
                  // SizedBox(width: 10.w,),
                  Expanded(
                    child: CommonTextfield(
                      controller: context.read<AddTripBloc>().tripNameController,
                      hintText: "Trip Name",
                    ),
                  )
                ],
              ),
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SvgPicture.asset(ImageConstant.descriptionIcon),
                  Expanded(
                    child: CommonTextfield(
                      controller: context.read<AddTripBloc>().placeDescriptioneController,
                      hintText: "Place Name",
                    ),
                  )
                ],
              ),
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
                  if (context.read<AddTripBloc>().onGroupList.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    showDialog(
                      context: context,
                      builder: (BuildContext context2) {
                        return selectGroupDialog(context);
                      },
                    ).then((value) {
                      BlocProvider.of<AddTripBloc>(context).add(DataFillChangeEvent());
                    });
                  } else {
                    FocusScope.of(context).unfocus();
                    showToast("First Add Group");
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline_outlined, color: ColorConstant.primaryColor, size: 26),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            context.read<AddTripBloc>().selectedGroup.toString() == 'null'
                                ? "Select Group"
                                : context.read<AddTripBloc>().selectedGroup[DatabaseHelper.colGroupName],
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
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                    context.read<AddTripBloc>().selectedGroup.toString() == 'null'
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 38,
                              ),
                              Text(
                                "Tap here to select group",
                                style: TextStyleConstant.blackRegular14.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF888888),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
                  if (context.read<AddTripBloc>().onUsersList.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    showDialog(
                      context: context,
                      builder: (BuildContext context2) {
                        return selectUsersDialog(context);
                      },
                    ).then((value) {
                      BlocProvider.of<AddTripBloc>(context).add(DataFillChangeEvent());
                    });
                  } else {
                    FocusScope.of(context).unfocus();
                    showToast("First Add Person");
                  }
                  // showAddPersonDialog();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(ImageConstant.personDetailIcon),
                        const SizedBox(
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
                            ).then((value) {
                              BlocProvider.of<AddTripBloc>(context).add(DataFillChangeEvent());
                            });
                          },
                          child: Icon(
                            Icons.add,
                            color: ColorConstant.primaryColor,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 34,
                        ),
                        Text(
                          "Tap here to select persons",
                          style: TextStyleConstant.blackRegular14.copyWith(
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF888888),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 1,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        context.read<AddTripBloc>().userDataList.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: context.read<AddTripBloc>().userDataList.length,
                padding: const EdgeInsets.only(top: 0),
                itemBuilder: (BuildContext context, int index) {
                  return StatefulBuilder(builder: (context2,setState){
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
                                  context.read<AddTripBloc>().userDataList.remove(context.read<AddTripBloc>().userDataList[index]);
                                  context.read<AddTripBloc>().userPart.remove(index);
                                  BlocProvider.of<AddTripBloc>(context).add(DataReload(context));
                                 setState((){});
                                  Navigator.pop(context);
                                },
                                context: context,
                                content: "Do you really want to delete this person?",
                                title: "Delete");
                          },
                        ),
                      ],
                      child: listItem(context.read<AddTripBloc>().userDataList[index], index, context),
                    );
                  });
                },
              )
            : Container(),
        const SizedBox(
          height: 15,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: GestureDetector(
            onTap: () {
              if (context.read<AddTripBloc>().beginDate == null || context.read<AddTripBloc>().endDate == null) {
                showToast("Select date range");
              } else if (context.read<AddTripBloc>().tripNameController.text == "") {
                showToast("Enter trip name");
              } else if (context.read<AddTripBloc>().placeDescriptioneController.text == "") {
                showToast("Enter place name");
              } else if (context.read<AddTripBloc>().selectedGroup == null) {
                showToast("Select Group");
              } else {
                BlocProvider.of<AddTripBloc>(context).add(AddTripDataEvent(context));
              }
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
                "Save Trip",
                style: TextStyleConstant.whiteBold16.copyWith(fontSize: 15),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  listItem(var item, var index, BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        elevation: 5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              item[DatabaseHelper.colUserProfile] != null && item[DatabaseHelper.colUserProfile] != ""
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: MemoryImage(base64Decode(item[DatabaseHelper.colUserProfile])),
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(ImageConstant.defaultPersonImg),
                    ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item[DatabaseHelper.colUserName]}",
                      style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              StatefulBuilder(
                builder: (context2, stateFull) {
                  return Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context.read<AddTripBloc>().userPart[index] <= 0) {
                            showToast("Please Enter Valid Value");
                          } else {
                            context.read<AddTripBloc>().userPart[index] -= 0.5;
                            stateFull(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorConstant.primaryColor.withOpacity(0.8),
                          ),
                          child: const Icon(Icons.remove, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(context.read<AddTripBloc>().userPart[index].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        onTap: () {
                          context.read<AddTripBloc>().userPart[index] += 0.5;
                          stateFull(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorConstant.primaryColor.withOpacity(0.8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
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

  selectImageTypeDialog(BuildContext context) {
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
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Select Image Type",
                    style: TextStyleConstant.whiteRegular16,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    getImage("2").then((value) {
                      if (value != null) {
                        context.read<AddTripBloc>().tripImageData = value;
                        BlocProvider.of<AddTripBloc>(context).add(DataFillChangeEvent());
                        // setState(() {});
                      }
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
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
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          getImage("1").then((value) {
                            if (value != null) {
                              context.read<AddTripBloc>().tripImageData = value;
                              BlocProvider.of<AddTripBloc>(context).add(DataFillChangeEvent());
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  selectGroupDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context2, setState) {
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 45,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Group List",
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 0.0, maxHeight: MediaQuery.of(context).size.height / 2),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: context.read<AddTripBloc>().onGroupList.length,
                    itemBuilder: (BuildContext context2, int index) {
                      return GestureDetector(
                        onTap: () async {
                          context.read<AddTripBloc>().selectedGroup = await context.read<AddTripBloc>().onGroupList[index];
                          setState(() {});
                          Navigator.pop(context2);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: context.read<AddTripBloc>().selectedGroup.toString() == 'null'
                                ? Colors.white
                                : context.read<AddTripBloc>().selectedGroup[DatabaseHelper.colGroupId] ==
                                        context.read<AddTripBloc>().onGroupList[index][DatabaseHelper.colGroupId]
                                    ? ColorConstant.primaryColor
                                    : Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.read<AddTripBloc>().onGroupList[index][DatabaseHelper.colGroupName],
                            style: TextStyleConstant.blackRegular14.copyWith(
                              color: context.read<AddTripBloc>().selectedGroup.toString() == 'null'
                                  ? ColorConstant.primaryColor
                                  : context.read<AddTripBloc>().selectedGroup[DatabaseHelper.colGroupId] !=
                                          context.read<AddTripBloc>().onGroupList[index][DatabaseHelper.colGroupId]
                                      ? ColorConstant.primaryColor
                                      : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                )
              ],
            ),
          );
        },
      ),
    );
  }

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
                    borderRadius: const BorderRadius.only(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: groupNameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                            hintText: "Enter Group Name",
                            isDense: true,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: const [
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
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (groupNameController.text == "") {
                                    showToast("First enter group name");
                                  } else {
                                    context.read<AddTripBloc>().groupName = groupNameController.text;
                                    BlocProvider.of<AddTripBloc>(context).add(AddGroupExpenseEvent(context));
                                    setState(() {});
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: const [
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 45,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: const BorderRadius.only(
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
                          setState(() {});
                          BlocProvider.of<AddTripBloc>(context).add(GetDataLoadEvent(context));
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: context.read<AddTripBloc>().onUsersList.length,
                    itemBuilder: (BuildContext contexts, int index) {
                      bool isContain = false;
                      for (var i in context.read<AddTripBloc>().userDataList) {
                        // onUsersList.remove(userDataList[i]);
                        if (i[DatabaseHelper.colUserId] == context.read<AddTripBloc>().onUsersList[index][DatabaseHelper.colUserId]) {
                          isContain = true;
                          break;
                        }
                      }
                      return GestureDetector(
                        onTap: () {
                          if (isContain) {
                            context.read<AddTripBloc>().selectedIndex.remove(index);
                            context.read<AddTripBloc>().userDataList.removeWhere(
                                  (element) =>
                                      element[DatabaseHelper.colUserName] ==
                                      context.read<AddTripBloc>().onUsersList[index][DatabaseHelper.colUserName],
                                );
                            setState(() {});
                          } else {
                            print(" ADD UserPart ");
                            context.read<AddTripBloc>().userDataList.add(context.read<AddTripBloc>().onUsersList[index]);
                            context.read<AddTripBloc>().selectedIndex.add(index);
                            context.read<AddTripBloc>().userPart.add(1);
                            setState(() {});
                          }
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: isContain ? ColorConstant.primaryColor : Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.read<AddTripBloc>().onUsersList[index][DatabaseHelper.colUserName],
                            style: TextStyleConstant.blackRegular14.copyWith(color: isContain ? Colors.white : ColorConstant.primaryColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
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
                    margin: const EdgeInsets.only(top: 50),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: ListView(
                      // mainAxisSize: MainAxisSize.min,
                      shrinkWrap: true,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Center(
                            child: Text(
                          "Add Person",
                          style: TextStyleConstant.blackBold16.copyWith(letterSpacing: 0.5, fontSize: 16),
                        )),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: personNameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                              hintText: "Enter person name",
                              isDense: true,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: const [
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
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (personNameController.text == "") {
                                      showToast("First enter person name");
                                    } else {
                                      context.read<AddTripBloc>().userName = personNameController.text;
                                      context.read<AddTripBloc>().userProfile =
                                          imageByte != null ? base64Encode(imageByte) : context.read<AddTripBloc>().defaultImgBytes;
                                      context.read<AddTripBloc>().userPart.add(1);
                                      BlocProvider.of<AddTripBloc>(context).add(AddUserEvent(context));
                                      setState(() {});
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: const [
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
                        const SizedBox(height: 15),
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
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                    contentPadding: EdgeInsets.zero,
                                    content: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color: ColorConstant.primaryColor,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            mainAxisSize: MainAxisSize.min,
                                            children: const <Widget>[
                                              Text(
                                                "Select Image Type",
                                                style: TextStyle(color: Colors.white, fontSize: 16.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
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
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
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
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            getImage("1").then((value) {
                                              imageByte = base64Decode(value);
                                              setState(() {});
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
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
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
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
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
