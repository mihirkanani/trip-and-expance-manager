import 'package:expense_manager/Bloc/Event/add_diary_event.dart';
import 'package:expense_manager/Bloc/State/add_diary_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class AddDiaryBloc extends Bloc<AddDiaryEvent, AddDiaryState> {
  String result = "";
  final HtmlEditorController controller = HtmlEditorController();
  TextEditingController diaryTitle = TextEditingController();
  var diaryContent;
  var imageByte;
  final bool update;
  var diaryList;

  AddDiaryBloc({required this.update, required this.diaryList}) : super(AddDiaryInitialState()) {
    on<AddDiaryLoadEvent>(_onInitialState);
    on<GetAddDiaryDataEvent>(_onGetAddDiaryDataState);
    on<AddDiaryDataEvent>(_onAddDiaryState);
    on<UpdateAddDiaryDataEvent>(_onUpdateDiaryState);
    on<RefreshDataEvent>(_onRefreshDataState);
  }

  _onInitialState(AddDiaryLoadEvent event, Emitter<AddDiaryState> emit) {
    PreferenceUtils.init();
    update ? BlocProvider.of<AddDiaryBloc>(event.context).add(GetAddDiaryDataEvent(event.context)) : emit(AddDiaryDataLoaded());
  }

  _onRefreshDataState(RefreshDataEvent event, Emitter<AddDiaryState> emit) {
    emit(AddDiaryDataLoaded());
  }

  _onGetAddDiaryDataState(GetAddDiaryDataEvent event, Emitter<AddDiaryState> emit) {
    diaryTitle.text = diaryList['${DatabaseHelper.colDiaryTitle}'];
    diaryContent = diaryList['${DatabaseHelper.colDiaryContent}'];
    emit(AddDiaryDataLoaded());
  }

  _onAddDiaryState(AddDiaryDataEvent event, Emitter<AddDiaryState> emit) async {
    Map<String, dynamic> row = {
      DatabaseHelper.colDiaryTitle: diaryTitle == null ? '' : diaryTitle.text,
      DatabaseHelper.colDiaryContent: diaryContent == null ? '' : diaryContent
    };
    final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblDiary);
    print('inserted row id: $id');
    controller.clearFocus();
    Navigator.pop(event.context);
    Navigator.pop(event.context);
  }

  _onUpdateDiaryState(UpdateAddDiaryDataEvent event, Emitter<AddDiaryState> emit) async {
    print("Dialry COntent is $diaryContent");
    Map<String, dynamic> row = {
      DatabaseHelper.colDiaryTitle: diaryTitle == null ? '' : diaryTitle.text,
      DatabaseHelper.colDiaryContent: diaryContent == null ? '' : diaryContent
    };
    final id = await dbHelper.update(
      row: row,
      tableName: DatabaseHelper.tblDiary,
      id: diaryList['${DatabaseHelper.colDiaryId}'],
    );
    print('updated row id: $id');
    controller.clearFocus();
    Navigator.pop(event.context);
    Navigator.pop(event.context);
  }
}
