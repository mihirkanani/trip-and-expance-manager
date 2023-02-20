import 'package:expense_manager/Bloc/Bloc/add_expenses_with_home_bloc.dart';
import 'package:expense_manager/Bloc/Event/add_expenses_with_home_event.dart';
import 'package:expense_manager/Bloc/State/add_expenses_with_home_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class AddExpenseWithHomeView extends StatelessWidget {
  const AddExpenseWithHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddExpensesWithHomeBloc, AddExpensesWithHomeState>(
      builder: (context, state) {
        if (state is AddExpensesWithHomeInitialState) {
          BlocProvider.of<AddExpensesWithHomeBloc>(context).add(AddExpensesWithHomeInitialEvent(context));
          return Scaffold(
            appBar: appBar(context),
            body: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              lineWidth: 3,
            ),
          );
        }
        if (state is AddExpensesWithHomeDataLoaded) {
          return Scaffold(
            appBar: appBar(context),
            body: bodyView(context),
          );
        }
        return Container();
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
                BlocProvider.of<AddExpensesWithHomeBloc>(context).add(DataReload(context));
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
                        context.read<AddExpensesWithHomeBloc>().selectedCate,
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
                          BlocProvider.of<AddExpensesWithHomeBloc>(context).add(DataReload(context));
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
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context2) {
                  return personDialog(context);
                },
              ).then((value) {
                BlocProvider.of<AddExpensesWithHomeBloc>(context).add(DataReload(context));
              });
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
                        context.read<AddExpensesWithHomeBloc>().selectPerson == null
                            ? "Select Person"
                            : '${context.read<AddExpensesWithHomeBloc>().selectPerson['trip_user_name']}',
                        style: TextStyleConstant.blackRegular14.copyWith(color: Colors.black),
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
                      "Tap here to select person",
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
              Expanded(
                child: CommonTextfield(controller: context.read<AddExpensesWithHomeBloc>().descriptionController, hintText: "Description"),
              )
            ],
          ),
          Divider(
            height: 1,
          ),
          SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: context.read<AddExpensesWithHomeBloc>().selectedDate,
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
                context.read<AddExpensesWithHomeBloc>().selectedDate = value;
                BlocProvider.of<AddExpensesWithHomeBloc>(context).add(DataReload(context));
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
                    DateFormat("dd, MMM yyyy").format(context.read<AddExpensesWithHomeBloc>().selectedDate),
                    style: TextStyleConstant.blackRegular14.copyWith(color: Colors.black),
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
            onTap: () async {
              await showTimePicker(
                context: context,
                initialTime: BlocProvider.of<AddExpensesWithHomeBloc>(context).time,
              ).then((value) {
                BlocProvider.of<AddExpensesWithHomeBloc>(context).time = value!;
                BlocProvider.of<AddExpensesWithHomeBloc>(context).add(DataReload(context));
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
                    context.read<AddExpensesWithHomeBloc>().time.format(context),
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
                  controller: context.read<AddExpensesWithHomeBloc>().amountController,
                  textInput: TextInputType.number,
                  hintText: "Expense Amount",
                ),
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
              if (context.read<AddExpensesWithHomeBloc>().descriptionController.text == "") {
                showToast("Enter description");
              } else if (context.read<AddExpensesWithHomeBloc>().amountController.text == "") {
                showToast("Enter amount");
              } else if (context.read<AddExpensesWithHomeBloc>().selectPerson == "" || context.read<AddExpensesWithHomeBloc>().selectPerson == null) {
                showToast("Please Select Person");
              } else {
                BlocProvider.of<AddExpensesWithHomeBloc>(context).add(InsertExpenseWithHomeEvent(context));
                // await addTripExpense();
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
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
                    "Category List",
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                ...List.generate(
                  context.read<AddExpensesWithHomeBloc>().categories.length,
                  (index) => GestureDetector(
                    onTap: () async {
                      setState(() {
                        context.read<AddExpensesWithHomeBloc>().selectedCate = context.read<AddExpensesWithHomeBloc>().categories[index];
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('category', context.read<AddExpensesWithHomeBloc>().selectedCate);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.read<AddExpensesWithHomeBloc>().selectedCate == context.read<AddExpensesWithHomeBloc>().categories[index]
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
                        context.read<AddExpensesWithHomeBloc>().categories[index],
                        style: TextStyleConstant.blackRegular14.copyWith(
                          color: context.read<AddExpensesWithHomeBloc>().selectedCate == context.read<AddExpensesWithHomeBloc>().categories[index]
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

  personDialog(BuildContext context) {
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
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Person List",
                    style: TextStyleConstant.whiteBold16,
                  ),
                ),
                ...List.generate(
                  context.read<AddExpensesWithHomeBloc>().userList.length,
                  (index) => GestureDetector(
                    onTap: () async {
                      setState(() {
                        context.read<AddExpensesWithHomeBloc>().selectPerson = context.read<AddExpensesWithHomeBloc>().userList[index];
                      });
                      print("Select Person ${context.read<AddExpensesWithHomeBloc>().selectPerson}");
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.read<AddExpensesWithHomeBloc>().selectPerson.toString() == '[]' ||
                                context.read<AddExpensesWithHomeBloc>().selectPerson == null
                            ? Colors.white
                            : context.read<AddExpensesWithHomeBloc>().selectPerson[DatabaseHelper.colUserId] ==
                                    context.read<AddExpensesWithHomeBloc>().userList[index][DatabaseHelper.colUserId]
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
                        context.read<AddExpensesWithHomeBloc>().userList[index]['trip_user_name'],
                        style: TextStyleConstant.blackRegular14.copyWith(
                          color: context.read<AddExpensesWithHomeBloc>().selectPerson.toString() == '[]' ||
                                  context.read<AddExpensesWithHomeBloc>().selectPerson == null
                              ? ColorConstant.primaryColor
                              : context.read<AddExpensesWithHomeBloc>().selectPerson[DatabaseHelper.colUserId] ==
                                      context.read<AddExpensesWithHomeBloc>().userList[index][DatabaseHelper.colUserId]
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
                                    context.read<AddExpensesWithHomeBloc>().selectedCate = catNameController.text;
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
}
