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
  static List<Expenses> getSessionTransactions(
    int sessionKey,
  ) {
    final transactions = Boxes.getTransactions()
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
    final transactions = Boxes.getTransactions()
        .values
        .where(
          (tx) => tx.sessionKey == sessionKey && tx.accountId == accountId,
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
    return transactions.fold<double>(
      0,
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
        if (!transaction.isExpense &&
            !isTransfer(transaction) &&
            !isOpeningBalance(transaction)) {
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
        if (transaction.isExpense &&
            !isTransfer(transaction) &&
            !isOpeningBalance(transaction)) {
          return previousValue + transaction.amount;
        }

        return previousValue;
      },
    );
  }

  static double getCashBalance(
    List<Expenses> transactions,
  ) {
    double cashBalance = 0;

    for (Expenses data in transactions) {
      final account =
          AccountsBox.getAccounts().get(int.tryParse(data.accountId));

      if (account == null) continue;

      final isCash = account.type.toLowerCase() == "cash";

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
          AccountsBox.getAccounts().get(int.tryParse(data.accountId));
      if (account == null) continue;
      final isCash = account.type.toLowerCase() == "cash";
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
    String? remarks1,
    String? remarks2,
  }) async {
    final transferId = DateTime.now().microsecondsSinceEpoch.toString();

    // Money leaving source account
    final expense = Expenses()
      ..amount = amount
      ..category = "Transfer"
      ..isExpense = true
      ..date = date
      ..sessionKey = sessionKey
      ..accountId = fromAccountId
      ..remarks = remarks2
      ..transferId = transferId;

    // Money entering destination account
    final income = Expenses()
      ..amount = amount
      ..category = "Transfer"
      ..isExpense = false
      ..date = date
      ..sessionKey = sessionKey
      ..accountId = toAccountId
      ..remarks = remarks1
      ..transferId = transferId;

    await Boxes.getTransactions().add(expense);
    await Boxes.getTransactions().add(income);
  }

  static Future<void> updateTransfer({
    required String transferId,
    required double amount,
    required DateTime date,
    required String fromAccountId,
    required String toAccountId,
    String? remarks,
  }) async {
    final pair = getTransferPair(transferId);
    if (pair == null) {
      throw StateError('Transfer pair not found.');
    }

    final source = pair.source;
    final destination = pair.destination;

    source
      ..amount = amount
      ..category = "Transfer"
      ..isExpense = true
      ..date = date
      ..accountId = fromAccountId
      ..remarks = _buildTransferRemarks(
        prefix: 'Transfer To',
        accountId: toAccountId,
        remarks: remarks,
      )
      ..transferId = transferId;

    destination
      ..amount = amount
      ..category = "Transfer"
      ..isExpense = false
      ..date = date
      ..accountId = toAccountId
      ..remarks = _buildTransferRemarks(
        prefix: 'Transfer From',
        accountId: fromAccountId,
        remarks: remarks,
      )
      ..transferId = transferId;

    await source.save();
    await destination.save();
  }

  static Future<void> deleteTransfer(
    String transferId,
  ) async {
    final pair = getTransferPair(transferId);
    if (pair == null) {
      throw StateError('Transfer pair not found.');
    }

    await Boxes.getTransactions().deleteAll(
      [
        pair.source.key,
        pair.destination.key,
      ],
    );
  }

  static TransferPair? getTransferPair(
    String transferId,
  ) {
    final entries = Boxes.getTransactions()
        .values
        .where(
          (tx) => tx.category == "Transfer" && tx.transferId == transferId,
        )
        .toList()
        .cast<Expenses>();

    if (entries.length != 2) {
      return null;
    }

    final sourceEntries = entries.where((tx) => tx.isExpense).toList();
    final destinationEntries = entries.where((tx) => !tx.isExpense).toList();

    if (sourceEntries.length != 1 || destinationEntries.length != 1) {
      return null;
    }

    return TransferPair(
      source: sourceEntries.single,
      destination: destinationEntries.single,
    );
  }

  static bool isTransfer(
    Expenses tx,
  ) {
    return tx.category == "Transfer";
  }

  static bool isOpeningBalance(
    Expenses tx,
  ) {
    return tx.category == "Opening Balance";
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

  static String _buildTransferRemarks({
    required String prefix,
    required String accountId,
    String? remarks,
  }) {
    final account = AccountsBox.getAccounts().get(
      int.tryParse(accountId),
    );
    final accountName = account?.name ?? accountId;
    final trimmedRemarks = remarks?.trim() ?? '';

    if (trimmedRemarks.isEmpty) {
      return '$prefix: $accountName';
    }

    return '$prefix: $accountName $trimmedRemarks';
  }
}

class TransferPair {
  final Expenses source;
  final Expenses destination;

  const TransferPair({
    required this.source,
    required this.destination,
  });
}
