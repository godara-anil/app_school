import 'package:app_school/model/Expenses.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
class dataBackup {
  backUp() async {
    final box = await Hive.openBox<Expenses>('expenses');
    final boxPath = box.path;
    await box.close();
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final localFile = await File('/storage/emulated/0/Android/data/data.hive').create(recursive: true);
    print(directory.path);
    // print(boxPath);
    try {
      var  contents = await File('$boxPath').readAsBytes() ;
      localFile.writeAsBytes(contents);
    } finally {
      await Hive.openBox<Expenses>('expenses');
    }
  }

}
