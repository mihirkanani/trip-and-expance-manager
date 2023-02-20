import 'dart:convert';

import 'package:expense_manager/Bloc/Event/edit_trip_event.dart';
import 'package:expense_manager/Bloc/State/edit_trip_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditTripBloc extends Bloc<EditTripEvent, EditTripState> {
  TextEditingController tripNameController = TextEditingController();
  TextEditingController placeDescriptionController = TextEditingController();
  List userDataList = [];
  List selectedIndex = [];
  List selectedUsers = [];
  List<double> userPart = [];
  var tripImageData;
  List onGroupList = [];
  var userProfile;
  var userName;
  var insertUserId;
  var groupName;
  var selectedGroup;
  bool isLoaded = false;
  DateTime? beginDate;
  DateTime? endDate;
  var defaultImgBytes;
  var defaultTripImgBytes;
  List onUsersList = [];
  var editPersonList = [];
  var tripID;
  var tripExpenseID;
  var selectedData;
  ValueNotifier<int> id = ValueNotifier(0);

  EditTripBloc({required var this.selectedData}) : super(EditTripEmptyState()) {
    on<EditTripLoadEvent>(_onDataLoadState);
    on<EditTripGetGroupDataEvent>(_onGetGroupDataState);
    on<AddGroupExpansesEvent>(_onAddGroupExpansesState);
    on<GetGroupInfoEvent>(_onGetGroupInfo);
    on<AddUserEvent>(_onAddUser);
    on<GetUserInfo>(_onGetUserInfo);
    on<UpdateTripEvent>(_onUpdateTrip);
    on<DataReload>(_onDataLoaded);
  }
  _onDataLoaded(DataReload event, Emitter<EditTripState> emit) {
    emit(EditTripDataLoaded());
  }

  _onDataLoadState(EditTripLoadEvent event, Emitter<EditTripState> emit) async {
    ByteData bytes = await rootBundle.load('assets/images/defaultPersonImg.png');
    var buffer = bytes.buffer;
    defaultImgBytes = base64.encode(Uint8List.view(buffer));

    ByteData bytesTrip = await rootBundle.load('assets/images/TripImg.png');
    var bufferTrip = bytesTrip.buffer;
    defaultTripImgBytes = base64.encode(Uint8List.view(bufferTrip));

    PreferenceUtils.init();
    onGroupList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblGroupExpense,
    );
    print(" Group List .......${onGroupList.length}");
    isLoaded = true;
    //===================================================================
    editPersonList = [];
    var tripData = selectedData["tripData"];
    tripID = tripData['${DatabaseHelper.colId}'];
    print("tripID : $tripID");
    tripNameController.text = tripData['${DatabaseHelper.colTripName}'];
    placeDescriptionController.text = tripData['${DatabaseHelper.colTripPlaceDesc}'];
    tripImageData = tripData['${DatabaseHelper.colTripImage}'];
    beginDate = DateTime.fromMillisecondsSinceEpoch(tripData['${DatabaseHelper.colTripFromDate}']);
    endDate = DateTime.fromMillisecondsSinceEpoch(tripData['${DatabaseHelper.colTripToDate}']);
    var userList = selectedData["userList"];
    print("Group Id .........${tripData['${DatabaseHelper.colGroupId}']}");

    print(userList);
    for (int i = 0; i < userList.length; i++) {
      print(userList[i]);
      int? total;
      await dbHelper
          .copysumOfSummaryWithUserColumn(
        tableName: DatabaseHelper.tblTripExpense,
        columnName: DatabaseHelper.colTripExpAmount,
        matchId: '${DatabaseHelper.colUserId}',
        id: userList[i]['data']['${DatabaseHelper.colUserId}'].toString(),
        matchId2: '${DatabaseHelper.colTripId}',
        id2: '$tripID',
      )
          .then((value) {
        if (value != null) {
          total = value as int;
        } else {
          total = 0;
        }
      });
      editPersonList.add({
        "${DatabaseHelper.colUserId}": userList[i]['data']['${DatabaseHelper.colUserId}'],
        "${DatabaseHelper.colTripUserProfile}": userList[i]['data']['${DatabaseHelper.colTripUserProfile}'],
        "${DatabaseHelper.colTripUserName}": userList[i]['data']['${DatabaseHelper.colTripUserName}'],
        "${DatabaseHelper.colTripUserPart}": userList[i]['data']['${DatabaseHelper.colTripUserPart}'],
        "expense": '$total'
      });
    }
    print("------------------");
    BlocProvider.of<EditTripBloc>(event.context).add(EditTripGetGroupDataEvent(event.context, null, null));
  }

  _onGetGroupDataState(EditTripGetGroupDataEvent event, Emitter<EditTripState> emit) async {
    var tripData = selectedData["tripData"];
    onGroupList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblGroupExpense,
    );
    if (event.groupList != null) {
      selectedGroup = event.groupList;
    } else if (event.userList1 != null) {
      userDataList.add(event.userList1);
      print("UserList 1 Is Display in ${event.userList1}");
    } else {
      for (var i in onGroupList) {
        if (tripData['${DatabaseHelper.colGroupId}'] == i['${DatabaseHelper.colGroupId}']) {
          selectedGroup = i;
        }
      }
    }
    var userList = [];
    userList.addAll(await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblUsers,
    ));
    print(" User Data .......${onUsersList.length}");

    onUsersList = userList;
    // for (var edit in editPersonList) {
    //   for(int i=0; i<onUsersList.length; i++){
    //     if(onUsersList[i]['${DatabaseHelper.colUserId}'] == edit['${DatabaseHelper.colUserId}']){
    //      selectedIndex.add(i);
    //      selectedUsers.add(onUsersList[i]);
    //       // userDataList.add(onUsersList[i]);
    //     }
    //   }
    // //   onUsersList.removeWhere((element) => element['${DatabaseHelper.colUserId}'] == edit['${DatabaseHelper.colUserId}']);
    // }
    for (var edit in editPersonList) {
      onUsersList.removeWhere((element) => element['${DatabaseHelper.colUserId}'] == edit['${DatabaseHelper.colUserId}']);
    }
    print(" Group List .......${onGroupList.length}");
    print(" User List .......${onUsersList.length}");
    print(" selectedIndex .......${selectedIndex}");
    isLoaded = true;

    emit(EditTripDataLoaded());
  }

  _onAddGroupExpansesState(AddGroupExpansesEvent event, Emitter<EditTripState> emit) async {
    isLoaded = false;
    Map<String, dynamic> row = {
      DatabaseHelper.colGroupName: groupName,
      DatabaseHelper.colGroupExpense: '',
    };
    print("insert data ... $row");
    id.value = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblGroupExpense);
    BlocProvider.of<EditTripBloc>(event.context).add(GetGroupInfoEvent(event.context));
    print('inserted row id: ${id.value}');
  }

  _onGetGroupInfo(GetGroupInfoEvent event, Emitter<EditTripState> emit) async {
    var group = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblGroupExpense, query: "${DatabaseHelper.colGroupId} = ${id.value}");
    print('group Selected value row id: $group');
    selectedGroup = group[0];
    BlocProvider.of<EditTripBloc>(event.context).add(EditTripGetGroupDataEvent(event.context, group[0], null));
  }

  _onAddUser(AddUserEvent event, Emitter<EditTripState> emit) async {
    isLoaded = false;
    Map<String, dynamic> row = {DatabaseHelper.colUserName: userName, DatabaseHelper.colUserProfile: userProfile, DatabaseHelper.colUserExpense: ''};
    print("insert data ... $row");
    id.value = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblUsers);
    print('inserted row id: $id');
    BlocProvider.of<EditTripBloc>(event.context).add(GetUserInfo(event.context));
  }

  _onGetUserInfo(GetUserInfo event, Emitter<EditTripState> emit) async {
    var user = await dbHelper.queryStringRow(tableName: DatabaseHelper.tblUsers, query: "${DatabaseHelper.colUserId} = ${id.value}");
    print('user Selected value row id: $user');
    BlocProvider.of<EditTripBloc>(event.context).add(EditTripGetGroupDataEvent(event.context, null, user[0]));
  }

  _onUpdateTrip(UpdateTripEvent event, Emitter<EditTripState> emit) async {
    Map<String, dynamic> row = {
      DatabaseHelper.colTripFromDate: beginDate!.millisecondsSinceEpoch,
      DatabaseHelper.colTripToDate: endDate!.millisecondsSinceEpoch,
      DatabaseHelper.colTripName: tripNameController.text,
      DatabaseHelper.colGroupId: selectedGroup['${DatabaseHelper.colGroupId}'],
      DatabaseHelper.colTripPlaceDesc: placeDescriptionController.text,
      DatabaseHelper.colTripImage: tripImageData ?? defaultTripImgBytes,
    };
    print("insert data ... $row");

    Map<String, dynamic> trip = {
      DatabaseHelper.colGroupId: selectedGroup['${DatabaseHelper.colGroupId}'],
    };
    id.value = await dbHelper.update(row: row, tableName: DatabaseHelper.tblTrip, id: tripID);
    final tripUser = await dbHelper.tripExpenseUpdate(row: trip, tableName: DatabaseHelper.tblTripUsers, id: tripID);
    final tripExpense = await dbHelper.tripExpenseUpdate(row: trip, tableName: DatabaseHelper.tblTripExpense, id: tripID);

    print('inserted row id: ${id.value}');
    print('Trip row id: $tripExpense');
    print('Trip User id: $tripUser');

    for (var i = 0; i < editPersonList.length; i++) {
      id.value = await dbHelper.tripUserPartUpdate(
          tableName: DatabaseHelper.tblTripUsers,
          tripUserPart: "${editPersonList[i]['${DatabaseHelper.colTripUserPart}']}",
          userId: '${editPersonList[i]['${DatabaseHelper.colUserId}']}',
          tripId: "$tripID");
      print('updated row id: ${id.value}');
    }
    for (var i in userDataList) {
      Map<String, dynamic> row = {
        DatabaseHelper.colTripId: tripID,
        DatabaseHelper.colTripUserName: i['${DatabaseHelper.colUserName}'],
        DatabaseHelper.colUserId: i['${DatabaseHelper.colUserId}'],
        DatabaseHelper.colGroupId: selectedGroup['${DatabaseHelper.colGroupId}'],
        DatabaseHelper.colTripUserProfile: i['${DatabaseHelper.colUserProfile}'],
        DatabaseHelper.colTripUserPart: '1.0',
      };
      print("insert data ... $row");
      id.value = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblTripUsers);
      print('inserted row id: ${id.value}');

      for (var i = 0; i < userDataList.length; i++) {
        print("User Part Iis ${userPart[i]}");
        id.value = await dbHelper.tripUserPartUpdate(
            tableName: DatabaseHelper.tblTripUsers,
            tripUserPart: "${userPart[i]}",
            userId: '${userDataList[i]['${DatabaseHelper.colUserId}']}',
            tripId: "$tripID");
        print('updated row id: ${id.value}');
      }
    }
  }
}
