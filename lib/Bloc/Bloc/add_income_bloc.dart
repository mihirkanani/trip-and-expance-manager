import 'package:expense_manager/Bloc/Event/add_income_event.dart';
import 'package:expense_manager/Bloc/State/add_income_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';

class AddIncomeBloc extends Bloc<AddIncomeEvent, AddIncomeState> {
  bool isCategory = true;
  final picker = ImagePicker();
  DateTime datePicker = DateTime.now();

  List selectedDateList = [];
  List selectedTimeList = [];
  DateTime selectedDate = DateTime.now();
  List categoryList = [];

  List imageDataList = [];
  int? incomeAmount;

  List selectedCatList = [];
  int selectedCatLength = 0;
  int? interstitialId;

  List incomeAmountList = [];
  List remarkList = [];
  TimeOfDay time = TimeOfDay.now();
  // var imageByte;
  String imageByte ="";

  TextEditingController imageDescController = TextEditingController();

  AddIncomeBloc() : super(AddIncomeInitialState()) {
    on<AddIncomeInitialEvent>(_onInitialState);
    on<InsertExpenseEvent>(_onInsertExpanse);
    on<AddIncomeForStoreEvent>(_onAddIncome);
    on<ChangeDateAndTimeEvent>(_onChangeTimeAndDate);
    on<ChangeTabEvent>(_onTabChange);
    on<UpdateCameraDataEvent>(_onCameraDataUpdate);
  }

  _onCameraDataUpdate(UpdateCameraDataEvent event, Emitter<AddIncomeState> emit) {
    if (event.imageByte == "") {
      showToast("first select image");
    } else if (event.imageDescController == "") {
      showToast("first enter description or remarks");
    } else {
      imageDataList.add({"image": event.imageByte, "description": event.imageDescController});
      print("==> ${imageDataList}");
      emit(AddIncomeDataLoaded());
      Navigator.pop(event.context);
    }
  }

  _onChangeTimeAndDate(ChangeDateAndTimeEvent event, Emitter<AddIncomeState> emit) {
    emit(AddIncomeDataLoaded());
  }

  _onTabChange(ChangeTabEvent event, Emitter<AddIncomeState> emit) {
    emit(AddIncomeDataLoaded());
  }

  void _onInitialState(AddIncomeInitialEvent event, Emitter<AddIncomeState> emit) {
    PreferenceUtils.init();
    selectedDate = DateTime.now();
    getCategories();
    emit(AddIncomeDataLoaded());
  }

  getCategories() async {
    categoryList.clear();
    categoryList.addAll(await dbHelper.queryStringRow(tableName: DatabaseHelper.tblCategory, query: '${DatabaseHelper.colCategoryType}=1'));
  }

  Future<void> _onInsertExpanse(InsertExpenseEvent event, Emitter<AddIncomeState> emit) async {
    for (var list = 0; list < selectedCatList.length; list++) {
      Map<String, dynamic> row = {
        DatabaseHelper.colAccId: 1,
        DatabaseHelper.colCategoryName: "${selectedCatList[list][DatabaseHelper.colName]}",
        DatabaseHelper.colCateId: "${selectedCatList[list][DatabaseHelper.colId]}",
        DatabaseHelper.colCateIcon: "${selectedCatList[list][DatabaseHelper.colCateIcon]}",
        DatabaseHelper.colCateColor: "${selectedCatList[list][DatabaseHelper.colCateColor]}",
        DatabaseHelper.colRemarks: remarkList[list].toString(),
        DatabaseHelper.colAmount: incomeAmountList[list].toString(),
        DatabaseHelper.colTime: selectedTimeList[list].toString(),
        DatabaseHelper.colDateCreated: selectedDateList[list].toString(),
      };
      final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblIncome);
      for (int i = 0; i < imageDataList.length; i++) {
        Map<String, dynamic> img = {
          DatabaseHelper.colImageId: id,
          DatabaseHelper.colType: 1,
          DatabaseHelper.colImageData: imageDataList[i]['image'],
          DatabaseHelper.colImageDesc: imageDataList[i]['description'],
          DatabaseHelper.colDateCreated: selectedDateList[list].toString(),
        };
        await dbHelper.insert(row: img, tableName: DatabaseHelper.tblImage);
      }
    }
    Navigator.pop(event.context);
    showToast("Yay! Income added");
  }

  _onAddIncome(AddIncomeForStoreEvent event, Emitter<AddIncomeState> emit) {
    if (event.amountController == "") {
      showToast("Enter amount");
    }else {
      selectedCatList.add(categoryList[event.index]);
      incomeAmountList.add(int.parse(event.amountController));
      remarkList.add(event.remarkController);
      selectedDateList.add(selectedDate.millisecondsSinceEpoch);
      selectedTimeList.add(time.format(event.context));
      selectedCatLength = selectedCatList.length;
      emit(AddIncomeDataLoaded());
      Navigator.pop(event.context);
    }
  }
}

// class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
//   var imageByte;
//   TextEditingController imageDescController = TextEditingController();
//
//   ImageUploadBloc() : super(ImageUploadInitialState()) {
//     on<ImageUploadInitialEvent>(_onInitialState);
//   }
//
//   StreamSubscription? connectivitySubscription;
//
//   _onInitialState(ImageUploadInitialEvent event, Emitter<ImageUploadState> emit) {
//     emit(ImageUploadInitialState());
//   }
// }
