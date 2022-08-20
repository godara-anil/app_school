import 'package:flutter/material.dart';
import 'package:app_school/pages/dashboard.dart';
import 'package:app_school/pages/expense_list.dart';
import 'package:app_school/pages/settings_sessions.dart';
import 'package:app_school/pages/dataBackUp.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/pages/splashScreen.dart';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesAdapter());
  Hive.registerAdapter(SessionsAdapter());
  await Hive.openBox<Expenses>('expenses');
  await Hive.openBox<Sessions>('sessions');
  runApp(MaterialApp(
    home: dashboard(),
    routes: {
      '/dashboard': (context) => dashboard(),
      '/expenses': (context) => expenses(),
      '/settings': (context) => Settings_session(),
      '/splash': (context) => SplashScreen(),
      '/dataBackUp': (context) => dataBackUp(),
    },
  ));
}

