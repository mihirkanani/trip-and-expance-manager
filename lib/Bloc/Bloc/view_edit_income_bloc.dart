import 'dart:async';
import 'package:expense_manager/Bloc/Event/view_edit_income_event.dart';
import 'package:expense_manager/Bloc/State/view_edit_income_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ViewEditIncomeBloc extends Bloc<ViewEditIncomeEvent, ViewEditIncomeState> {
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

  ViewEditIncomeBloc({required var this.selectedCat}) : super(ViewEditIncomeEmptyState()) {
    on<ViewEditIncomeLoadEvent>(_onDataLoadState);
    on<GetDataLoadEvent>(_getData);
    on<ChangeDateAndTimeEvent>(_onChangeTimeAndDate);
    on<InsertIncomeEvent>(_onInsertExpanse);
    on<ChangeTabEvent>(_onTabChange);
    on<UpdateCameraDataEvent>(_onCameraDataUpdate);
  }

  _onDataLoadState(ViewEditIncomeLoadEvent event, Emitter<ViewEditIncomeState> emit) {
    PreferenceUtils.init();
    amountController.text = "${selectedCat[DatabaseHelper.colAmount]}".trim();
    remarkController.text = "${selectedCat[DatabaseHelper.colRemarks] ?? ''}";
    selectedDate = DateTime.fromMillisecondsSinceEpoch(selectedCat[DatabaseHelper.colDateCreated]);
    time = TimeOfDay(
      hour: int.parse(selectedCat[DatabaseHelper.colTime].split(":")[0]),
      minute: int.parse(
        selectedCat[DatabaseHelper.colTime].split(":")[1].split(" ")[0],
      ),
    );
  }

  _getData(GetDataLoadEvent event, Emitter<ViewEditIncomeState> emit) async {
    print("data ... id .... ${selectedCat[DatabaseHelper.colId]}");
    imageDataList.addAll(
      await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblImage,
          query: '${DatabaseHelper.colImageId}=${selectedCat[DatabaseHelper.colId]} AND ${DatabaseHelper.colType}=1'),
    );
    print(imageDataList.length.toString());
    isLoaded = true;
    emit(ViewEditIncomeLoaded());
  }

  _onChangeTimeAndDate(ChangeDateAndTimeEvent event, Emitter<ViewEditIncomeState> emit) {
    emit(ViewEditIncomeLoaded());
  }

  _onTabChange(ChangeTabEvent event, Emitter<ViewEditIncomeState> emit) {
    emit(ViewEditIncomeLoaded());
  }

  _onCameraDataUpdate(UpdateCameraDataEvent event, Emitter<ViewEditIncomeState> emit) async {
    if (imageByte == null) {
      showToast("first select image");
    } else if (imageDescController.text == null || imageDescController.text == "") {
      showToast("first enter description or remarks");
    } else {
      Map<String, dynamic> img = {
        DatabaseHelper.colImageId: selectedCat['${DatabaseHelper.colId}'],
        DatabaseHelper.colType: 0,
        DatabaseHelper.colImageData: imageByte,
        DatabaseHelper.colImageDesc: imageDescController.text,
        DatabaseHelper.colDateCreated: DateTime.now().millisecondsSinceEpoch,
      };
      newImages.add(img);
      print(newImages);
      imageByte = "";
      imageDescController.clear();
      emit(ViewEditIncomeLoaded());
      Navigator.pop(event.context);
    }
  }

  _onInsertExpanse(InsertIncomeEvent event, Emitter<ViewEditIncomeState> emit) async {
    isLoaded = false;

    Map<String, dynamic> row = {
      DatabaseHelper.colDateCreated: selectedDate!.millisecondsSinceEpoch.toString(),
      DatabaseHelper.colTime: time.format(event.context).toString(),
      DatabaseHelper.colRemarks: remarkController.text,
      DatabaseHelper.colAmount: double.parse(amountController.text),
    };

    print("insert data ... $row");
    final id = await dbHelper.update(row: row, tableName: DatabaseHelper.tblIncome, id: selectedCat[DatabaseHelper.colId]);
    print('inserted row id: $id');
    for (int i = 0; i < newImages.length; i++) {
      Map<String, dynamic> img = {
        DatabaseHelper.colImageId: selectedCat[DatabaseHelper.colId],
        DatabaseHelper.colType: 1,
        DatabaseHelper.colImageData: newImages[i][DatabaseHelper.colImageData],
        DatabaseHelper.colImageDesc: newImages[i][DatabaseHelper.colImageDesc],
        DatabaseHelper.colDateCreated: DateTime.now().millisecondsSinceEpoch,
      };
      final imgId = await dbHelper.insert(row: img, tableName: DatabaseHelper.tblImage);
    }
    for (int i = 0; i < deleteID.length; i++) {
      var del = await dbHelper.delete(id: deleteID[i], tableName: DatabaseHelper.tblImage);
      print("$del ... deleted..");
    }
    isLoaded = true;
  }
}
