import 'package:hive/hive.dart';
import 'package:app_school/model/Expenses.dart';
class Boxes {
  static Box<Expenses> getTransactions() =>
      Hive.box<Expenses>('expenses');
}
class Sess {
  static Box<Sessions> getTransactions() =>
      Hive.box<Sessions>('sessions');
}