import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../boxes.dart';

class dataBackUp extends StatefulWidget {
  const dataBackUp({Key? key}) : super(key: key);

  @override
  State<dataBackUp> createState() => dataBackUpState();
}

class dataBackUpState extends State<dataBackUp> {
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
      final newPath1 = '${dir?.path}/sessons.hive';
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
         final newPath1 = '${dir?.path}/sessons.hive';
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
}
