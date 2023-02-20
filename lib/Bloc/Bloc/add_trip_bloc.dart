import 'dart:convert';

import 'package:expense_manager/Bloc/Event/add_trip_event.dart';
import 'package:expense_manager/Bloc/State/add_trip_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTripBloc extends Bloc<AddTripEvent, AddTripState> {
  TextEditingController tripNameController = TextEditingController();
  TextEditingController placeDescriptioneController = TextEditingController();
  List userDataList = [];
  String? groupName;
  var tripImageData;
  var selectedGroup;
  String? userProfile;
  String? userName;
  List onUsersList = [];
  List onGroupList = [];
  bool isLoaded = false;
  DateTime? beginDate;
  DateTime? endDate;
  var defaultImgBytes;
  var defaultTripImgBytes;
  List<double> userPart = [];
  List selectedIndex = [];
  ValueNotifier<int> id =ValueNotifier(0);

  AddTripBloc() : super(AddTripEmptyState()) {
    on<AddTripLoadEvent>(_onDataLoadState);
    on<GetDataLoadEvent>(_getData);
    on<SetDataLoadEvent>(_setData);
    on<AddTripDataEvent>(_addTrip);
    on<AddPersonEvent>(_addPerson);
    on<UpdateUserEvent>(_updateUser);
    on<AddGroupExpenseEvent>(_addGroupExpense);
    on<GetGroupInfoEvent>(_getGroupInfo);
    on<GetGroupDataEvent>(_getGroupData);
    on<AddUserEvent>(_addUser);
    on<GetUserInfoEvent>(_getUserInfo);
    on<GetUserDataEvent>(_getUserData);
    on<DataFillChangeEvent>(_dataChangeFill);
    on<DataReload>(_onDataLoaded);
  }

  _onDataLoaded(DataReload event, Emitter<AddTripState> emit){
    emit(AddTripDataLoaded());
  }
  _onDataLoadState(AddTripLoadEvent event, Emitter<AddTripState> emit) async {
    PreferenceUtils.init();
    onGroupList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblGroupExpense,
    );
    print(" Group List .......${onGroupList.length}");
    isLoaded = true;
    BlocProvider.of<AddTripBloc>(event.context).add(GetDataLoadEvent(event.context));
  }
  _dataChangeFill(DataFillChangeEvent event, Emitter<AddTripState> emit) async {
    emit(AddTripDataLoaded());
  }

  _getData(GetDataLoadEvent event, Emitter<AddTripState> emit) async {
    onUsersList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblUsers,
    );
    print(" User List .......${onUsersList.length}");
    isLoaded = true;
    BlocProvider.of<AddTripBloc>(event.context).add(SetDataLoadEvent());
  }

  _setData(SetDataLoadEvent event, Emitter<AddTripState> emit) async {
    ByteData bytes = await rootBundle.load('assets/images/defaultPersonImg.png');
    var buffer = bytes.buffer;
    defaultImgBytes = base64.encode(Uint8List.view(buffer));

    ByteData bytesTrip = await rootBundle.load('assets/images/TripImg.png');
    var bufferTrip = bytesTrip.buffer;
    defaultTripImgBytes = base64.encode(Uint8List.view(bufferTrip));
    emit(AddTripDataLoaded());
  }

  _addTrip(AddTripDataEvent event, Emitter<AddTripState> emit) async {
    Map<String, dynamic> row = {
      DatabaseHelper.colTripFromDate: beginDate!.toLocal().millisecondsSinceEpoch,
      DatabaseHelper.colTripToDate: endDate!.toLocal().millisecondsSinceEpoch,
      DatabaseHelper.colTripName: tripNameController.text,
      DatabaseHelper.colGroupId: selectedGroup[DatabaseHelper.colGroupId],
      DatabaseHelper.colTripPlaceDesc: placeDescriptioneController.text,
      DatabaseHelper.colTripImage: tripImageData ?? defaultTripImgBytes,
    };
    print("insert data ... $row");
    id.value = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblTrip);
    print('inserted row id: $id');
    BlocProvider.of<AddTripBloc>(event.context).add(AddPersonEvent(event.context));
  }

  _addPerson(AddPersonEvent event, Emitter<AddTripState> emit) async {
    print("=> $userDataList");
    for (var i in userDataList) {
      Map<String, dynamic> row = {
        DatabaseHelper.colTripId: id.value,
        DatabaseHelper.colTripUserName: i[DatabaseHelper.colUserName],
        DatabaseHelper.colUserId: i[DatabaseHelper.colUserId],
        DatabaseHelper.colTripUserPart: '1',
        DatabaseHelper.colGroupId: selectedGroup[DatabaseHelper.colGroupId],
        DatabaseHelper.colTripUserProfile: i[DatabaseHelper.colUserProfile],
      };
      print("insert data ... $row");
      await dbHelper.insert(row: row, tableName: DatabaseHelper.tblTripUsers);
      print('inserted row id: ${id.value}');
    }
    BlocProvider.of<AddTripBloc>(event.context).add(UpdateUserEvent(event.context));
  }

  _updateUser(UpdateUserEvent event, Emitter<AddTripState> emit) async {
    for (var i = 0; i < userDataList.length; i++) {
      print("User Part Iis ${userPart[i]}");
      id.value = await dbHelper.tripUserPartUpdate(
        tableName: DatabaseHelper.tblTripUsers,
        tripUserPart: "${userPart[i]}",
        userId: '${userDataList[i][DatabaseHelper.colUserId]}',
        tripId: "${id.value}",
      );
      print('updated row id: ${id.value}');
    }
    Navigator.pop(event.context);
  }

  _addGroupExpense(AddGroupExpenseEvent event, Emitter<AddTripState> emit) async {
    isLoaded = false;
    Map<String, dynamic> row = {
      DatabaseHelper.colGroupName: groupName,
      DatabaseHelper.colGroupExpense: '',
    };
    print("insert data ... $row");
    id.value = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblGroupExpense);
    print('inserted row id: ${id.value}');
    BlocProvider.of<AddTripBloc>(event.context).add(GetGroupInfoEvent(event.context));
  }

  _getGroupInfo(GetGroupInfoEvent event, Emitter<AddTripState> emit) async {
    var group = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblGroupExpense, query: "${DatabaseHelper.colGroupId} = ${id.value}");
    print('group Selected value row id: $group');
    selectedGroup = group[0];
    BlocProvider.of<AddTripBloc>(event.context).add(GetGroupDataEvent());
  }

  _getGroupData(GetGroupDataEvent event, Emitter<AddTripState> emit) async {
    onGroupList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblGroupExpense,
    );
    print(" Group List .......${onGroupList.length}");
    isLoaded = true;
  }

  _addUser(AddUserEvent event, Emitter<AddTripState> emit) async {
    isLoaded = false;
    Map<String, dynamic> row = {DatabaseHelper.colUserName: userName, DatabaseHelper.colUserProfile: userProfile, DatabaseHelper.colUserExpense: ''};
    print("insert data ... $row");
    id.value = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblUsers);
    print('inserted row id: $id');
    BlocProvider.of<AddTripBloc>(event.context).add(GetUserInfoEvent(event.context));
  }

  _getUserInfo(GetUserInfoEvent event, Emitter<AddTripState> emit) async {
    var user = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblUsers, query: "${DatabaseHelper.colUserId} = ${id.value}");
    print('user Selected value row id: $user');
    userDataList.add(user[0]);
    BlocProvider.of<AddTripBloc>(event.context).add(GetUserDataEvent());
  }

  _getUserData(GetUserDataEvent event, Emitter<AddTripState> emit) async {
    onUsersList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblUsers,
    );
    print(" User List .......${onUsersList.length}");
    isLoaded = true;
  }
}
