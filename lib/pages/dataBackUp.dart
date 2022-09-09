import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../boxes.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;


class dataBackUp extends StatefulWidget {
  const dataBackUp({Key? key}) : super(key: key);

  @override
  State<dataBackUp> createState() => dataBackUpState();
}

class dataBackUpState extends State<dataBackUp> {
  final googleSignIn = GoogleSignIn.standard(scopes: [
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
  ]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Fuctions'),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => _fetchData(context, true),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  primary: Colors.green[900],
                ),
                child: Text(
                    'Back Up Local',
                  style: TextStyle(fontSize: 24),
                )
            ),
            SizedBox(height: 24,),
            ElevatedButton(onPressed:_shareFile,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10)
                ),
                child: Text('Share Data',
                  style: TextStyle(fontSize: 24),
                )
            ),
            SizedBox(height: 24,),
            ElevatedButton(onPressed: () => _fetchData(context, false),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  primary: Colors.red[900]
                ),
                child: Text('Restore Data',
                  style: TextStyle(fontSize: 24),
                )
            ),
            SizedBox(height: 24,),
            ElevatedButton(onPressed: () => _uploadToNormal(),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  primary: Colors.blueAccent[900]
                ),
                child: Text('Google Drive',
                  style: TextStyle(fontSize: 24),
                )
            ),
          ],
        ),
      ),
    );
  }
  void _fetchData(BuildContext context, isCreate) async {
    String textValue = isCreate ? 'backup' : 'restore';
    final response = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('Alert!!!',
            style: TextStyle(color: Colors.blue),),
            content: Text('Are you sure you want to $textValue the data!'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('OK'),
              ),
            ],
          ),
    );
    // show the loading dialog
    if (response != null && response == true) {
          showDialog(
      // The user CANNOT close this dialog  by pressing outside it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });
    // await Future.delayed(const Duration(seconds: 3));
    if (isCreate) {
      var response = await _createBackupFile();
      Navigator.of(context).pop();
      if(response != true) _showError(context);
    }
    else if (!isCreate) {
      var response = await _restoreDb();
      Navigator.of(context).pop();
      if(response != true) _showError(context);
    }
  }
       // Close the dialog programmatically
  }
  Future _restoreDb() async {
    if(await Permission.storage.request().isGranted) {
      var dir = await getExternalStorageDirectory();
      final boxPath = Boxes.getTransactions().path;
      final boxPath1 = Sess.getTransactions().path;
      final newPath = '${dir?.path}/expenses.hive';
      final newPath1 = '${dir?.path}/sessions.hive';
      try {
        await File(newPath).copy(boxPath!);
        await File(newPath1).copy(boxPath1!);
        return true;
      } catch (e) {
        return e;
      }
    }
    else {
      // Handle the error
      return true;
    }

  }
  Future<void> _shareFile() async {
    try {
      await Share.shareFiles([Boxes.getTransactions().path.toString(),
        Sess.getTransactions().path.toString() ], subject: "Database");
    } catch (e) {
      print(e);
    }
  }
  Future  _createBackupFile() async {
       if(await Permission.storage.request().isGranted) {
       //  Directory dir = Directory('/storage/emulated/0/Download');
         var dir = await getExternalStorageDirectory();
         final boxPath = Boxes.getTransactions().path;
         final boxPath1 = Sess.getTransactions().path;
         final newPath = '${dir?.path}/expenses.hive';
         final newPath1 = '${dir?.path}/sessions.hive';
         try {
           await File(boxPath!).copy(newPath);
           await File(boxPath1!).copy(newPath1);
           return true;
         }
         catch (e) { return e;}
       }
       else {
         // Handle the error
         return false;
       }
     }
  Future _showError(BuildContext context) {
        return showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: const Text('Error!!!',
                  style: TextStyle(color: Colors.red),),
                content: Text('Unable to process the request!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            });
     }
  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await  googleSignIn.signIn();
    final headers = await googleUser?.authHeaders;
    if (headers == null) {
      //await showMessage(context, "Sign-in first", "Error");
      print('error');
      return null;
    }
    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);
    return driveApi;
  }
  Future<void> _showList() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      print('returned from here');
      return;
    }
    final fileList = await driveApi.files.list(
      spaces: 'myApp',
      $fields: 'files(id, name, modifiedTime)',
    );
    print('i am here');
    final files = fileList.files;
    if (files == null) {
      //return showMessage(context, "Data not found", "");
      print('data not found');
    }

    final alert = AlertDialog(
      title: Text("Item List"),
      content: SingleChildScrollView(
        child: ListBody(
          children: files!.map((e) => Text(e.name ?? "no-name")).toList(),
        ),
      ),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
  Future<void> _uploadToNormal() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return;
      }
      // Not allow a user to do something else
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: Duration(seconds: 2),
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (context, animation, secondaryAnimation) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      final folderId = await _getFolderId(driveApi);
      if (folderId == null) {
      //  await showMessage(context, "Failure", "Error");
        return;
      }

      // Create data here instead of loading a file
      File exp = File(Boxes.getTransactions().path!);
      File sess = File(Sess.getTransactions().path!);
      var media = new drive.Media(exp.openRead(), exp.lengthSync());
      var media1 = new drive.Media(sess.openRead(), sess.lengthSync());

      // Set up File info
      var driveFile = new drive.File();
      final timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now());
      driveFile.name = "expenses-$timestamp.hive";
      driveFile.modifiedTime = DateTime.now().toUtc();
      driveFile.parents = [folderId];

      var driveFile1 = new drive.File();
      driveFile1.name = "sessions-$timestamp.hive";
      driveFile1.modifiedTime = DateTime.now().toUtc();
      driveFile1.parents = [folderId];

      // Upload
      final response =
      await driveApi.files.create(driveFile, uploadMedia: media, );
      final response1 =
      await driveApi.files.create(driveFile1, uploadMedia: media1, );
      print("response: $response");
      print("response: $response1");

      // simulate a slow process
      await Future.delayed(Duration(seconds: 2));
    } finally {
      // Remove a dialog
      Navigator.pop(context);
    }
  }
  Future<String?> _getFolderId(drive.DriveApi driveApi) async {
    final mimeType = "application/vnd.google-apps.folder";
    String folderName = "myApp";
    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$folderName'",
        $fields: "files(id, name)",
      );
      print('found');
      final files = found.files;
      if (files == null) {
       // await showMessage(context, "Sign-in first", "Error");
        return null;
      }
      if (files.isNotEmpty) {
        return files.first.id;
      }

      // Create a folder
      var folder = new drive.File();
      folder.name = folderName;
      folder.mimeType = mimeType;
      final folderCreation = await driveApi.files.create(folder);
      print("Folder ID: ${folderCreation.id}");

      return folderCreation.id;
    } catch (e) {
      print(e);
      // I/flutter ( 6132): DetailedApiRequestError(status: 403, message: The granted scopes do not give access to all of the requested spaces.)
      return null;
    }
  }
}
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = new http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
