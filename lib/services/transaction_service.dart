import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

class TransactionService {
  // ADD TRANSACTION
  static Future<void> addTransaction({
    required double amount,
    required String category,
    required bool isExpense,
    required DateTime date,
    required int sessionKey,
    required String accountId,
    String? remarks,
  }) async {

    final expense = Expenses()

      ..amount = amount
      ..category = category
      ..isExpense = isExpense
      ..date = date
      ..sessionKey = sessionKey
      ..accountId = accountId
      ..remarks = remarks;

    await Boxes.getTransactions().add(expense);
  }

  // UPDATE TRANSACTION
  static Future<void> updateTransaction({
    required Expenses expense,
    required double amount,
    required String category,
    required bool isExpense,
    required DateTime date,
    required String accountId,
    String? remarks,
  }) async {

    expense
      ..amount = amount
      ..category = category
      ..isExpense = isExpense
      ..date = date
      ..accountId = accountId
      ..remarks = remarks;

    await expense.save();
  }

  // DELETE TRANSACTION
  static Future<void> deleteTransaction(
      Expenses expense,
      ) async {

    await expense.delete();
  }

  // GET SESSION TRANSACTIONS
  static List<Expenses> getSessionTransactions(int sessionKey,) {

    final transactions =
    Boxes.getTransactions()
        .values
        .where(
          (tx) => tx.sessionKey == sessionKey,
    )
        .toList()
        .cast<Expenses>();

    transactions.sort(
          (b, a) => a.date.compareTo(b.date),
    );

    return transactions;
  }

  // GET ACCOUNT TRANSACTIONS
  static List<Expenses> getAccountTransactions({
    required int sessionKey,
    required String accountId,
  }) {

    final transactions =
    Boxes.getTransactions()
        .values
        .where(
          (tx) =>
      tx.sessionKey == sessionKey &&
          tx.accountId == accountId,
    )
        .toList()
        .cast<Expenses>();

    transactions.sort(
          (b, a) => a.date.compareTo(b.date),
    );

    return transactions;
  }

  // GET INCOME TRANSACTIONS
  static List<Expenses> getIncomeTransactions(
      int sessionKey,
      ) {

    return getSessionTransactions(sessionKey)
        .where((tx) => !tx.isExpense && isTransfer(tx))
        .toList();
  }

  // GET EXPENSE TRANSACTIONS
  static List<Expenses> getExpenseTransactions(
      int sessionKey,
      ) {

    return getSessionTransactions(sessionKey)
        .where((tx) => tx.isExpense && isTransfer(tx))
        .toList();
  }

  static double getNetBalance(
      List<Expenses> transactions,
      ) {

    return transactions.fold<double>( 0,
          (previousValue, transaction) {
        if (isTransfer(transaction)) {
          return previousValue;
        }
        if (transaction.isExpense) {
          return previousValue - transaction.amount;
        }

        return previousValue + transaction.amount;
      },
    );
  }

  static double getNetIncome(
      List<Expenses> transactions,
      ) {

    return transactions.fold<double>(
      0,
          (previousValue, transaction) {

        if (!transaction.isExpense && !isTransfer(transaction)) {
          return previousValue + transaction.amount;
        }

        return previousValue;
      },
    );
  }

  static double getNetExpense(
      List<Expenses> transactions,
      ) {

    return transactions.fold<double>(
      0,
          (previousValue, transaction) {

        if (transaction.isExpense && !isTransfer(transaction)) {
          return previousValue + transaction.amount;
        }

        return previousValue;
      },
    );
  }

  static double getCashBalance(List<Expenses> transactions,) {

    double cashBalance = 0;

    for (Expenses data in transactions) {

      final account =
      AccountsBox.getAccounts()
          .get(int.tryParse(data.accountId));

      if (account == null) continue;

      final isCash =
          account.type.toLowerCase() == "cash";

      if (!isCash) continue;

      if (data.isExpense) {
        cashBalance -= data.amount;
      } else {
        cashBalance += data.amount;
      }
    }

    return cashBalance;
  }

  static double getBankBalance(
      List<Expenses> transactions,
      ) {

    double bankBalance = 0;

    for (Expenses data in transactions) {

      final account =
      AccountsBox.getAccounts()
          .get(int.tryParse(data.accountId));

      if (account == null) continue;

      final isCash =
          account.type.toLowerCase() == "cash";

      if (isCash) continue;

      if (data.isExpense) {
        bankBalance -= data.amount;
      } else {
        bankBalance += data.amount;
      }
    }

    return bankBalance;
  }
  static List<Expenses> getTransactionsBySession(
      int sessionKey,
      ) {

    final transactions = Boxes.getTransactions()
        .values
        .where(
          (e) => e.sessionKey == sessionKey,
    )
        .toList()
        .cast<Expenses>();

    transactions.sort(
          (b, a) => a.date.compareTo(b.date),
    );

    return transactions;
  }

  static double getAccountBalance({
    required double openingBalance,
    required List<Expenses> transactions,
  }) {

    double balance = openingBalance;

    for (var transaction in transactions) {

      if (transaction.isExpense) {
        balance -= transaction.amount;
      } else {
        balance += transaction.amount;
      }
    }

    return balance;
  }

  // TRANSFER BETWEEN ACCOUNTS
  static Future<void> transferTransaction({
    required double amount,
    required DateTime date,
    required int sessionKey,
    required String fromAccountId,
    required String toAccountId,
    String? remarks,
  }) async {

    // Money leaving source account
    final expense = Expenses()
      ..amount = amount
      ..category = "Transfer"
      ..isExpense = true
      ..date = date
      ..sessionKey = sessionKey
      ..accountId = fromAccountId
      ..remarks = remarks;

    // Money entering destination account
    final income = Expenses()
      ..amount = amount
      ..category = "Transfer"
      ..isExpense = false
      ..date = date
      ..sessionKey = sessionKey
      ..accountId = toAccountId
      ..remarks = remarks;

    await Boxes.getTransactions().add(expense);
    await Boxes.getTransactions().add(income);
  }

  static bool isTransfer(
      Expenses tx,
      ) {
    return tx.category == "Transfer";
  }

  static double getNetTransferBalance(
      List<Expenses> transactions,
      ) {
    double transferBalance = 0;

    for (final tx in transactions) {

      if (tx.category != "Transfer") {
        continue;
      }

      if (tx.isExpense) {
        transferBalance -= tx.amount;
      } else {
        transferBalance += tx.amount;
      }
    }

    return transferBalance;
  }
}