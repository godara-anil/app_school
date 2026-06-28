import 'package:app_school/pages/account_summary_page.dart';
import 'package:app_school/pages/accounts_page.dart';
import 'package:app_school/pages/authenticate.dart';
import 'package:app_school/pages/category_page.dart';
import 'package:app_school/pages/dashboard.dart';
import 'package:app_school/pages/data_backup.dart';
import 'package:app_school/pages/expense_list.dart';
import 'package:app_school/pages/expense_pie_chart_page.dart';
import 'package:app_school/pages/ledger_page.dart';
import 'package:app_school/pages/reports_home_page.dart';
import 'package:app_school/pages/settings_sessions.dart';
import 'package:app_school/services/app_database_service.dart';
import 'package:app_school/services/auto_backup_service.dart';
import 'package:app_school/services/background_backup_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabaseService.initialize();
  await BackgroundBackupService.initialize();
  runApp(const SchoolFinanceApp());
}

class SchoolFinanceApp extends StatefulWidget {
  const SchoolFinanceApp({super.key});

  @override
  State<SchoolFinanceApp> createState() => _SchoolFinanceAppState();
}

class _SchoolFinanceAppState extends State<SchoolFinanceApp>
    with WidgetsBindingObserver {
  bool _isCheckingBackup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutomaticBackup();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _checkAutomaticBackup();
    }
  }

  Future<void> _checkAutomaticBackup() async {
    if (_isCheckingBackup) {
      return;
    }

    _isCheckingBackup = true;
    try {
      await AutoBackupService.runDueBackup();
    } finally {
      _isCheckingBackup = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
    );
  }
}
