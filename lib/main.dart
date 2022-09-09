import 'package:app_school/pages/authenticate.dart';
import 'package:app_school/pages/reports.dart';
import 'package:flutter/material.dart';
import 'package:app_school/pages/dashboard.dart';
import 'package:app_school/pages/expense_list.dart';
import 'package:app_school/pages/settings_sessions.dart';
import 'package:app_school/pages/dataBackUp.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:workmanager/workmanager.dart';
import 'package:app_school/model/google_api.dart';



const fetchBackground = "backupDrive";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
      // Code to run in background
       //var an =
       await UploadDatabase().uploadToNormal();
       // print("i am backing up data: $an");
        break;
    }
    return Future.value(true);
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesAdapter());
  Hive.registerAdapter(SessionsAdapter());
  await Hive.openBox<Expenses>('expenses');
  await Hive.openBox<Sessions>('sessions');
  await Workmanager().initialize(
    callbackDispatcher,
      isInDebugMode: true,
  );
  await Workmanager().registerPeriodicTask(
    "1",
    existingWorkPolicy: ExistingWorkPolicy.keep,
    fetchBackground,
    frequency: const Duration(hours: 24),
    initialDelay:
    const Duration(seconds: 5),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(MaterialApp(
    home: FingerprintPage(),
    routes: {
      '/dashboard': (context) => dashboard(),
      '/expenses': (context) => const expenses(),
      '/settings': (context) => const Settings_session(),
      '/dataBackUp': (context) => const dataBackUp(),
      '/reports': (context) => const reports(),
    },
    /*theme: ThemeData(
      primaryColor: Colors.green[700],
    ),*/
  ));
}