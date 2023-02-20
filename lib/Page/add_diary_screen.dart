import 'package:expense_manager/Bloc/Bloc/add_diary_bloc.dart';
import 'package:expense_manager/Bloc/Event/add_diary_event.dart';
import 'package:expense_manager/Bloc/State/add_diary_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import '../utils/text_style_constant.dart';

class AddDiaryView extends StatelessWidget {
  const AddDiaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddDiaryBloc, AddDiaryState>(
      builder: (context, state) {
        if (state is AddDiaryInitialState) {
          BlocProvider.of<AddDiaryBloc>(context).add(AddDiaryLoadEvent(context));
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: ColorConstant.primaryColor,
              title: Text(
                context.read<AddDiaryBloc>().update ? "Expense Diary" : "Add Expense Diary",
                style: TextStyleConstant.whiteBold16,
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (context.read<AddDiaryBloc>().diaryTitle == null && context.read<AddDiaryBloc>().diaryContent == null) {
                      showToast("Please enter content");
                    } else {
                      showLoader(context);
                      var txt = await context.read<AddDiaryBloc>().controller.getText();
                      if (txt.contains('src=\"data:')) {
                        txt = '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                        showToast("Please Remove Image");
                        Navigator.pop(context);
                      } else {
                        print("TExt is $txt");
                        context.read<AddDiaryBloc>().diaryContent = txt;
                        print("DirtyContent is ${context.read<AddDiaryBloc>().diaryContent}");
                        if (context.read<AddDiaryBloc>().update) {
                          BlocProvider.of<AddDiaryBloc>(context).add(UpdateAddDiaryDataEvent(context));
                        } else {
                          BlocProvider.of<AddDiaryBloc>(context).add(AddDiaryDataEvent(context));
                        }
                      }
                    }
                  },
                  icon: Icon(
                    Icons.save,
                  ),
                ),
                context.read<AddDiaryBloc>().update
                    ? IconButton(
                        onPressed: () async {
                          confirmDialog(
                            onConfirm: () async {
                              await dbHelper.deleteItem(
                                id: context.read<AddDiaryBloc>().diaryList["${DatabaseHelper.colDiaryId}"],
                                matchId: DatabaseHelper.colDiaryId,
                                tableName: DatabaseHelper.tblDiary,
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            context: context,
                            content: "Do you really want to delete this diary?",
                            title: "Delete",
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
          );
        }
        if (state is AddDiaryDataLoading) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorConstant.primaryColor,
              title: Text(
                context.read<AddDiaryBloc>().update ? "Expense Diary" : "Add Expense Diary",
                style: TextStyleConstant.whiteBold16,
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (context.read<AddDiaryBloc>().diaryTitle == null && context.read<AddDiaryBloc>().diaryContent == null) {
                      showToast("Please enter content");
                    } else {
                      showLoader(context);
                      var txt = await context.read<AddDiaryBloc>().controller.getText();
                      if (txt.contains('src=\"data:')) {
                        txt = '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                        showToast("Please Remove Image");
                        Navigator.pop(context);
                      } else {
                        print("TExt is $txt");
                        context.read<AddDiaryBloc>().diaryContent = txt;
                        print("DirtyContent is ${context.read<AddDiaryBloc>().diaryContent}");
                        if (context.read<AddDiaryBloc>().update) {
                          BlocProvider.of<AddDiaryBloc>(context).add(UpdateAddDiaryDataEvent(context));
                        } else {
                          BlocProvider.of<AddDiaryBloc>(context).add(AddDiaryDataEvent(context));
                        }
                      }
                    }
                  },
                  icon: Icon(
                    Icons.save,
                  ),
                ),
                context.read<AddDiaryBloc>().update
                    ? IconButton(
                        onPressed: () async {
                          confirmDialog(
                            onConfirm: () async {
                              await dbHelper.deleteItem(
                                id: context.read<AddDiaryBloc>().diaryList["${DatabaseHelper.colDiaryId}"],
                                matchId: DatabaseHelper.colDiaryId,
                                tableName: DatabaseHelper.tblDiary,
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            context: context,
                            content: "Do you really want to delete this diary?",
                            title: "Delete",
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
          );
        }
        if (state is AddDiaryDataLoaded) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: ColorConstant.primaryColor,
              title: Text(
                context.read<AddDiaryBloc>().update ? "Expense Diary" : "Add Expense Diary",
                style: TextStyleConstant.whiteBold16,
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (context.read<AddDiaryBloc>().diaryTitle == null && context.read<AddDiaryBloc>().diaryContent == null) {
                      showToast("Please enter content");
                    } else {
                      showLoader(context);
                      var txt = await context.read<AddDiaryBloc>().controller.getText();
                      if (txt.contains('src=\"data:')) {
                        txt = '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                        showToast("Please Remove Image");
                        Navigator.pop(context);
                      } else {
                        print("TExt is $txt");
                        context.read<AddDiaryBloc>().diaryContent = txt;
                        print("DirtyContent is ${context.read<AddDiaryBloc>().diaryContent}");
                        if (context.read<AddDiaryBloc>().update) {
                          BlocProvider.of<AddDiaryBloc>(context).add(UpdateAddDiaryDataEvent(context));
                        } else {
                          BlocProvider.of<AddDiaryBloc>(context).add(AddDiaryDataEvent(context));
                        }
                      }
                    }
                  },
                  icon: Icon(
                    Icons.save,
                  ),
                ),
                context.read<AddDiaryBloc>().update
                    ? IconButton(
                        onPressed: () async {
                          confirmDialog(
                            onConfirm: () async {
                              await dbHelper.deleteItem(
                                id: context.read<AddDiaryBloc>().diaryList["${DatabaseHelper.colDiaryId}"],
                                matchId: DatabaseHelper.colDiaryId,
                                tableName: DatabaseHelper.tblDiary,
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            context: context,
                            content: "Do you really want to delete this diary?",
                            title: "Delete",
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            body: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextFormField(
                      controller: context.read<AddDiaryBloc>().diaryTitle,
                      style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Title",
                        hintStyle: TextStyleConstant.blackBold16.copyWith(fontSize: 18, color: Colors.grey),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                  ),
                  Expanded(
                    child: HtmlEditor(
                      controller: context.read<AddDiaryBloc>().controller,
                      htmlEditorOptions: HtmlEditorOptions(
                        hint: 'Description...',
                        initialText: context.read<AddDiaryBloc>().diaryContent,
                      ),
                      otherOptions: OtherOptions(
                        height: MediaQuery.of(context).size.height,
                      ),
                      htmlToolbarOptions: HtmlToolbarOptions(
                        defaultToolbarButtons: [
                          FontButtons(),
                          ColorButtons(),
                          ListButtons(),
                          ParagraphButtons(),
                        ],
                        customToolbarInsertionIndices: [2, 2],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorConstant.primaryColor,
            title: Text(
              context.read<AddDiaryBloc>().update ? "Expense Diary" : "Add Expense Diary",
              style: TextStyleConstant.whiteBold16,
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (context.read<AddDiaryBloc>().diaryTitle == null && context.read<AddDiaryBloc>().diaryContent == null) {
                    showToast("Please enter content");
                  } else {
                    showLoader(context);
                    var txt = await context.read<AddDiaryBloc>().controller.getText();
                    if (txt.contains('src=\"data:')) {
                      txt = '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                      showToast("Please Remove Image");
                      Navigator.pop(context);
                    } else {
                      print("TExt is $txt");
                      context.read<AddDiaryBloc>().diaryContent = txt;
                      print("DirtyContent is ${context.read<AddDiaryBloc>().diaryContent}");
                      if (context.read<AddDiaryBloc>().update) {
                        BlocProvider.of<AddDiaryBloc>(context).add(UpdateAddDiaryDataEvent(context));
                      } else {
                        BlocProvider.of<AddDiaryBloc>(context).add(AddDiaryDataEvent(context));
                      }
                    }
                  }
                },
                icon: Icon(
                  Icons.save,
                ),
              ),
              context.read<AddDiaryBloc>().update
                  ? IconButton(
                      onPressed: () async {
                        confirmDialog(
                          onConfirm: () async {
                            await dbHelper.deleteItem(
                              id: context.read<AddDiaryBloc>().diaryList["${DatabaseHelper.colDiaryId}"],
                              matchId: DatabaseHelper.colDiaryId,
                              tableName: DatabaseHelper.tblDiary,
                            );
                            Navigator.pop(context);
                          },
                          context: context,
                          content: "Do you really want to delete this diary?",
                          title: "Delete",
                        );
                      },
                      icon: Icon(
                        Icons.delete,
                      ),
                    )
                  : Container(),
              SizedBox(
                width: 10,
              )
            ],
          ),
          body: Center(),
        );
      },
    );
  }
}
