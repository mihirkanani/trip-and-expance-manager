import 'package:expense_manager/Bloc/Event/group_event.dart';
import 'package:expense_manager/Bloc/State/group_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  String groupName = "";
  List onGroupList = [];
  List pastTrips = [];
  List onGroupDelete = [];
  List groupTrips = [];
  bool isLoaded = false;
  List users = [];

  GroupBloc() : super(GroupInitialState()) {
    on<GroupLoadingEvent>(_onGroupLoadingState);
    on<GroupLoadEvent>(_onInitialState);
    on<GetGroupDataEvent>(_onGroupDataState);
    on<AddGroupExpenseEvent>(_onAddGroupExpenseState);
    on<UpdateGroupEvent>(_onUpdateGroupState);
  }

  _onInitialState(GroupLoadEvent event, Emitter<GroupState> emit) {
    PreferenceUtils.init();
    BlocProvider.of<GroupBloc>(event.context).add(GetGroupDataEvent(event.context));
  }

  _onGroupLoadingState(GroupLoadingEvent event, Emitter<GroupState> emit) {
    emit(GroupDataLoading());
  }

  _onGroupDataState(GetGroupDataEvent event, Emitter<GroupState> emit) async {
    groupTrips.clear();
    onGroupDelete.clear();
    onGroupList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblGroupExpense,
    );

    for (var group in onGroupList) {
      var groupl = await dbHelper.getGroupTotalExpense(
        sumName: '${DatabaseHelper.colTripExpAmount}',
        tableName: '${DatabaseHelper.tblTripExpense}',
        matchId: '${DatabaseHelper.colGroupId}',
        id: group['${DatabaseHelper.colGroupId}'],
      );

      groupTrips.add(groupl[0]['total'] == null ? 0.0 : groupl[0]['total']);

      var deleteGroup = await dbHelper.queryStringRow(
          tableName: DatabaseHelper.tblTripUsers, query: '${DatabaseHelper.colGroupId} = ${group['${DatabaseHelper.colGroupId}']}');
      print(" Delete List .......${deleteGroup}");

      onGroupDelete.add(deleteGroup);
    }
    emit(GroupDataLoaded());
    print(" Delete List .......${onGroupDelete.reversed}");
    print(" Group List .......${groupTrips}");
  }

  _onAddGroupExpenseState(AddGroupExpenseEvent event, Emitter<GroupState> emit) async {
    isLoaded = false;
    Map<String, dynamic> row = {
      DatabaseHelper.colGroupName: groupName,
      DatabaseHelper.colGroupExpense: '',
    };
    print("insert data ... $row");
    final id = await dbHelper.insert(row: row, tableName: DatabaseHelper.tblGroupExpense);
    BlocProvider.of<GroupBloc>(event.context).add(GetGroupDataEvent(event.context));
    print('inserted row id: $id');
  }

  _onUpdateGroupState(UpdateGroupEvent event, Emitter<GroupState> emit) async {
    isLoaded = false;
    Map<String, dynamic> row = {
      DatabaseHelper.colGroupName: groupName,
      DatabaseHelper.colGroupExpense: '',
    };
    print("Update data ... $row");
    final id = await dbHelper.updateArg(row: row, tableName: DatabaseHelper.tblGroupExpense, id: event.groupId, whereId: DatabaseHelper.colGroupId);
    BlocProvider.of<GroupBloc>(event.context).add(GetGroupDataEvent(event.context));
    print('Update row id: $id');
  }
}
