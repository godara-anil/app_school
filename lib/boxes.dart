import 'package:hive/hive.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/model/category_model.dart';
class Boxes {
  static Box<Expenses> getTransactions() =>
      Hive.box<Expenses>('expenses');
}
class Sess {
  static Box<Sessions> getTransactions() =>
      Hive.box<Sessions>('sessions');
}
class AccountsBox {
  static Box<Account> getAccounts() =>
      Hive.box<Account>('accounts');
}
class CategoryBox {
  static Box<Category> getCategories() =>
      Hive.box<Category>('categories');
}