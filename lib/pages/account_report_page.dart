import 'package:flutter/material.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

import 'package:app_school/services/account_service.dart';
import 'package:app_school/services/report_service.dart';
import 'package:app_school/services/pdf_service.dart';
import 'package:app_school/services/session_service.dart';
import 'package:app_school/services/transaction_service.dart';
import 'package:app_school/widget/addExpensesDialog.dart';
import 'package:app_school/widget/transfer_dialog.dart';
import 'package:intl/intl.dart';

class AccountReportPage extends StatelessWidget {
  const AccountReportPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accounts = AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account Reports",
        ),
        backgroundColor: Colors.green,
      ),
      body: accounts.isEmpty
          ? const Center(
              child: Text(
                "No Accounts Found",
              ),
            )
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];

                final balance = AccountService.getAccountBalance(
                  account,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: account.type.toLowerCase() == "cash"
                          ? Colors.green
                          : Colors.blue,
                      child: Text(
                        account.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      account.type.toUpperCase(),
                    ),
                    trailing: Text(
                      balance.toStringAsFixed(
                        0,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountLedgerPage(
                            account: account,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AccountLedgerPage extends StatefulWidget {
  final Account account;

  const AccountLedgerPage({
    Key? key,
    required this.account,
  }) : super(key: key);

  @override
  State<AccountLedgerPage> createState() => _AccountLedgerPageState();
}

class _AccountLedgerPageState extends State<AccountLedgerPage> {
  DateTimeRange? selectedRange;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final transactions = AccountService.getAccountTransactions(
      widget.account.key.toString(),
    );
    final filteredTransactions = (selectedRange == null
            ? transactions
            : transactions.where((tx) {
                final txDate = DateTime(
                  tx.date.year,
                  tx.date.month,
                  tx.date.day,
                );

                return !txDate.isBefore(
                      selectedRange!.start,
                    ) &&
                    !txDate.isAfter(
                      selectedRange!.end,
                    );
              }).toList())
        .where((tx) {
      if (searchText.isEmpty) {
        return true;
      }

      final search = searchText.toLowerCase();

      return tx.category.toLowerCase().contains(search) ||
          (tx.remarks ?? '').toLowerCase().contains(search) ||
          tx.amount.toString().contains(search);
    }).toList();
    filteredTransactions.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    final totalIncome = ReportService.getTotalIncome(
      filteredTransactions,
    );

    final totalExpense = ReportService.getTotalExpense(
      filteredTransactions,
    );
    final transferBalance = ReportService.getTransferBalance(
      filteredTransactions,
    );

    final openingBalance = transactions
        .where(
          (t) => t.category == "Opening Balance",
        )
        .fold<double>(
          0,
          (sum, tx) => tx.isExpense ? sum - tx.amount : sum + tx.amount,
        );
    final balance =
        openingBalance + totalIncome + transferBalance - totalExpense;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.account.name),
            Text(
              selectedRange == null
                  ? "01 Apr ${DateTime.now().year} → Today"
                  : "${DateFormat('d MMM yyyy').format(selectedRange!.start)} → ${DateFormat('d MMM yyyy').format(selectedRange!.end)}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );

              if (range != null) {
                setState(() {
                  selectedRange = range;
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'pdf') {
                exportPdf();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Text('Export PDF'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(
              16,
            ),
            color: Colors.green.withOpacity(
              0.08,
            ),
            child: Column(
              children: [
                buildSummaryRow(
                  "Opening Balance",
                  openingBalance.toStringAsFixed(0),
                ),
                buildSummaryRow(
                  "Total Income",
                  totalIncome.toStringAsFixed(0),
                ),
                buildSummaryRow(
                  "Total Expense",
                  totalExpense.toStringAsFixed(0),
                ),
                buildSummaryRow(
                  "Transfer Balance",
                  transferBalance >= 0
                      ? "+${transferBalance.toStringAsFixed(0)}"
                      : transferBalance.toStringAsFixed(0),
                ),
                const Divider(),
                buildSummaryRow(
                  "Current Balance",
                  balance.toStringAsFixed(
                    0,
                  ),
                  isBold: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text(
                      "No Transactions",
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      double balanceTillHere = 0;
                      for (int i = 0; i <= index; i++) {
                        final txn = filteredTransactions[i];

                        if (txn.category == "Transfer") {
                          if (txn.isExpense) {
                            balanceTillHere -= txn.amount;
                          } else {
                            balanceTillHere += txn.amount;
                          }
                        } else {
                          if (txn.isExpense) {
                            balanceTillHere -= txn.amount;
                          } else {
                            balanceTillHere += txn.amount;
                          }
                        }
                      }
                      final tx = filteredTransactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                tx.isExpense ? Colors.red : Colors.green,
                            child: Icon(
                              tx.isExpense
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            tx.category,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.remarks ?? "",
                              ),
                              Text(
                                tx.date.toString().substring(
                                      0,
                                      10,
                                    ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                tx.amount.toStringAsFixed(0),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      tx.isExpense ? Colors.red : Colors.green,
                                ),
                              ),
                              Text(
                                "Bal: ${balanceTillHere.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (tx.category == 'Transfer') {
                              if (tx.transferId == null) {
                                showOldTransferMessage();
                                return;
                              }

                              await showDialog(
                                context: context,
                                builder: (context) => TransferDialog(
                                  transferId: tx.transferId,
                                ),
                              );
                              setState(() {});
                              return;
                            }

                            await showDialog(
                              context: context,
                              builder: (context) => AddExpenseDialog(
                                expenses: tx,
                                onClickDone: (amount, name, isExpense, date,
                                        accountId, remarks) =>
                                    TransactionService.updateTransaction(
                                  expense: tx,
                                  amount: amount,
                                  category: name,
                                  isExpense: isExpense,
                                  date: date,
                                  accountId: accountId,
                                  remarks: remarks,
                                ),
                              ),
                            );
                            setState(() {});
                          },
                          onLongPress: () async {
                            if (tx.category == 'Transfer') {
                              if (tx.transferId == null) {
                                showOldTransferMessage();
                                return;
                              }

                              if (SessionService.getActiveSessionLockStatus()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      SessionService.lockedMessage,
                                    ),
                                  ),
                                );
                                return;
                              }

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    'Delete Transfer',
                                  ),
                                  content: const Text(
                                    'Delete both linked transfer entries?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        false,
                                      ),
                                      child: const Text(
                                        'Cancel',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        true,
                                      ),
                                      child: const Text(
                                        'Delete',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (!context.mounted) return;
                              if (confirm == true) {
                                try {
                                  await TransactionService.deleteTransfer(
                                      tx.transferId!);
                                  if (!context.mounted) return;
                                  setState(() {});
                                } on StateError {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Transfer could not be deleted because its linked entry is missing.',
                                      ),
                                    ),
                                  );
                                }
                              }
                              return;
                            }
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Delete Transaction',
                                ),
                                content: Text(
                                  'Delete "${tx.category}" transaction?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      false,
                                    ),
                                    child: const Text(
                                      'Cancel',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      true,
                                    ),
                                    child: const Text(
                                      'Delete',
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (!context.mounted) return;
                            if (confirm == true) {
                              await TransactionService.deleteTransaction(tx);
                              setState(() {});
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void showOldTransferMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Old transfer entries cannot be edited. Please create a new transfer if changes are required.',
        ),
      ),
    );
  }

  Widget buildSummaryRow(
    String title,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> exportPdf() async {
    final transactions = AccountService.getAccountTransactions(
      widget.account.key.toString(),
    );
    final filteredTransactions = (selectedRange == null
            ? transactions
            : transactions.where((tx) {
                final txDate = DateTime(
                  tx.date.year,
                  tx.date.month,
                  tx.date.day,
                );

                return !txDate.isBefore(
                      selectedRange!.start,
                    ) &&
                    !txDate.isAfter(
                      selectedRange!.end,
                    );
              }).toList())
        .where((tx) {
      if (searchText.isEmpty) {
        return true;
      }

      final search = searchText.toLowerCase();

      return tx.category.toLowerCase().contains(search) ||
          (tx.remarks ?? '').toLowerCase().contains(search) ||
          tx.amount.toString().contains(search);
    }).toList();
    final totalIncome = ReportService.getTotalIncome(
      filteredTransactions,
    );

    final totalExpense = ReportService.getTotalExpense(
      filteredTransactions,
    );

    final transferBalance = ReportService.getTransferBalance(
      filteredTransactions,
    );

    final balance = AccountService.getAccountBalance(
      widget.account,
    );
    final openingBalance = transactions
        .where(
          (t) => t.category == "Opening Balance",
        )
        .fold<double>(
          0,
          (sum, tx) => tx.isExpense ? sum - tx.amount : sum + tx.amount,
        );
    await PdfService.exportAccountLedger(
      accountName: widget.account.name,
      sessionName: SessionService.getActiveSession().session,
      openingBalance: openingBalance,
      totalIncome: totalIncome - openingBalance,
      totalExpense: totalExpense,
      transferBalance: transferBalance,
      currentBalance: balance,
      transactions: filteredTransactions,
    );
  }
}
