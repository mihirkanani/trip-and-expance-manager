import 'dart:convert';
import 'package:expense_manager/Bloc/Bloc/add_income_bloc.dart';
import 'package:expense_manager/Bloc/State/add_income_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/common_textfield.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../Bloc/Event/add_income_event.dart';
import '../utils/image_utils.dart';

class AddIncomeView extends StatelessWidget {
  const AddIncomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddIncomeBloc, AddIncomeState>(
      builder: (context, state) {
        if (state is AddIncomeInitialState) {
          BlocProvider.of<AddIncomeBloc>(context).add(AddIncomeInitialEvent(context));
          return Scaffold(
            body: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              lineWidth: 3,
            ),
            floatingActionButton: !BlocProvider.of<AddIncomeBloc>(context).isCategory
                ? FloatingActionButton(
                    backgroundColor: ColorConstant.primaryColor,
                    onPressed: () {
                      // showImageDialog();
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : Container(),
          );
        }
        if (state is AddIncomeDataLoaded) {
          return Scaffold(
            appBar: appBar(context),
            body: bodyView(),
            floatingActionButton: !BlocProvider.of<AddIncomeBloc>(context).isCategory
                ? FloatingActionButton(
                    backgroundColor: ColorConstant.primaryColor,
                    onPressed: () {
                      showDialog(
                        context: context,
                        // barrierDismissible: false,
                        builder: (BuildContext context2) {
                          return showImageDialog(context);
                        },
                      ).then((value) {
                        BlocProvider.of<AddIncomeBloc>(context).add(ChangeTabEvent(context));
                      });
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : Container(),
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
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          )),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Income",
            style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
          ),
          Text(
            "Add category and photos",
            style: TextStyleConstant.blackRegular16.copyWith(fontSize: 12),
          ),
        ],
      ),
      actions: [
        BlocProvider.of<AddIncomeBloc>(context).incomeAmountList.isNotEmpty && BlocProvider.of<AddIncomeBloc>(context).selectedCatList.isNotEmpty
            ? InkWell(
                onTap: () {
                  if ((BlocProvider.of<AddIncomeBloc>(context).incomeAmountList.isNotEmpty) &&
                      BlocProvider.of<AddIncomeBloc>(context).selectedCatList.isNotEmpty) {
                    BlocProvider.of<AddIncomeBloc>(context).add(InsertExpenseEvent(context));
                    // insertExpense(context);
                  } else {
                    // final snackBar = SnackBar(content: Text('Oops! Add data first'));
                    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
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
                      BlocProvider.of<AddIncomeBloc>(context).incomeAmountList.isNotEmpty &&
                              BlocProvider.of<AddIncomeBloc>(context).selectedCatList.isNotEmpty
                          ? BlocProvider.of<AddIncomeBloc>(context).incomeAmountList.length == 1
                              ? Text(
                                  "Save",
                                  style: TextStyle(
                                    color: ColorConstant.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  "Save All",
                                  style: TextStyle(
                                    color: ColorConstant.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                          : Container(),
                      const SizedBox(
                        width: 5,
                      ),
                      BlocProvider.of<AddIncomeBloc>(context).incomeAmountList.isNotEmpty &&
                              BlocProvider.of<AddIncomeBloc>(context).selectedCatList.isNotEmpty
                          ? BlocProvider.of<AddIncomeBloc>(context).incomeAmountList.length == 1
                              ? Icon(
                                  Icons.done,
                                  color: ColorConstant.primaryColor,
                                )
                              : Icon(Icons.done_all_rounded, color: ColorConstant.primaryColor)
                          : Container(),
                    ],
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  Widget bodyView() {
    return BlocBuilder<AddIncomeBloc, AddIncomeState>(builder: (context, state) {
      return ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 10,
          ),
          toggleCard(),
          const SizedBox(
            height: 20,
          ),
          BlocProvider.of<AddIncomeBloc>(context).isCategory ? categoryTab() : cameraTab(context),
          BlocProvider.of<AddIncomeBloc>(context).incomeAmountList.isNotEmpty
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: BlocProvider.of<AddIncomeBloc>(context).selectedCatList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 5,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colId] >= 10 &&
                                          BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colId] < 14 ||
                                      BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colId] == 100
                                  ? Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color:
                                              HexColor(BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colCateColor]),
                                          borderRadius: BorderRadius.circular(500)),
                                      child: SvgPicture.asset(
                                        "assets/icons/category/${BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colCateIcon]}.svg",
                                        color: Colors.white,
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: HexColor(BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colCateColor]),
                                        borderRadius: BorderRadius.circular(500),
                                      ),
                                      child: showCategoryIcon(
                                        int.parse(
                                          BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colCateIcon],
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${BlocProvider.of<AddIncomeBloc>(context).selectedCatList[index][DatabaseHelper.colName]}",
                                    style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                                  ),
                                  Text(
                                    "${PreferenceUtils.getString(key: selectedCurrency)} ${BlocProvider.of<AddIncomeBloc>(context).incomeAmountList[index]}",
                                    style: TextStyleConstant.blackRegular16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : Container(),
          const SizedBox(
            height: 10,
          ),
        ],
      );
    });
  }

  Widget toggleCard() {
    return BlocBuilder<AddIncomeBloc, AddIncomeState>(builder: (context, state) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    BlocProvider.of<AddIncomeBloc>(context).isCategory = true;
                    BlocProvider.of<AddIncomeBloc>(context).add(ChangeTabEvent(context));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: BlocProvider.of<AddIncomeBloc>(context).isCategory ? ColorConstant.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Category",
                          style: BlocProvider.of<AddIncomeBloc>(context).isCategory
                              ? TextStyleConstant.whiteRegular16
                              : TextStyleConstant.blackRegular16,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset(
                          ImageConstant.catIcon,
                          color: BlocProvider.of<AddIncomeBloc>(context).isCategory ? Colors.white : Colors.black,
                        ),
                      ],
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
                    BlocProvider.of<AddIncomeBloc>(context).isCategory = false;
                    BlocProvider.of<AddIncomeBloc>(context).add(ChangeTabEvent(context));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: !BlocProvider.of<AddIncomeBloc>(context).isCategory ? ColorConstant.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Camera",
                          style: !BlocProvider.of<AddIncomeBloc>(context).isCategory
                              ? TextStyleConstant.whiteRegular16
                              : TextStyleConstant.blackRegular16,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset(
                          ImageConstant.cameraIcon,
                          color: BlocProvider.of<AddIncomeBloc>(context).isCategory ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget categoryTab() {
    return BlocBuilder<AddIncomeBloc, AddIncomeState>(
      builder: (context, state) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.9, mainAxisSpacing: 10, crossAxisCount: 4),
          itemBuilder: (BuildContext contexts, int index) {
            return InkWell(
              onTap: () {
                if (BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colCateIcon] == "Add Category") {
                  // pushNamed(
                  //     route: rtAddCategoryScreen,
                  //     thenFunc: (value) {
                  //       getCategories();
                  //       setState(() {});
                  //     });
                } else {
                  showDialog(
                    context: context,
                    // barrierDismissible: false,
                    builder: (BuildContext contexts) => addIncomeDialog(index, context),
                  );
                }
              },
              child: Column(
                children: [
                  BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colId] >= 10 &&
                              BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colId] < 14 ||
                          BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colId] == 100
                      ? Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: HexColor(BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colCateColor]),
                              borderRadius: BorderRadius.circular(500)),
                          child: SvgPicture.asset(
                            "assets/icons/category/${BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colCateIcon]}.svg",
                            color: Colors.white,
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: HexColor(BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colCateColor]),
                              borderRadius: BorderRadius.circular(500)),
                          child: showCategoryIcon(
                            int.parse(
                              BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colCateIcon],
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    BlocProvider.of<AddIncomeBloc>(context).categoryList[index][DatabaseHelper.colName],
                    style: TextStyleConstant.blackRegular14.copyWith(fontSize: 10),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            );
          },
          itemCount: BlocProvider.of<AddIncomeBloc>(context).categoryList.length,
        );
      },
    );
  }

  Widget cameraTab(BuildContext context) {
    return BlocProvider.of<AddIncomeBloc>(context).imageDataList.isNotEmpty
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: BlocProvider.of<AddIncomeBloc>(context).imageDataList.length,
            padding: const EdgeInsets.only(top: 0),
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  height: 200,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: BlocProvider.of<AddIncomeBloc>(context).imageDataList[index]["image"] == null
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
                                  base64Decode(BlocProvider.of<AddIncomeBloc>(context).imageDataList[index]["image"]),
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          BlocProvider.of<AddIncomeBloc>(context).imageDataList[index]["description"],
                          style: TextStyleConstant.blackRegular14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  ImageConstant.cameraIcon,
                  color: Colors.black45,
                  height: 100,
                  width: 100,
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
                          child: context.read<AddIncomeBloc>().imageByte == ""
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
                                    base64Decode(context.read<AddIncomeBloc>().imageByte),
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        CommonTextfield(
                          controller: context.read<AddIncomeBloc>().imageDescController,
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
                                  context.read<AddIncomeBloc>().imageByte = value;
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
                                  context.read<AddIncomeBloc>().imageByte = value;
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
                              BlocProvider.of<AddIncomeBloc>(context).add(UpdateCameraDataEvent(
                                context,
                                context.read<AddIncomeBloc>().imageByte,
                                context.read<AddIncomeBloc>().imageDescController.text,
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

  addIncomeDialog(index, BuildContext context) {
    TextEditingController amountController = TextEditingController();
    TextEditingController remarkController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(builder: (context2, setState) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Add Income",
                  style: TextStyleConstant.whiteRegular16,
                ),
              ),
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
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
                      controller: amountController,
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
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: BlocProvider.of<AddIncomeBloc>(context).selectedDate,
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
                        if (value != null) {
                          BlocProvider.of<AddIncomeBloc>(context).selectedDate = value;
                        }
                        BlocProvider.of<AddIncomeBloc>(context).add(ChangeDateAndTimeEvent(context));
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
                        DateFormat("dd, MMM yyyy").format(BlocProvider.of<AddIncomeBloc>(context).selectedDate),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () async {
                      await showTimePicker(
                        context: context,
                        initialTime: BlocProvider.of<AddIncomeBloc>(context).time,
                      ).then((value) {
                        BlocProvider.of<AddIncomeBloc>(context).time = value!;
                        BlocProvider.of<AddIncomeBloc>(context).add(ChangeDateAndTimeEvent(context));
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
                        BlocProvider.of<AddIncomeBloc>(context).time.format(context),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
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
                      controller: remarkController,
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
                    height: 15,
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
                            decoration: BoxDecoration(
                              color: const Color(0xFF999999),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
                            if (amountController.text == "") {
                              showToast("Enter amount");
                            } else {
                              BlocProvider.of<AddIncomeBloc>(context).add(
                                AddIncomeForStoreEvent(context, index, amountController.text, remarkController.text),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: ColorConstant.primaryColor, borderRadius: BorderRadius.circular(10)),
                            child: const Text(
                              "Add",
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
              Container(),
            ],
          ),
        );
      }),
    );
  }
}
