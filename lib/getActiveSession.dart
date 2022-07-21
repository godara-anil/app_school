import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

class getActiveSession {
  static  getSession() => Sess.getTransactions().values.where((Sessions) => Sessions.isActive == true)
      .toList().cast<Sessions>();
}