import 'dart:convert';
import 'package:expense_manager/Bloc/Bloc/view_edit_expense_bloc.dart';
import 'package:expense_manager/Bloc/Event/view_edit_expense_event.dart';
import 'package:expense_manager/Bloc/State/view_edit_expense_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/common_textfield.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class ViewEditExpenseView extends StatelessWidget {
  const ViewEditExpenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewEditExpenseBloc, ViewEditExpenseState>(
      builder: (context, state) {
        if (state is ViewEditExpenseEmptyState) {
          context.read<ViewEditExpenseBloc>().add(ViewEditExpenseLoadEvent());
          context.read<ViewEditExpenseBloc>().add(GetDataLoadEvent());
        }
        if (state is ViewEditExpenseLoading) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: ColorConstant.primaryColor,
              onPressed: () {
                // showImageDialog();
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
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
        if (state is ViewEditExpenseLoaded) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: ColorConstant.primaryColor,
              onPressed: () {
                showDialog(
                  context: context,
                  // barrierDismissible: false,
                  builder: (BuildContext contextg) {
                    return showImageDialog(context);
                  },
                ).then((value) {
                  BlocProvider.of<ViewEditExpenseBloc>(context).add(ChangeTabEvent(context));
                });
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
            appBar: appBar(context),
            body: Column(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context2) {
                            return addExpensesDialog(context);
                          },
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 5,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              context.read<ViewEditExpenseBloc>().selectedCat[DatabaseHelper.colCateId] > 9 &&
                                      context.read<ViewEditExpenseBloc>().selectedCat[DatabaseHelper.colCateId] < 99
                                  ? Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: HexColor(context.read<ViewEditExpenseBloc>().selectedCat[DatabaseHelper.colCateColor]),
                                        borderRadius: BorderRadius.circular(500),
                                      ),
                                      child: showCategoryIcon(
                                        int.parse(context.read<ViewEditExpenseBloc>().selectedCat[DatabaseHelper.colCateIcon]),
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: HexColor(context.read<ViewEditExpenseBloc>().selectedCat[DatabaseHelper.colCateColor]),
                                        borderRadius: BorderRadius.circular(500),
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/icons/category/${context.read<ViewEditExpenseBloc>().selectedCat[DatabaseHelper.colCateIcon]}.svg",
                                        color: Colors.white,
                                      ),
                                    ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${context.read<ViewEditExpenseBloc>().selectedCat[DatabaseHelper.colCategoryName]}",
                                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      context.read<ViewEditExpenseBloc>().remarkController.text,
                                      textAlign: TextAlign.justify,
                                      style: TextStyleConstant.blackRegular16,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<ViewEditExpenseBloc>().amountController.text}",
                                style: TextStyleConstant.blackRegular16.copyWith(color: ColorConstant.redColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: cameraTab(context),
                )
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 70,
      leading: InkWell(
        onTap: () {
          confirmDialog(
            onConfirm: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            context: context,
            content: "Do you want to discard your changes?",
            title: "Discard Changes",
          );
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
            "View/Edit Expenses",
            style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () {
            BlocProvider.of<ViewEditExpenseBloc>(context).add(InsertExpenseEvent(context));
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: ColorConstant.primaryColor),
            ),
            child: Row(
              children: [
                Text(
                  "Update",
                  style: TextStyle(
                    color: ColorConstant.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.done,
                  color: ColorConstant.primaryColor,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  addExpensesDialog(BuildContext context) {
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
                    "Update Expense",
                    style: TextStyleConstant.whiteRegular16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
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
                          controller: context.read<ViewEditExpenseBloc>().amountController,
                          style: const TextStyle(color: Colors.black),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                            hintText: "Enter amount",
                            isDense: true,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: context.read<ViewEditExpenseBloc>().selectedDate!,
                            firstDate: DateTime(2021),
                            lastDate: DateTime(2101),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData(
                                  primaryColor: ColorConstant.primaryColor,
                                  primarySwatch: const MaterialColor(
                                    0xffFE7317,
                                    <int, Color>{
                                      50: Color(0xffFE7317), //10%
                                      100: Color(0xffFE7317), //20%
                                      200: Color(0xffFE7317), //30%
                                      300: Color(0xffFE7317), //40%
                                      400: Color(0xffFE7317), //50%
                                      500: Color(0xffFE7317), //60%
                                      600: Color(0xffFE7317), //70%
                                      700: Color(0xffFE7317), //80%
                                      800: Color(0xffFE7317), //90%
                                      900: Color(0xffFE7317), //100%
                                    },
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          ).then((value) {
                            if (value == null) return;
                            context.read<ViewEditExpenseBloc>().selectedDate = value;
                            setState(() {});
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
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
                          child: Text(
                            DateFormat("dd, MMM yyyy").format(context.read<ViewEditExpenseBloc>().selectedDate!),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          await showTimePicker(
                            context: context,
                            initialTime: BlocProvider.of<ViewEditExpenseBloc>(context).time,
                          ).then((value) {
                            BlocProvider.of<ViewEditExpenseBloc>(context).time = value!;
                            BlocProvider.of<ViewEditExpenseBloc>(context).add(ChangeDateAndTimeEvent(context));
                            setState(() {});
                            return null;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
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
                          child: Text(
                            context.read<ViewEditExpenseBloc>().time.format(context),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                          controller: context.read<ViewEditExpenseBloc>().remarkController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                            hintText: "Enter remark",
                            isDense: true,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFF999999), borderRadius: BorderRadius.circular(10)),
                                child: const Text(
                                  "Cancel",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (context.read<ViewEditExpenseBloc>().amountController.text == "") {
                                  showToast("Enter amount");
                                } else {
                                  Navigator.pop(context);
                                  setState(() {});
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ColorConstant.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Update",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          )
                        ],
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

  Widget cameraTab(BuildContext context) {
    return (BlocProvider.of<ViewEditExpenseBloc>(context).imageDataList != null &&
                BlocProvider.of<ViewEditExpenseBloc>(context).imageDataList.isNotEmpty) ||
            (BlocProvider.of<ViewEditExpenseBloc>(context).newImages.isNotEmpty && BlocProvider.of<ViewEditExpenseBloc>(context).newImages != null)
        ? SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                BlocProvider.of<ViewEditExpenseBloc>(context).imageDataList != null &&
                        BlocProvider.of<ViewEditExpenseBloc>(context).imageDataList.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: BlocProvider.of<ViewEditExpenseBloc>(context).imageDataList.length,
                        padding: const EdgeInsets.only(top: 0),
                        itemBuilder: (BuildContext context, int index) {
                          return listItem(BlocProvider.of<ViewEditExpenseBloc>(context).imageDataList[index], false, index, context);
                        })
                    : Container(),
                BlocProvider.of<ViewEditExpenseBloc>(context).newImages.isNotEmpty && BlocProvider.of<ViewEditExpenseBloc>(context).newImages != null
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: BlocProvider.of<ViewEditExpenseBloc>(context).newImages.length,
                        padding: const EdgeInsets.only(top: 0),
                        itemBuilder: (BuildContext context, int index) {
                          return listItem(BlocProvider.of<ViewEditExpenseBloc>(context).newImages[index], true, index, context);
                        })
                    : Container(),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  ImageConstant.noPhoto,
                  addRepaintBoundary: false,
                  animate: true,
                  fit: BoxFit.cover,
                  height: 150,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "No Photos Available\nTap the Add Button Below to add photo",
                  style: TextStyleConstant.blackRegular16.copyWith(color: Colors.black26),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
  }

  listItem(var item, bool isLocal, int index, BuildContext context) {
    var dt = DateTime.fromMillisecondsSinceEpoch(item[DatabaseHelper.colDateCreated]);
    var date = DateFormat('dd MMM,yyyy hh:mm a').format(dt);
    return BlocBuilder<ViewEditExpenseBloc, ViewEditExpenseState>(
      builder: (context, state) {
        if (state is ViewEditExpenseLoaded) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              height: 200,
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    child: item[DatabaseHelper.colImageData] == null
                        ? const Icon(
                            Icons.camera_alt_outlined,
                            size: 100,
                            color: Colors.white,
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                            ),
                            child: Image.memory(
                              base64Decode(item[DatabaseHelper.colImageData]),
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: TextStyleConstant.lightBlackRegular16.copyWith(fontSize: 14),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                item[DatabaseHelper.colImageDesc] ?? "",
                                style: TextStyleConstant.blackRegular14,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            confirmDialog(
                              onConfirm: () {
                                if (isLocal) {
                                  BlocProvider.of<ViewEditExpenseBloc>(context).newImages.removeAt(index);
                                } else {
                                  BlocProvider.of<ViewEditExpenseBloc>(context).imageDataList.removeAt(index);
                                  BlocProvider.of<ViewEditExpenseBloc>(context).deleteID.add(item[DatabaseHelper.colId]);
                                }
                                BlocProvider.of<ViewEditExpenseBloc>(context).add(ChangeTabEvent(context));
                                Navigator.pop(context);
                              },
                              context: context,
                              content: "Do you really want to delete this image?",
                              title: "Delete Changes",
                            );
                          },
                          child: const Icon(Icons.delete_forever_rounded),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  showImageDialog(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context2, setState) {
            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: ListView(
                // mainAxisSize: MainAxisSize.min,
                shrinkWrap: true,
                children: [
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                        color: ColorConstant.primaryColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        )),
                    alignment: Alignment.center,
                    child: Text(
                      "Add new Photos",
                      style: TextStyleConstant.whiteRegular16,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xffe8e3e3), borderRadius: BorderRadius.circular(15)),
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          child: context.read<ViewEditExpenseBloc>().imageByte == ""
                              ? const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 100,
                                  color: Colors.white,
                                )
                              : ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                  ),
                                  child: Image.memory(
                                    base64Decode(context.read<ViewEditExpenseBloc>().imageByte),
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        CommonTextfield(
                          controller: context.read<ViewEditExpenseBloc>().imageDescController,
                          hintText: "Description or Remarks",
                        ),
                      ],
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 0,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              getImage("2").then((value) {
                                if (value != null) {
                                  context.read<ViewEditExpenseBloc>().imageByte = value;
                                  setState(() {});
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Click Picture",
                                    style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              getImage("1").then((value) {
                                if (value != null) {
                                  context.read<ViewEditExpenseBloc>().imageByte = value;
                                  setState(() {});
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Gallery",
                                    style: TextStyleConstant.blackRegular14.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
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
                            onTap: () {
                              BlocProvider.of<ViewEditExpenseBloc>(context).add(UpdateCameraDataEvent(
                                context,
                                context.read<ViewEditExpenseBloc>().imageByte,
                                context.read<ViewEditExpenseBloc>().imageDescController.text,
                              ));
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
                                  borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              child: Text(
                                "Save Photo",
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
            );
          },
        ));
  }
}
