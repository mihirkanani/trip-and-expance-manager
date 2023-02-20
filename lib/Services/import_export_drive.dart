// ignore_for_file: unnecessary_null_comparison
import 'dart:io';
import 'package:expense_manager/Services/google_client.dart';
import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:path/path.dart' as p;

class ImportExport {
  drive.FileList? fl;
  drive.File? fi;

  googleAuth() async {
    final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final GoogleSignInAccount? account = await googleSignIn.signIn();

    final authHeaders = await account!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
  }

  Future<bool?> exportToDrive(filePath) async {
    File localFile = File(filePath);
    final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn().onError((error, stackTrace) {
      return null;
    });

    bool isUpdated, isExported = false;
    if (account != null) {
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      drive.FileList? fl;
      drive.File? fi;
      fl = await driveApi.files.list();

      try {
        var bak = fl.files!.firstWhere((element) => element.name == 'expense_backup.txt');
        if (bak != null) {
          var driveFile = drive.File()..name = p.basename("expense_backup.txt");
          final updateRes = await driveApi.files.update(
            driveFile,
            bak.id!,
            uploadMedia: drive.Media(
              localFile.openRead(),
              localFile.lengthSync(),
            ),
          );
          if (updateRes != null) {
            isUpdated = true;
          }
          return true;
        }
      } catch (e) {
        var driveFile = drive.File()..name = p.basename("expense_backup.txt");
        final result = await driveApi.files.create(driveFile, uploadMedia: drive.Media(localFile.openRead(), localFile.lengthSync()));
        if (result != null) {
          isExported = true;
        }
        return true;
      }
    } else {
      final dbHelper = DatabaseHelper.instance;
      return false;
    }
    return null;
  }

  Future<String> importFromDrive() async {
    final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn().onError((error, stackTrace) {
      return null;

    });
    String s = "";
    if (account != null) {
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      drive.FileList fl;
      fl = await driveApi.files.list();

      try {
        var bak = fl.files!.firstWhere((element) => element.name == 'expense_backup.txt');
        if (bak != null) {
          Object down = await driveApi.files.get(bak.id!, downloadOptions: drive.DownloadOptions.fullMedia);
          Object list = down;
          showToast("Please wait, It will take some time");

          // for (var i in list) {
          //   s += String.fromCharCodes(i);
          //   print("------------------ data ----------------");
          //   print(s);
          // }
          print("Data list ------- $s");
        }
      } catch (e) {
        print(e);
        s += "No Backup Available";
      }
    } else {
      // popNavigation();
      showToast("Something went Wrong.Try Again");
      // final dbHelper = DatabaseHelper.instance;
    }
    return s;
  }
}
