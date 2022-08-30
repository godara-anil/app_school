import 'package:app_school/pages/authenticate.dart';
import 'package:app_school/pages/reports.dart';
import 'package:flutter/material.dart';
import 'package:app_school/pages/dashboard.dart';
import 'package:app_school/pages/expense_list.dart';
import 'package:app_school/pages/settings_sessions.dart';
import 'package:app_school/pages/dataBackUp.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesAdapter());
  Hive.registerAdapter(SessionsAdapter());
  await Hive.openBox<Expenses>('expenses');
  await Hive.openBox<Sessions>('sessions');
  runApp(MaterialApp(
    home: FingerprintPage(),
    routes: {
      '/dashboard': (context) => dashboard(),
      '/expenses': (context) => expenses(),
      '/settings': (context) => Settings_session(),
      '/dataBackUp': (context) => dataBackUp(),
      '/reports': (context) => reports(),
    },
    /*theme: ThemeData(
      primaryColor: Colors.green[700],
    ),*/
  ));
}



