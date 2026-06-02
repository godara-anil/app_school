import 'package:app_school/pages/authenticate.dart';
import 'package:app_school/pages/reports_home_page.dart';
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
import 'package:app_school/pages/account_summary_page.dart';
import 'package:app_school/pages/account_ledger_page.dart';
import 'package:app_school/pages/ledger_page.dart';
import 'package:app_school/pages/accounts_page.dart';
import 'package:app_school/model/category_model.dart';
import 'package:app_school/pages/category_page.dart';
import 'package:app_school/pages/expense_pie_chart_page.dart';



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
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CategoryAdapter());
  await Hive.openBox<Expenses>('expenses');
  await Hive.openBox<Sessions>('sessions');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Category>('categories');
  final accountsBox = AccountsBox.getAccounts();
  /*if (accountsBox.isEmpty) {
    await accountsBox.add(
      Account(
        name: "Cash",
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
  }*/
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
      '/expenses': (context) => const ExpensesPage(),
      '/settings': (context) => const Settings_session(),
      '/dataBackUp': (context) => const DataBackupPage(),
      '/reports': (context) => const ReportsHomePage(),
      '/accountsSummary': (context) => const AccountSummaryPage(),
      '/accounts': (context) => const AccountsPage(),
      '/ledger': (context) => const LedgerPage(),
      '/categories': (context) => const CategoryPage(),
      '/expensePieChart': (context) => const ExpensePieChartPage(),
     // '/accountLedger': (context) => const AccountLedgerPage(),
    },
    /*theme: ThemeData(
      primaryColor: Colors.green[700],
    ),*/
  ));
}