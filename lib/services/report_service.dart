import 'package:app_school/model/Expenses.dart';
import 'package:app_school/services/transaction_service.dart';

class ReportService {

  static double getTotalIncome(
      List<Expenses> transactions,
      ) {

    return TransactionService
        .getNetIncome(transactions);
  }

  static double getTotalExpense(
      List<Expenses> transactions,
      ) {

    return TransactionService
        .getNetExpense(transactions);
  }

  static double getNetBalance(
      List<Expenses> transactions,
      ) {

    return TransactionService
        .getNetBalance(transactions);
  }

  static Map<String, double>
  getCategoryWiseExpense(
      List<Expenses> transactions,
      ) {

    Map<String, double> data = {};

    for (var tx in transactions) {

      if (!tx.isExpense) continue;

      if (data.containsKey(tx.category)) {

        data[tx.category] =
            data[tx.category]! +
                tx.amount;

      } else {

        data[tx.category] =
            tx.amount;
      }
    }

    return data;
  }

  static Map<String, double>
  getCategoryWiseIncome(
      List<Expenses> transactions,
      ) {

    Map<String, double> data = {};

    for (var tx in transactions) {

      if (tx.isExpense) continue;

      if (data.containsKey(tx.category)) {

        data[tx.category] =
            data[tx.category]! +
                tx.amount;

      } else {

        data[tx.category] =
            tx.amount;
      }
    }

    return data;
  }
}