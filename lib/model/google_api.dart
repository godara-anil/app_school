
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;



class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
class UploadDatabase {

  final googleSignIn = GoogleSignIn.standard(scopes: [
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
  ]);

  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await  googleSignIn.signInSilently();
    final headers = await googleUser?.authHeaders;
    // print(googleUser);
    if (headers == null) {
      //await showMessage(context, "Sign-in first", "Error");
     return null;
    }
    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);
    return driveApi;
  }
  uploadToNormal() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return;
      }

      final folderId = await _getFolderId(driveApi);
      if (folderId == null) {
        //  await showMessage(context, "Failure", "Error");
        return;
      }
      // Create data here instead of loading a file
      File exp = File("/data/user/0/com.anil.app_school/app_flutter/expenses.hive");
      File sess = File('/data/user/0/com.anil.app_school/app_flutter/sessions.hive');
      var media = drive.Media(exp.openRead(), exp.lengthSync());
      var media1 = drive.Media(sess.openRead(), sess.lengthSync());

      // Set up File info
      var driveFile = drive.File();
      final timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now());
      driveFile.name = "expenses-$timestamp.hive";
      driveFile.modifiedTime = DateTime.now().toUtc();
      driveFile.parents = [folderId];

      var driveFile1 = drive.File();
      driveFile1.name = "sessions-$timestamp.hive";
      driveFile1.modifiedTime = DateTime.now().toUtc();
      driveFile1.parents = [folderId];

      // Upload
    //  final response =
      await driveApi.files.create(driveFile, uploadMedia: media, );
      // final response1 =
      await driveApi.files.create(driveFile1, uploadMedia: media1, );
     // print("response: $response");
     // print("response: $response1");

      // simulate a slow process
      // await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      // Remove a dialog
      return false;
    }
  }
  Future<String?> _getFolderId(drive.DriveApi driveApi) async {
    const mimeType = "application/vnd.google-apps.folder";
    String folderName = "myApp";
    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$folderName'",
        $fields: "files(id, name)",
      );
      final files = found.files;
      if (files == null) {
        // await showMessage(context, "Sign-in first", "Error");
        return null;
      }

      if (files.isNotEmpty) {
        // print(files.first.id);
        return files.first.id;
      }

      // Create a folder
      var folder = drive.File();
      folder.name = folderName;
      folder.mimeType = mimeType;
      final folderCreation = await driveApi.files.create(folder);
      return folderCreation.id;
    } catch (e) {
     // print(e);
      // I/flutter ( 6132): DetailedApiRequestError(status: 403, message: The granted scopes do not give access to all of the requested spaces.)
      return null;
    }
  }
}