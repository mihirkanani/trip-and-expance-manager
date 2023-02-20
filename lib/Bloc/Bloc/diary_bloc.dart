import 'package:expense_manager/Bloc/Event/diary_event.dart';
import 'package:expense_manager/Bloc/State/diary_state.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/main.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  List onDiaryList = [];
  bool isLoaded = false;

  DiaryBloc() : super(DiaryInitialState()) {
    on<DiaryLoadEvent>(_onInitialState);
    on<GetDiaryDataEvent>(_onGetDiaryDataState);
  }

  _onInitialState(DiaryLoadEvent event, Emitter<DiaryState> emit) {
    PreferenceUtils.init();
    BlocProvider.of<DiaryBloc>(event.context).add(GetDiaryDataEvent(event.context));
  }

  _onGetDiaryDataState(GetDiaryDataEvent event, Emitter<DiaryState> emit) async {
    onDiaryList = await dbHelper.queryAllRows(
      tableName: DatabaseHelper.tblDiary,
    );
    emit(DiaryDataLoaded());
  }
}
