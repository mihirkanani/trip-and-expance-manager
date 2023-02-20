import 'package:expense_manager/Bloc/Bloc/add_category_bloc.dart';
import 'package:expense_manager/Bloc/Event/add_category_event.dart';
import 'package:expense_manager/Bloc/State/add_category_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class AddCategoryView extends StatelessWidget {
  const AddCategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCategoryBloc, AddCategoryState>(
      builder: (context, state) {
        if (state is AddCategoryInitialState) {
          context.read<AddCategoryBloc>().add(AddCategoryLoadEvent());
          context.read<AddCategoryBloc>().add(GetCategoriesEvent());
        }
        if (state is AddCategoryLoading) {
          return Scaffold(
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
            floatingActionButton: context.read<AddCategoryBloc>().isExpenses
                ? context.read<AddCategoryBloc>().expenseAmountList.isNotEmpty && context.read<AddCategoryBloc>().selectedCatList.isNotEmpty
                    ? FloatingActionButton(
                        backgroundColor: ColorConstant.primaryColor,
                        onPressed: () {
                          if ((context.read<AddCategoryBloc>().expenseAmountList.isNotEmpty) &&
                              context.read<AddCategoryBloc>().selectedCatList.isNotEmpty) {
                            BlocProvider.of<AddCategoryBloc>(context).add(InsertExpanseEvent(context));
                          } else {}
                        },
                        child: context.read<AddCategoryBloc>().expenseAmountList.length == 1
                            ? const Icon(
                                Icons.done,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.white,
                              ),
                      )
                    : Container()
                : context.read<AddCategoryBloc>().incomeAmountList.isNotEmpty && context.read<AddCategoryBloc>().selectedCatList.isNotEmpty
                    ? FloatingActionButton(
                        backgroundColor: ColorConstant.primaryColor,
                        onPressed: () {
                          if ((context.read<AddCategoryBloc>().incomeAmountList.isNotEmpty) &&
                              context.read<AddCategoryBloc>().selectedCatList.isNotEmpty) {
                            BlocProvider.of<AddCategoryBloc>(context).add(InsertIncomeEvent(context));
                          } else {}
                        },
                        child: context.read<AddCategoryBloc>().incomeAmountList.length == 1
                            ? const Icon(
                                Icons.done,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.white,
                              ),
                      )
                    : Container(),
          );
        }
        if (state is AddCategoryLoaded) {
          return Scaffold(
            floatingActionButton: context.read<AddCategoryBloc>().isExpenses
                ? context.read<AddCategoryBloc>().expenseAmountList.isNotEmpty && context.read<AddCategoryBloc>().selectedCatList.isNotEmpty
                    ? FloatingActionButton(
                        backgroundColor: ColorConstant.primaryColor,
                        onPressed: () {
                          if ((context.read<AddCategoryBloc>().expenseAmountList.isNotEmpty) &&
                              context.read<AddCategoryBloc>().selectedCatList.isNotEmpty) {
                            BlocProvider.of<AddCategoryBloc>(context).add(InsertExpanseEvent(context));
                          } else {}
                        },
                        child: context.read<AddCategoryBloc>().expenseAmountList.length == 1
                            ? const Icon(
                                Icons.done,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.white,
                              ),
                      )
                    : Container()
                : context.read<AddCategoryBloc>().incomeAmountList.isNotEmpty && context.read<AddCategoryBloc>().selectedCatList.isNotEmpty
                    ? FloatingActionButton(
                        backgroundColor: ColorConstant.primaryColor,
                        onPressed: () {
                          if ((context.read<AddCategoryBloc>().incomeAmountList.isNotEmpty) &&
                              context.read<AddCategoryBloc>().selectedCatList.isNotEmpty) {
                            BlocProvider.of<AddCategoryBloc>(context).add(InsertIncomeEvent(context));
                          } else {}
                        },
                        child: context.read<AddCategoryBloc>().incomeAmountList.length == 1
                            ? const Icon(
                                Icons.done,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                color: Colors.white,
                              ),
                      )
                    : Container(),
            body: bodyView(context),
          );
        }
        return Container();
      },
    );
  }

  bodyView(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(15),
          // color: Colors.white,
          child: Text(
            "Add Category",
            style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        toggleCard(context),
        const SizedBox(
          height: 20,
        ),
        context.read<AddCategoryBloc>().isExpenses ? expensesTab(context) : incomeTab(context),
        context.read<AddCategoryBloc>().isExpenses
            ? context.read<AddCategoryBloc>().expenseAmountList.isNotEmpty
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: context.read<AddCategoryBloc>().expenseAmountList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
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
                                context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colId] > 9 &&
                                        context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colId] < 99
                                    ? Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: HexColor(context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateColor]),
                                          borderRadius: BorderRadius.circular(500),
                                        ),
                                        child: showCategoryIcon(
                                            int.parse(context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateIcon])))
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: HexColor(context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateColor]),
                                          borderRadius: BorderRadius.circular(500),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/icons/category/${context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateIcon]}.svg",
                                          color: Colors.white,
                                        ),
                                      ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colName]}",
                                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<AddCategoryBloc>().expenseAmountList[index]}",
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
                : Container()
            : context.read<AddCategoryBloc>().incomeAmountList.isNotEmpty
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: context.read<AddCategoryBloc>().selectedCatList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
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
                                context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colId] >= 10 &&
                                            context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colId] < 14 ||
                                        context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colId] == 100
                                    ? Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: HexColor(context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateColor]),
                                            borderRadius: BorderRadius.circular(500)),
                                        child: SvgPicture.asset(
                                          "assets/icons/category/${context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateIcon]}.svg",
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: HexColor(context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateColor]),
                                            borderRadius: BorderRadius.circular(500)),
                                        child: showCategoryIcon(
                                          int.parse(
                                            context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colCateIcon],
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
                                      "${context.read<AddCategoryBloc>().selectedCatList[index][DatabaseHelper.colName]}",
                                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      "${PreferenceUtils.getString(key: selectedCurrency)} ${context.read<AddCategoryBloc>().incomeAmountList[index]}",
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
          height: 20,
        ),
      ],
    );
  }

  Widget toggleCard(BuildContext context) {
    return BlocBuilder<AddCategoryBloc, AddCategoryState>(builder: (context, state) {
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
                    context.read<AddCategoryBloc>().isExpenses = true;
                    context.read<AddCategoryBloc>().selectedCatList.clear();
                    context.read<AddCategoryBloc>().remarkList.clear();
                    context.read<AddCategoryBloc>().incomeAmountList.clear();
                    context.read<AddCategoryBloc>().selectedTimeList.clear();
                    context.read<AddCategoryBloc>().selectedDateList.clear();
                    context.read<AddCategoryBloc>().expenseAmountList.clear();
                    BlocProvider.of<AddCategoryBloc>(context).add(ChangeTabEvent(context));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.read<AddCategoryBloc>().isExpenses ? ColorConstant.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Expenses",
                          style: context.read<AddCategoryBloc>().isExpenses ? TextStyleConstant.whiteRegular16 : TextStyleConstant.blackRegular16,
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
                    context.read<AddCategoryBloc>().isExpenses = false;
                    context.read<AddCategoryBloc>().selectedCatList.clear();
                    context.read<AddCategoryBloc>().remarkList.clear();
                    context.read<AddCategoryBloc>().incomeAmountList.clear();
                    context.read<AddCategoryBloc>().selectedTimeList.clear();
                    context.read<AddCategoryBloc>().selectedDateList.clear();
                    context.read<AddCategoryBloc>().expenseAmountList.clear();
                    BlocProvider.of<AddCategoryBloc>(context).add(ChangeTabEvent(context));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: !context.read<AddCategoryBloc>().isExpenses ? ColorConstant.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Income",
                          style: !context.read<AddCategoryBloc>().isExpenses ? TextStyleConstant.whiteRegular16 : TextStyleConstant.blackRegular16,
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

  Widget expensesTab(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1.2, mainAxisSpacing: 3, crossAxisCount: 3),
      itemBuilder: (BuildContext contexts, int index) {
        return InkWell(
          onTap: () async {
            if (context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colCateIcon] == "Add Category") {
              context.read<AddCategoryBloc>().name.clear();
              for (int i = 0; i < context.read<AddCategoryBloc>().expensesCategoryList.length; i++) {
                context.read<AddCategoryBloc>().name.add(context.read<AddCategoryBloc>().expensesCategoryList[i]["name"]);
              }
              showDialog(
                context: context,
                builder: (BuildContext context2) {
                  return showAddCategoryDialog(context);
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context2) {
                  return addExpensesDialog(index, context);
                },
              );
            }
          },
          child: Column(
            children: [
              context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colId] > 9 &&
                      context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colId] < 99
                  ? Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: HexColor(context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colCateColor]),
                          borderRadius: BorderRadius.circular(500)),
                      child: showCategoryIcon(
                        int.parse(context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colCateIcon]),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: HexColor(context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colCateColor]),
                          borderRadius: BorderRadius.circular(500)),
                      child: SvgPicture.asset(
                        "assets/icons/category/${context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colCateIcon]}.svg",
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(
                height: 5,
              ),
              Text(
                context.read<AddCategoryBloc>().expensesCategoryList[index][DatabaseHelper.colName],
                style: TextStyleConstant.blackRegular14.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      },
      itemCount: context.read<AddCategoryBloc>().expensesCategoryList.length,
    );
  }

  Widget incomeTab(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 1.2, mainAxisSpacing: 3, crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () async {
            if (context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colCateIcon] == "Add Category") {
              context.read<AddCategoryBloc>().name.clear();
              for (int i = 0; i < context.read<AddCategoryBloc>().incomeCategoryList.length; i++) {
                context.read<AddCategoryBloc>().name.add(context.read<AddCategoryBloc>().incomeCategoryList[i]["name"]);
              }
              showDialog(
                context: context,
                builder: (BuildContext context2) {
                  return showAddCategoryDialog(context);
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context2) {
                  return addIncomeDialog(index, context);
                },
              );
            }
          },
          child: Column(
            children: [
              context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colId] >= 10 &&
                          context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colId] < 14 ||
                      context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colId] == 100
                  ? Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: HexColor(context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colCateColor]),
                        borderRadius: BorderRadius.circular(500),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/category/${context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colCateIcon]}.svg",
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: HexColor(context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colCateColor]),
                        borderRadius: BorderRadius.circular(500),
                      ),
                      child: showCategoryIcon(
                        int.parse(context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colCateIcon]),
                      ),
                    ),
              const SizedBox(
                height: 5,
              ),
              Text(
                context.read<AddCategoryBloc>().incomeCategoryList[index][DatabaseHelper.colName],
                style: TextStyleConstant.blackRegular14.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      },
      itemCount: context.read<AddCategoryBloc>().incomeCategoryList.length,
    );
  }

  showAddCategoryDialog(BuildContext context) {
    var selectedIcon;
    TextEditingController catNameController = TextEditingController();
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
                              "Add New Category",
                              style: TextStyleConstant.blackBold16.copyWith(letterSpacing: 0.5, fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
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
                              controller: catNameController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                hintText: "Enter category name",
                                isDense: true,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              // dialogBox(setDialogState,selectedIcon);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context2) {
                                  return AlertDialog(
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                    contentPadding: EdgeInsets.zero,
                                    content: SizedBox(
                                      width: MediaQuery.of(context).size.width * .7,
                                      child: SingleChildScrollView(
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
                                                    topRight: Radius.circular(18),
                                                    topLeft: Radius.circular(18),
                                                  )),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Select Category Image",
                                                style: TextStyleConstant.whiteBold16,
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * .7,
                                              child: GridView.builder(
                                                scrollDirection: Axis.vertical,
                                                padding: const EdgeInsets.all(8.0),
                                                shrinkWrap: true,
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                                itemCount: context.read<AddCategoryBloc>().categoryIcons.length,
                                                itemBuilder: (BuildContext context2, int index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedIcon = context.read<AddCategoryBloc>().categoryIcons[index];
                                                      });
                                                      print(" Selected Category $selectedIcon");
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Card(
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Icon(
                                                          context.read<AddCategoryBloc>().categoryIcons[index]['icon'],
                                                          color: ColorConstant.primaryColor,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 40,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                              child: Center(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedIcon != null ? "Selected Image" : "Select Category Image",
                                          style: TextStyle(color: selectedIcon != null ? Colors.black : Colors.grey),
                                        ),
                                        Icon(
                                          selectedIcon == null ? Icons.add : selectedIcon['icon'],
                                          color: ColorConstant.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(vertical: 5),
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
                                      child: Center(
                                        child: Text(
                                          "Cancel",
                                          style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                                        ),
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
                                      BlocProvider.of<AddCategoryBloc>(context).add(
                                        InsertCategoriesEvent(context, catNameController.text, selectedIcon),
                                      );
                                      BlocProvider.of<AddCategoryBloc>(context).add(
                                        GetCategoriesEvent(),
                                      );
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
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                contentPadding: EdgeInsets.zero,
                                content: SizedBox(
                                  width: MediaQuery.of(context).size.width * .7,
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
                                              topRight: Radius.circular(18),
                                              topLeft: Radius.circular(18),
                                            )),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Select Category Image",
                                          style: TextStyleConstant.whiteBold16,
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * .7,
                                        child: GridView.builder(
                                          scrollDirection: Axis.vertical,
                                          padding: const EdgeInsets.all(8.0),
                                          shrinkWrap: true,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                          itemCount: context.read<AddCategoryBloc>().categoryIcons.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedIcon = context.read<AddCategoryBloc>().categoryIcons[index];
                                                });
                                                print(" Selected Category $selectedIcon");
                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Card(
                                                color: Colors.white,
                                                child: Center(
                                                  child: Icon(
                                                    context.read<AddCategoryBloc>().categoryIcons[index]['icon'],
                                                    color: ColorConstant.primaryColor,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: ColorConstant.primaryColor,
                          child: Icon(
                            selectedIcon == null ? Icons.add : selectedIcon['icon'],
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          },
        ));
  }

  addExpensesDialog(index, BuildContext context) {
    TextEditingController amountController = TextEditingController();
    TextEditingController remarkController = TextEditingController();
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
                    "Add Expense",
                    style: TextStyleConstant.whiteRegular16,
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
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
                          borderRadius: BorderRadius.circular(10)),
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
                          initialDate: context.read<AddCategoryBloc>().selectedDate!,
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
                          context.read<AddCategoryBloc>().selectedDate = value;
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
                          DateFormat("dd, MMM yyyy").format(context.read<AddCategoryBloc>().selectedDate!),
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
                          initialTime: BlocProvider.of<AddCategoryBloc>(context).time,
                        ).then((value) {
                          BlocProvider.of<AddCategoryBloc>(context).time = value!;
                          BlocProvider.of<AddCategoryBloc>(context).add(ChangeDateAndTimeEvent(context));
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
                          context.read<AddCategoryBloc>().time.format(context),
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
                              if (amountController.text == "") {
                                showToast("Enter amount");
                              } else {
                                context.read<AddCategoryBloc>().selectedCatList.add(context.read<AddCategoryBloc>().expensesCategoryList[index]);
                                context.read<AddCategoryBloc>().expenseAmountList.add(int.parse(amountController.text));
                                context.read<AddCategoryBloc>().remarkList.add(remarkController.text);
                                context
                                    .read<AddCategoryBloc>()
                                    .selectedDateList
                                    .add(context.read<AddCategoryBloc>().selectedDate!.millisecondsSinceEpoch);
                                context.read<AddCategoryBloc>().selectedTimeList.add(context.read<AddCategoryBloc>().time.format(context));
                                setState(() {});
                                Navigator.pop(context);
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
                )
              ],
            ),
          );
        },
      ),
    );
  }

  addIncomeDialog(index, BuildContext context) {
    TextEditingController amountController = TextEditingController();
    TextEditingController remarkController = TextEditingController();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context2, setState) {
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
                          initialDate: context.read<AddCategoryBloc>().selectedDate!,
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
                          context.read<AddCategoryBloc>().selectedDate = value;
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
                          DateFormat("dd, MMM yyyy").format(context.read<AddCategoryBloc>().selectedDate!),
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
                          initialTime: BlocProvider.of<AddCategoryBloc>(context).time,
                        ).then((value) {
                          BlocProvider.of<AddCategoryBloc>(context).time = value!;
                          BlocProvider.of<AddCategoryBloc>(context).add(ChangeDateAndTimeEvent(context));
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
                          context.read<AddCategoryBloc>().time.format(context),
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
                              if (amountController.text == "") {
                                showToast("Enter amount");
                              } else {
                                context.read<AddCategoryBloc>().selectedCatList.add(context.read<AddCategoryBloc>().incomeCategoryList[index]);
                                context.read<AddCategoryBloc>().incomeAmountList.add(int.parse(amountController.text));
                                context.read<AddCategoryBloc>().remarkList.add(remarkController.text);
                                context
                                    .read<AddCategoryBloc>()
                                    .selectedDateList
                                    .add(context.read<AddCategoryBloc>().selectedDate!.millisecondsSinceEpoch);
                                context.read<AddCategoryBloc>().selectedTimeList.add(context.read<AddCategoryBloc>().time.format(context));
                                setState(() {});
                                BlocProvider.of<AddCategoryBloc>(context).add(ChangeTabEvent(context));
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ColorConstant.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
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
        },
      ),
    );
  }
}
