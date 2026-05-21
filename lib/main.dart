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
import 'package:app_school/boxes.dart';



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
  print("START 1");
  await Hive.initFlutter();
  print("START 2");
  Hive.registerAdapter(ExpensesAdapter());
  Hive.registerAdapter(SessionsAdapter());
  Hive.registerAdapter(AccountAdapter());
  print("START 3");
  await Hive.openBox<Expenses>('expenses');
  print("START 4");
  await Hive.openBox<Sessions>('sessions');
  print("START 5");
  await Hive.openBox<Account>('accounts');
  print("START 6");
  final accountsBox = AccountsBox.getAccounts();
  if (accountsBox.isEmpty) {
    await accountsBox.add(
      Account(
        name: "Cash",
        openingBalance: 0,
        type: "cash",
      ),
    );

    await accountsBox.add(
      Account(
        name: "SBI Bank",
        openingBalance: 0,
        type: "bank",
      ),
    );

    await accountsBox.add(
      Account(
        name: "HGB",
        openingBalance: 0,
        type: "bank",
      ),
    );
  }
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