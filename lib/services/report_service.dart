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
  static List<Map<String, dynamic>>
  getMonthlyReport(
      List<Expenses> transactions,
      ) {

    Map<String, Map<String, double>>
    monthlyData = {};

    for (var tx in transactions) {

      final monthKey =
          "${tx.date.year}-${tx.date.month}";

      if (!monthlyData.containsKey(
        monthKey,
      )) {

        monthlyData[monthKey] = {

          "income": 0,
          "expense": 0,
        };
      }

      if (tx.isExpense) {

        monthlyData[monthKey]!["expense"] =
            monthlyData[monthKey]!["expense"]! +
                tx.amount;

      } else {

        monthlyData[monthKey]!["income"] =
            monthlyData[monthKey]!["income"]! +
                tx.amount;
      }
    }

    List<Map<String, dynamic>> result =
    [];

    monthlyData.forEach(
          (month, data) {

        final income =
            data["income"] ?? 0;

        final expense =
            data["expense"] ?? 0;

        result.add({

          "month": month,

          "income": income,

          "expense": expense,

          "balance":
          income - expense,
        });
      },
    );

    result.sort(
          (a, b) =>
          b["month"].compareTo(
            a["month"],
          ),
    );

    return result;
  }
}