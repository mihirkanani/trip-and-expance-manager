import 'dart:async';

import 'package:expense_manager/Bloc/Event/view_edit_expense_event.dart';
import 'package:expense_manager/Bloc/State/view_edit_expense_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ViewEditExpenseBloc extends Bloc<ViewEditExpenseEvent, ViewEditExpenseState> {
  bool isCategory = true;
  bool isLoaded = false;
  List deleteID = [];
  final picker = ImagePicker();

  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  List categoryList = [];

  List imageDataList = [];
  List newImages = [];

  // int expensesAmount;
  var selectedCat;
  TimeOfDay time = TimeOfDay.now();
  DateTime? selectedDate;
  Future<DateTime>? datePicker;
  String imageByte = "";
  TextEditingController imageDescController = TextEditingController();

  ViewEditExpenseBloc({required var this.selectedCat}) : super(ViewEditExpenseEmptyState()) {
    on<ViewEditExpenseLoadEvent>(_onDataLoadState);
    on<GetDataLoadEvent>(_getData);
    on<ChangeDateAndTimeEvent>(_onChangeTimeAndDate);
    on<InsertExpenseEvent>(_onInsertExpanse);
    on<ChangeTabEvent>(_onTabChange);
    on<UpdateCameraDataEvent>(_onCameraDataUpdate);
  }

  _onDataLoadState(ViewEditExpenseLoadEvent event, Emitter<ViewEditExpenseState> emit) {
    PreferenceUtils.init();
    print(selectedCat);
    amountController.text = "${selectedCat[DatabaseHelper.colAmount]}";
    remarkController.text = "${selectedCat[DatabaseHelper.colRemarks] ?? ''}";
    selectedDate = DateTime.fromMillisecondsSinceEpoch(selectedCat[DatabaseHelper.colDateCreated]);
    print("selectedDate $selectedDate");
    time = TimeOfDay(
      hour: int.parse(selectedCat[DatabaseHelper.colTime].split(":")[0]),
      minute: int.parse(selectedCat[DatabaseHelper.colTime].split(":")[1].split(" ")[0]),
    );
  }

  _getData(GetDataLoadEvent event, Emitter<ViewEditExpenseState> emit) async {
    print("data ... id .... ${selectedCat[DatabaseHelper.colId]}");
    imageDataList.addAll(await dbHelper.queryStringRow(
        tableName: DatabaseHelper.tblImage,
        query: '${DatabaseHelper.colImageId}=${selectedCat[DatabaseHelper.colId]} AND ${DatabaseHelper.colType}=0'));
    isLoaded = true;
    emit(ViewEditExpenseLoaded());
  }

  _onChangeTimeAndDate(ChangeDateAndTimeEvent event, Emitter<ViewEditExpenseState> emit) {
    emit(ViewEditExpenseLoaded());
  }

  _onTabChange(ChangeTabEvent event, Emitter<ViewEditExpenseState> emit) {
    emit(ViewEditExpenseLoaded());
  }

  _onCameraDataUpdate(UpdateCameraDataEvent event, Emitter<ViewEditExpenseState> emit) {
    if (imageByte == null) {
      showToast("first select image");
    } else if (imageDescController.text == null || imageDescController.text == "") {
      showToast("first enter description or remarks");
    } else {
      Map<String, dynamic> img = {
        DatabaseHelper.colImageId: selectedCat[DatabaseHelper.colId],
        DatabaseHelper.colType: 0,
        DatabaseHelper.colImageData: imageByte,
        DatabaseHelper.colImageDesc: imageDescController.text,
        DatabaseHelper.colDateCreated: DateTime.now().millisecondsSinceEpoch,
      };
      newImages.add(img);
      print(newImages);
      imageByte = "";
      imageDescController.clear();
      emit(ViewEditExpenseLoaded());
      Navigator.pop(event.context);
    }
  }

  _onInsertExpanse(InsertExpenseEvent event, Emitter<ViewEditExpenseState> emit) async {
    isLoaded = false;
    Map<String, dynamic> row = {
      DatabaseHelper.colDateCreated: selectedDate!.millisecondsSinceEpoch.toString(),
      DatabaseHelper.colTime: time.format(event.context).toString(),
      DatabaseHelper.colRemarks: remarkController.text,
      DatabaseHelper.colAmount: double.parse(amountController.text),
    };

    print("insert data ... $row");
    final id = await dbHelper.update(row: row, tableName: DatabaseHelper.tblExpense, id: selectedCat[DatabaseHelper.colId]);
    print('inserted row id: $id');
    for (int i = 0; i < newImages.length; i++) {
      Map<String, dynamic> img = {
        DatabaseHelper.colImageId: selectedCat[DatabaseHelper.colId],
        DatabaseHelper.colType: 0,
        DatabaseHelper.colImageData: newImages[i][DatabaseHelper.colImageData],
        DatabaseHelper.colImageDesc: newImages[i][DatabaseHelper.colImageDesc],
        DatabaseHelper.colDateCreated: DateTime.now().millisecondsSinceEpoch,
      };
      final imgId = await dbHelper.insert(row: img, tableName: DatabaseHelper.tblImage);
    }

    for (int i = 0; i < deleteID.length; i++) {
      var del = await dbHelper.delete(id: deleteID[i], tableName: DatabaseHelper.tblImage);
    }
    isLoaded = true;
  }
}
