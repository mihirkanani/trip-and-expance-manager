import 'dart:convert';
import 'dart:io';
import 'package:expense_manager/Services/ExportToText/src/sqlite_porter.dart';
import 'package:expense_manager/services/import_export_drive.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "expenses.db";
  static const _databaseVersion = 3;

  //
  static const colExAndRe = 'expense_recive';

  /// tables
  static const tblAccount = 'my_accounts';
  static const tblExpense = 'my_expenses';
  static const tblIncome = 'my_income';
  static const tblImage = 'images';
  static const tblCategory = 'categories';
  static const tblTrip = 'trips';
  static const tblTripUsers = 'trip_users';
  static const tblGroupExpense = 'group_expense';
  static const tblTripExpense = 'trip_expense';
  static const tblUsers = 'users';
  static const tblDiary = 'diary';

  //Coumn FIled on Diary
  static const colDiaryId = 'id';
  static const colDiaryTitle = 'title';
  static const colDiaryContent = 'content';

  /// columns names
  static const colId = 'id';
  static const colAccName = 'acc_name';
  static const colAccId = 'acc_id';
  static const colCategoryName = 'cate_name';
  static const colRemarks = 'remarks';
  static const colAmount = 'amount';
  static const colDateCreated = 'created_date';
  static const colTime = 'time';
  static const colImageData = 'imageData';
  static const colImageDesc = 'imageDesc';
  static const colName = 'name';

  /// 0--> Expense 1--> Income
  static const colCategoryType = 'cate_type';
  static const colCateIcon = 'cate_icon';
  static const colCateId = 'cate_id';
  static const colCateColor = 'cate_color';
  static const colImageId = 'image_id';
  static const colType = 'type';
  static const colExtra2 = 'extra2';
  static const colExtra1 = 'extra1';

  //group_expense filed
  static const colGroupId = 'group_id';
  static const colGroupName = 'group_name';
  static const colGroupExpense = 'group_expense';

  //group_expense filed
  static const colUserId = 'user_id';
  static const colUserName = 'user_name';
  static const colUserProfile = 'user_profile';
  static const colUserExpense = 'user_expense';

  /// trip manager
  static const colTripId = 'trip_id';
  static const colTripName = 'trip_name';
  static const colTripFromDate = 'from_date';
  static const colTripToDate = 'to_date';
  static const colTripPlaceDesc = 'trip_place_desc';
  static const colTripImage = 'trip_image';
  static const colTripCategoryName = 'trip_cate_name';
  static const colTripUserName = 'trip_user_name';
  static const colTripUserProfile = 'trip_user_profile';
  static const colTripUserId = 'trip_user_id';
  static const colTripUserPart = 'trip__user_part';
  static const colTripCateId = 'trip_cate_id';
  static const colTripTime = 'trip_time';
  static const colTripExpDesc = 'trip_exp_desc';
  static const colTripExpAmount = 'trip_exp_amount';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  String? dataFromBackup;

  // only have a single app-wide reference to the database
  static Database? _database;
  bool isImported = false;

  Future<Database> get database async {
    if (isImported) {
      _database = await _initDatabase(isImported);
      return _database!;
    }
    if (_database != null) {
      return _database!;
    }
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase(isImported);
    return _database!;
  }


  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }


  _initDatabase(isImported) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    var importDb = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: isImported ? _onLoad : _onCreate,
    );
    return importDb;
  }

  Future _onLoad(Database db, int version) async {
    var dbfile = jsonDecode(dataFromBackup!);
    List<String> dbData = dbfile.cast<String>();
    await dbImportSql(db, dbData);
  }

  List catList = [
    {"catName": "Sports", "icon": "Sports", "color": "#FE7317"},
    {"catName": "Shopping", "icon": "Shopping", "color": "#F47960"},
    {"catName": "Transport", "icon": "Transport", "color": "#2B3582"},
    {"catName": "Entertainment", "icon": "Entertainment", "color": "#6E3620"},
    {"catName": "Travels", "icon": "Travels", "color": "#3FA6C6"},
    {"catName": "Fuel", "icon": "Fuel", "color": "#FCB291"},
    {"catName": "Clothing", "icon": "Clothing", "color": "#C17B58"},
    {"catName": "Insurance", "icon": "Insurance", "color": "#109880"},
    {"catName": "Kids", "icon": "Kids", "color": "#D93C65"},
  ];

  List incomeCatList = [
    {"catName": "Bonus", "icon": "Bonus", "color": "#A53145"},
    {"catName": "Budget", "icon": "Budget", "color": "#34B28A"},
    {"catName": "Profit", "icon": "Profit", "color": "#868686"},
    {"catName": "Salary", "icon": "Salary", "color": "#00A9FF"}
  ];

  Future _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print("onCreate called ........");
    }
    await db.execute('''
          CREATE TABLE $tblAccount (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colAccName TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblExpense (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colAccId INTEGER NOT NULL,
            $colCategoryName TEXT NOT NULL,
            $colRemarks TEXT NOT NULL,
            $colCateIcon TEXT NOT NULL,
            $colCateId INTEGER NOT NULL,
            $colCateColor TEXT NOT NULL,
            $colAmount REAL NOT NULL,
            $colExtra1 TEXT,
            $colExtra2 TEXT,
            $colTime TEXT,
            $colDateCreated INTEGER NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblIncome (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colAccId INTEGER NOT NULL,
            $colCategoryName TEXT NOT NULL,
            $colRemarks TEXT NOT NULL,
            $colCateIcon TEXT NOT NULL,
            $colCateId INTEGER NOT NULL,
            $colCateColor TEXT NOT NULL,
            $colAmount REAL NOT NULL,
            $colExtra1 TEXT,
            $colExtra2 TEXT,
            $colTime TEXT,
            $colDateCreated INTEGER NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblImage (
            $colId INTEGER PRIMARY KEY,
            $colImageId INTEGER NOT NULL,
            $colType INTEGER NOT NULL,
            $colDateCreated INTEGER NOT NULL,
            $colImageData TEXT NOT NULL,
            $colExtra1 BLOB,
            $colExtra2 TEXT,
            $colImageDesc TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblCategory (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colName TEXT NOT NULL,
            $colCateIcon TEXT NOT NULL,
            $colCateColor TEXT NOT NULL,
            $colCategoryType INTEGER NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblTrip (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTripName TEXT NOT NULL,
            $colTripFromDate INTEGER NOT NULL,
            $colTripToDate INTEGER NOT NULL,
            $colGroupId INTEGER NOT NULL,
            $colTripPlaceDesc TEXT NOT NULL,
            $colTripImage TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblTripUsers (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTripId INTEGER NOT NULL,
            $colUserId INTEGER NOT NULL,
            $colTripUserPart REAL NOT NULL,
            $colGroupId INTEGER NOT NULL,
            $colTripUserName TEXT NOT NULL,
            $colTripUserProfile TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblTripExpense (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTripId INTEGER NOT NULL,
            $colTripUserId INTEGER NOT NULL,
            $colUserId INTEGER NOT NULL,
            $colGroupId INTEGER NOT NULL,
            $colTripCategoryName TEXT NOT NULL,
            $colTripUserName TEXT NOT NULL,
            $colTripTime TEXT NOT NULL,
            $colTripExpDesc TEXT NOT NULL,
            $colDateCreated INTEGER NOT NULL,
            $colExAndRe TEXT NOT NULL,
            $colTripExpAmount INTEGER NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblGroupExpense (
            $colGroupId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colGroupName TEXT NOT NULL,
            $colGroupExpense INTEGER NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblUsers (
            $colUserId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colUserName TEXT NOT NULL,
            $colUserProfile TEXT NOT NULL,
            $colUserExpense INTEGER NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tblDiary (
            $colDiaryId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colDiaryTitle TEXT NOT NULL,
            $colDiaryContent TEXT NOT NULL
          )
          ''');

    for (int i = 0; i < catList.length; i++) {
      await db.execute(
        '''INSERT INTO $tblCategory ('$colName', '$colCateIcon', '$colCateColor', '$colCategoryType') 
               values (?, ?, ?, ?)''',
        ["${catList[i]['catName']}", "${catList[i]['icon']}", "${catList[i]['color']}", 0],
      );
    }

    for (int i = 0; i < incomeCatList.length; i++) {
      await db.execute(
        '''INSERT INTO $tblCategory ('$colName', '$colCateIcon', '$colCateColor', '$colCategoryType') 
               values (?, ?, ?, ?)''',
        ["${incomeCatList[i]['catName']}", "${incomeCatList[i]['icon']}", "${incomeCatList[i]['color']}", 1],
      );
    }
  }

  Future<int> insert({Map<String, dynamic>? row, String? tableName}) async {
    Database db = await instance.database;
    return await db.insert(tableName!, row!);
  }

  Future<List<Map<String, dynamic>>> queryAllRows({String? tableName}) async {
    Database db = await instance.database;
    return await db.query(tableName!);
  }

  Future<int?> queryRowCount({String? tableName}) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${tableName!}'));
  }

  dynamic exported;

  //Export db
  exportDB() async {
    Database db = await instance.database;
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/dbFile.txt';
    List<String> strData = await dbExportSql(db);
    exported = jsonEncode(strData);

    File file = File(filePath);
    file.writeAsString(exported);
    bool? res = await ImportExport().exportToDrive(filePath);
    if (res == null) {
      showToast("Something went wrong please try again later");
    } else {
      if (res) {
        showToast("Uploaded");
      } else if (!res) {
        showToast("Export False Please try again latter.");
      }
    }
  }

  Future loadDatabase(context) async {
    dataFromBackup = await ImportExport().importFromDrive();
    if (dataFromBackup != "") {
      if (dataFromBackup == "No Backup Available") {
        showToast(dataFromBackup!);
      } else {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentsDirectory.path, _databaseName);
        await deleteDatabase(path);
        isImported = true;

        await instance.database;
        showToast("New data loaded");
      }
    }
  }

  Future<List<Map<String, dynamic>>> queryStringRow({tableName, query}) async {
    Database db = await instance.database;
    return await db.query(
      tableName,
      where: query,
    );
  }

  Future<List<Map<String, dynamic>>> getSingleData({
    tableName,
  }) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT $colTripUserPart FROM $tableName");
  }

  Future<List<Map<String, dynamic>>> getSingleDataWithGroupBy({tableName, selectedValue, matchId, id, groupBy}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT $selectedValue FROM $tableName where $matchId==$id GROUP BY $groupBy");
  }

  Future<List<Map<String, dynamic>>> getGroupTotalExpense({sumName, tableName, matchId, id}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT SUM($sumName) as total FROM $tableName where $matchId==$id");
  }

  Future<List<Map<String, dynamic>>> getSumWithTwoWhereCondition({sumName, tableName, matchId, id, matchId2, id2}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT SUM($sumName) as total FROM $tableName where $matchId==$id AND $matchId2==$id2");
  }

  Future<List<Map<String, dynamic>>> getGroupAmountCondition({sumName, tableName, matchId, id, matchId2, id2, matchId3, id3}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT SUM($colTripExpAmount) as sum FROM $tableName where $matchId==$id AND $matchId2==$id2 AND $matchId3 == $id3");
  }

  Future<List<Map<String, dynamic>>> getGroupBYData({tableName, matchId, id, groupBy}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM $tableName where $matchId==$id GROUP BY $groupBy");
  }

  Future<List<Map<String, dynamic>>> getGroupBYSum({sumName, tableName, matchId, id, groupBy}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT SUM($sumName) as total FROM $tableName where $matchId==$id GROUP BY $groupBy");
  }

  Future<List<Map<String, dynamic>>> getDifferent({sumName, tableName, matchId, id, groupBy}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM $tableName where $matchId==$id GROUP BY $groupBy");
  }

  Future<List<Map<String, dynamic>>> getMultiDifferent({tableName, matchId, id, matchId2, id2}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM $tableName where $matchId==$id AND $matchId2 = $id2");
  }

  Future<List<Map<String, dynamic>>> getSingleViewMultiDifferent({tableName, matchId, id, matchId2, id2}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT $colTripUserPart as total FROM $tableName where $matchId==$id AND $matchId2 = $id2");
  }

  Future<List<Map<String, dynamic>>> getGroupBYSumWithMultipleCondition({sumName, tableName, matchId, matchId2, id, id2, groupBy}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT SUM($sumName) as total FROM $tableName where $matchId==$id AND $matchId2 == $id2 GROUP BY $groupBy");
  }

  Future<List<Map<String, dynamic>>> getGroupBWithMultipleCondition({tableName, matchId, matchId2, id, id2, groupBy}) async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM $tableName where $matchId==$id AND $matchId2 == $id2 GROUP BY $groupBy");
  }

  Future<Object?> sumOfColumn({String? tableName, String? columnName}) async {
    Database db = await instance.database;
    var res = await db.rawQuery('SELECT SUM($columnName) FROM $tableName');
    return res[0]['SUM($columnName)'];
  }

  Future<Object?> sumOfSummaryColumn({String? tableName, String? columnName, String? matchId, String? id}) async {
    Database db = await instance.database;
    var res = await db.rawQuery('SELECT SUM($columnName) FROM $tableName WHERE $matchId = $id');
    return res[0]['SUM($columnName)'];
  }

  Future<Object?> sumOfSummaryWithUserColumn(
      {String? tableName, String? columnName, String? matchId, String? id, String? matchId2, String? id2}) async {
    Database db = await instance.database;
    var res = await db.rawQuery('SELECT SUM($columnName) FROM $tableName WHERE $matchId = $id AND $matchId2 = $id2');
    return res[0]['SUM($columnName)'];
  }

  Future<Object?> copysumOfSummaryWithUserColumn(
      {String? tableName, String? columnName, String? matchId, String? id, String? matchId2, String? id2}) async {
    Database db = await instance.database;
    var res = await db.rawQuery('SELECT SUM($columnName) FROM $tableName WHERE $matchId = $id AND $matchId2 = $id2');
    return res[0]['SUM($columnName)'];
  }

  Future<Object?> sumOfTripExpense({String? columnName, int? tripId}) async {
    Database db = await instance.database;
    var res = await db.rawQuery('SELECT SUM($columnName) FROM $tblTripExpense WHERE $colTripId = $tripId');
    return res[0]['SUM($columnName)'];
  }

  Future<Object?> sumOfUserExpense({String? columnName, int? userId}) async {
    Database db = await instance.database;

    var res = await db.rawQuery('SELECT SUM($columnName) FROM $tblTripExpense WHERE $colTripUserId = $userId');
    return res[0]['SUM($columnName)'];
  }

  updateUserName({String? userName, String? updateName, String? userId, String? selectedUserId, String? tableName}) async {
    Database db = await instance.database;

    int updateCount = await db.rawUpdate('''
    UPDATE $tableName
    SET $userName = ?
    WHERE $userId = ?
    ''', ['$updateName', '$selectedUserId']);

    print("Update USer Name $updateCount");
  }

  updateTripUserName(
      {String? userName,
      String? updateName,
      String? userProfile,
      String? updateProfile,
      String? userId,
      String? selectedUserId,
      String? tableName}) async {
    Database db = await instance.database;

    int updateCount = await db.rawUpdate('''
    UPDATE $tableName 
    SET $userName = ?, $userProfile = ? 
    WHERE $userId = ?
    ''', ['$updateName', '$updateProfile', '$selectedUserId']);
  }

  Future<int> update({Map<String, dynamic>? row, String? tableName, int? id}) async {
    Database db = await instance.database;
    return await db.update(tableName!, row!, where: '${DatabaseHelper.colId} = ?', whereArgs: [id]);
  }

  Future<int> tripUserPartUpdate({
    String? tripUserPart,
    String? userId,
    String? tripId,
    String? tableName,
  }) async {
    Database db = await instance.database;
    return await db.rawUpdate('UPDATE $tableName SET $colTripUserPart = \'$tripUserPart\'  WHERE $colTripId = $tripId AND $colUserId = $userId');
  }

  Future<int> updateArg({Map<String, dynamic>? row, String? tableName, int? id, String? whereId}) async {
    Database db = await instance.database;
    return await db.update(tableName!, row!, where: '$whereId = ?', whereArgs: [id]);
  }

  Future<int> tripExpenseUpdate({Map<String, dynamic>? row, String? tableName, int? id}) async {
    Database db = await instance.database;
    return await db.update(tableName!, row!, where: '${DatabaseHelper.colTripId} = ?', whereArgs: [id]);
  }

  Future<int> delete({int? id, String? tableName}) async {
    Database db = await instance.database;
    return await db.delete(tableName!, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> deleteItem({int? id, String? tableName, String? matchId}) async {
    Database db = await instance.database;
    return await db.delete(tableName!, where: '$matchId = ?', whereArgs: [id]);
  }

  Future<int> userDelete({int? id, String? tableName}) async {
    Database db = await instance.database;
    return await db.delete(tableName!, where: '$colUserId = ?', whereArgs: [id]);
  }

  Future<int> tripUserDelete({int? id, int? tripId, String? tableName}) async {
    Database db = await instance.database;
    return await db.rawDelete("DELETE FROM $tableName WHERE $colUserId = $id AND $colTripId = $tripId");
  }

  Future<int> groupDelete({int? id, String? tableName}) async {
    Database db = await instance.database;
    return await db.delete(tableName!, where: '$colGroupId = ?', whereArgs: [id]);
  }

  Future<int> deleteTripExpense({tripid, int? id, String? tableName}) async {
    Database db = await instance.database;
    return await db.delete(tableName!, where: '$tripid = ?', whereArgs: [id]);
  }
}
