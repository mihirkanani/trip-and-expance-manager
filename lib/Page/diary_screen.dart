import 'package:expense_manager/Bloc/Bloc/add_diary_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/diary_bloc.dart';
import 'package:expense_manager/Bloc/Event/diary_event.dart';
import 'package:expense_manager/Bloc/State/diary_state.dart';
import 'package:expense_manager/Page/add_diary_screen.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class DiaryView extends StatelessWidget {
  const DiaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiaryBloc, DiaryState>(
      builder: (context, state) {
        if (state is DiaryInitialState) {
          BlocProvider.of<DiaryBloc>(context).add(DiaryLoadEvent(context));
          return Scaffold(
            appBar: null,
            bottomNavigationBar: Container(
              height: 86,
              child: addDiaryButton(context),
            ),
            body: Container(
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
                      "Expense Diary",
                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SpinKitDualRing(
                        color: ColorConstant.primaryColor,
                        size: 30,
                        lineWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is DiaryDataLoading) {
          return Scaffold(
            appBar: null,
            bottomNavigationBar: Container(
              height: 86,
              child: addDiaryButton(context),
            ),
            body: Container(
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
                      "Expense Diary",
                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SpinKitDualRing(
                        color: ColorConstant.primaryColor,
                        size: 30,
                        lineWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is DiaryDataLoaded) {
          return Scaffold(
            appBar: null,
            bottomNavigationBar: Container(
              height: 86,
              child: addDiaryButton(context),
            ),
            body: Container(
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
                      "Expense Diary",
                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: context.read<DiaryBloc>().onDiaryList.length > 0
                        ? diaryListData(context)
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  ImageConstant.noDiaryFound,
                                  height: 200,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "No Expense Diary Found!",
                                  style: TextStyleConstant.blackBold14.copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: null,
          bottomNavigationBar: Container(
            height: 86,
            child: addDiaryButton(context),
          ),
          body: Container(
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
                    "Expense Diary",
                    style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SpinKitDualRing(
                      color: ColorConstant.primaryColor,
                      size: 30,
                      lineWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget diaryListData(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 0.0),
      children: [
        ...List.generate(
          context.read<DiaryBloc>().onDiaryList.length,
          (index) {
            return SwipeActionCell(
              key: ValueKey(index),
              fullSwipeFactor: 0.90,
              editModeOffset: 30,
              normalAnimationDuration: 300,
              deleteAnimationDuration: 200,
              trailingActions: [
                SwipeAction(
                  closeOnTap: true,
                  forceAlignmentToBoundary: true,
                  color: Colors.transparent,
                  widthSpace: 60,
                  content: _getIconButton(Colors.red, Icons.delete),
                  onTap: (handler) async {
                    confirmDialog(
                      onConfirm: () async {
                        await dbHelper.deleteItem(
                          id: context.read<DiaryBloc>().onDiaryList[index]["${DatabaseHelper.colDiaryId}"],
                          matchId: DatabaseHelper.colDiaryId,
                          tableName: DatabaseHelper.tblDiary,
                        );
                        Navigator.pop(context);
                        BlocProvider.of<DiaryBloc>(context).add(GetDiaryDataEvent(context));
                      },
                      context: context,
                      content: "Do you really want to delete this diary?",
                      title: "Delete",
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
                        create: (_) => AddDiaryBloc(
                          update: true,
                          diaryList: context.read<DiaryBloc>().onDiaryList[index],
                        ),
                        child: AddDiaryView(),
                      ),
                    ),
                  ).then((value) {
                    BlocProvider.of<DiaryBloc>(context).add(GetDiaryDataEvent(context));
                  });
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  elevation: 5,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        context.read<DiaryBloc>().onDiaryList[index]['${DatabaseHelper.colDiaryTitle}'] == ''
                            ? Container()
                            : Text(
                                "${context.read<DiaryBloc>().onDiaryList[index]['${DatabaseHelper.colDiaryTitle}']}",
                                style: TextStyleConstant.blackBold16.copyWith(fontSize: 14),
                              ),
                        context.read<DiaryBloc>().onDiaryList[index]['${DatabaseHelper.colDiaryContent}'] == ''
                            ? Text(
                                "Tap here to see your diary",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              )
                            : Text(
                                "Tap here to see your diary",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget addDiaryButton(context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context2) => BlocProvider(
              create: (_) => AddDiaryBloc(
                update: false,
                diaryList: null,
              ),
              child: AddDiaryView(),
            ),
          ),
        ).then((value) {
          BlocProvider.of<DiaryBloc>(context).add(GetDiaryDataEvent(context));
        });
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
            )
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "+ Add New Expense Diary",
          style: TextStyleConstant.whiteBold16.copyWith(fontSize: 15),
        ),
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
