import 'package:app_school/model/Expenses.dart';
import 'package:app_school/boxes.dart';


class AccountService {

  static double getAccountBalance(Account account) {

    final transactions = Boxes.getTransactions().values
        .where((e) => e.accountId == account.key.toString());

    double balance = account.openingBalance;

    for (var t in transactions) {
      if (t.isExpense) {
        balance -= t.amount;
      } else {
        balance += t.amount;
      }
    }

    return balance;
  }

  static String getAccountName(String accountId) {

    final key = int.tryParse(accountId);

    if (key == null) {
      return accountId;
    }

    final account =
    AccountsBox.getAccounts().get(key);

    if (account == null) {
      return "Unknown";
    }

    return account.name;
  }

  static List<Account> getActiveAccounts() {

    return AccountsBox
        .getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();
  }

  static double getTotalCashBalance() {

    final accounts =
    getActiveAccounts()
        .where(
          (a) =>
      a.type.toLowerCase() ==
          "cash",
    );

    double total = 0;

    for (var account in accounts) {

      total +=
          getAccountBalance(account);
    }

    return total;
  }

  static double getTotalBankBalance() {

    final accounts =
    getActiveAccounts()
        .where(
          (a) =>
      a.type.toLowerCase() ==
          "bank",
    );

    double total = 0;

    for (var account in accounts) {

      total +=
          getAccountBalance(account);
    }

    return total;
  }

  static List<Expenses>  getAccountTransactions(String accountId,) {

    return Boxes.getTransactions()
        .values
        .where(
          (e) =>
      e.accountId ==
          accountId,
    )
        .toList()
        .cast<Expenses>();
  }
}