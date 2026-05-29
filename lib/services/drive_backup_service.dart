import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import 'package:app_school/services/backup_service.dart';

class DriveBackupService {

  static final GoogleSignIn googleSignIn =
  GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  // SIGN IN + GET DRIVE API

  static Future<drive.DriveApi?> getDriveApi() async {

    try {

      GoogleSignInAccount? user =
          googleSignIn.currentUser;

      user ??= await googleSignIn.signInSilently();

      user ??= await googleSignIn.signIn();

      if (user == null) {
        return null;
      }

      final headers =
      await user.authHeaders;

      final client =
      GoogleAuthClient(headers);

      return drive.DriveApi(client);

    } catch (e) {

      print("DRIVE BACKUP ERROR: $e");

      return null;
    }
  }

  // UPLOAD BACKUP

  static Future<bool> uploadBackup() async {

    try {

      final driveApi =
      await getDriveApi();

      if (driveApi == null) {
        print("drive api is null");
        return false;
      }

      final backupFile =
      await BackupService.createBackup();

      if (backupFile == null) {
        return false;
      }

      final media = drive.Media(
        backupFile.openRead(),
        backupFile.lengthSync(),
      );

      final driveFile = drive.File()

        ..name =
            "school_backup.json"

        ..modifiedTime =
        DateTime.now().toUtc();

      await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      return true;

    } catch (e) {

      print(e);

      return false;
    }
  }
}

// GOOGLE AUTH CLIENT

class GoogleAuthClient
    extends http.BaseClient {

  final Map<String, String> headers;

  final http.Client client =
  http.Client();

  GoogleAuthClient(this.headers);

  @override
  Future<http.StreamedResponse> send(
      http.BaseRequest request,
      ) {

    request.headers.addAll(headers);

    return client.send(request);
  }
}