import 'package:expense_manager/Bloc/Bloc/add_trip_expense_bloc.dart';
import 'package:expense_manager/Bloc/Event/add_trip_expense_event.dart';
import 'package:expense_manager/Bloc/State/add_trip_expense_state.dart';
import 'package:expense_manager/utils/center_button.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/common_textfield.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class AddTripExpenseView extends StatelessWidget {
  const AddTripExpenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddTripExpenseBloc, AddTripExpenseState>(
      builder: (context, state) {
        if (state is AddTripExpenseEmptyState) {
          BlocProvider.of<AddTripExpenseBloc>(context).add(AddTripExpenseLoadEvent(context));
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
        if (state is AddTripExpenseDataLoaded) {
          return Scaffold(
            appBar: appBar(context),
            body: bodyView(context),
          );
        }
        return Scaffold(
          body: Container(),
        );
      },
    );
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
          )),
      title: Text(
        "Add Expense",
        style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
      ),
    );
  }

  Widget bodyView(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: ListView(
        children: [
          SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context2) {
                  return categoryDialog(context);
                },
              ).then((value) {
                BlocProvider.of<AddTripExpenseBloc>(context).add(DataReload(context));
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(ImageConstant.tripCatIcon),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        context.read<AddTripExpenseBloc>().selectedCate,
                        style: TextStyleConstant.blackRegular14.copyWith(color: Colors.black),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context2) {
                            return addCategoryDialog(context);
                          },
                        ).then((value) {
                          BlocProvider.of<AddTripExpenseBloc>(context).add(DataReload(context));
                        });
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
                      "Tap here to select category",
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
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                color: ColorConstant.primaryColor,
              ),
              // SizedBox(width: 10.w,),
              Expanded(child: CommonTextfield(controller: context.read<AddTripExpenseBloc>().descriptionController, hintText: "Description"))
            ],
          ),
          Divider(
            height: 1,
          ),
          SizedBox(
            height: 25,
          ),
          StatefulBuilder(
            builder: (context2, setState) {
              return InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: BlocProvider.of<AddTripExpenseBloc>(context).selectedDate,
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
                      BlocProvider.of<AddTripExpenseBloc>(context).selectedDate = value;
                      setState(() {});
                    }
                  });
                },
                child: Row(
                  children: [
                    SvgPicture.asset(ImageConstant.calendarIcon),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        DateFormat("dd, MMM yyyy").format(context.read<AddTripExpenseBloc>().selectedDate),
                        style: TextStyleConstant.blackRegular14.copyWith(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            },
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
            onTap: () async {
              await showTimePicker(
                context: context,
                initialTime: BlocProvider.of<AddTripExpenseBloc>(context).time,
              ).then((value) {
                BlocProvider.of<AddTripExpenseBloc>(context).time = value!;
                BlocProvider.of<AddTripExpenseBloc>(context).add(DataReload(context));
                return null;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: ColorConstant.primaryColor,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    context.read<AddTripExpenseBloc>().time.format(context),
                    style: TextStyleConstant.blackRegular14.copyWith(color: Colors.black, letterSpacing: 2),
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
            height: 15,
          ),
          Row(
            children: [
              SizedBox(
                width: 8,
              ),
              Text(
                "${PreferenceUtils.getString(key: selectedCurrency)}",
                style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor, fontSize: 16),
              ),
              // SvgPicture.asset(coinIcon),
              // SizedBox(width: 10.w,),
              Expanded(
                child: CommonTextfield(
                    controller: context.read<AddTripExpenseBloc>().amountController,
                    // suffixWidget: Text(
                    //   "${PreferenceUtils.getString(key: selectedCurrency)}",
                    //   style: TextStyleConstant.blackRegular14.copyWith(color: primaryColor),
                    // ),
                    textInput: TextInputType.number,
                    hintText: "Expense Amount"),
              )
            ],
          ),
          Divider(
            height: 1,
          ),
          SizedBox(
            height: 25,
          ),
          GestureDetector(
            onTap: () async {
              if (context.read<AddTripExpenseBloc>().descriptionController.text == "") {
                showToast("Enter description");
              } else if (context.read<AddTripExpenseBloc>().amountController.text == "") {
                showToast("Enter amount");
              } else {
                BlocProvider.of<AddTripExpenseBloc>(context).add(SaveTripExpanseEvent(context));
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
                  "Save Expense",
                  style: TextStyleConstant.whiteBold16.copyWith(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  categoryDialog(BuildContext context) {
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
                  height: 45,
                  decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      )),
                  alignment: Alignment.center,
                  child: Text(
                    "Category List",
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                ...List.generate(
                  context.read<AddTripExpenseBloc>().categories.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        context.read<AddTripExpenseBloc>().selectedCate = context.read<AddTripExpenseBloc>().categories[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.read<AddTripExpenseBloc>().selectedCate == context.read<AddTripExpenseBloc>().categories[index]
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
                        context.read<AddTripExpenseBloc>().categories[index],
                        style: TextStyleConstant.blackRegular14.copyWith(
                          color: context.read<AddTripExpenseBloc>().selectedCate == context.read<AddTripExpenseBloc>().categories[index]
                              ? Colors.white
                              : ColorConstant.primaryColor,
                        ),
                      ),
                    ),
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

  addCategoryDialog(BuildContext context) {
    TextEditingController catNameController = TextEditingController();
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
                    "Add new Category",
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
                          controller: catNameController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                            hintText: "Enter category",
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
                                  if (catNameController.text == "") {
                                    showToast("First enter cat name");
                                  } else {
                                    context.read<AddTripExpenseBloc>().selectedCate = catNameController.text;
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

  showDialogPicker(BuildContext context) {}
}
