import 'package:app_school/model/Expenses.dart';
import 'package:app_school/model/category_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppDatabaseService {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpensesAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SessionsAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AccountAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CategoryAdapter());
    }

    if (!Hive.isBoxOpen('expenses')) {
      await Hive.openBox<Expenses>('expenses');
    }
    if (!Hive.isBoxOpen('sessions')) {
      await Hive.openBox<Sessions>('sessions');
    }
    if (!Hive.isBoxOpen('accounts')) {
      await Hive.openBox<Account>('accounts');
    }
    if (!Hive.isBoxOpen('categories')) {
      await Hive.openBox<Category>('categories');
    }
  }
}
