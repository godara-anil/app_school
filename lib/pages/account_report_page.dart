import 'package:flutter/material.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

import 'package:app_school/services/account_service.dart';
import 'package:app_school/services/report_service.dart';

class AccountReportPage
    extends StatelessWidget {

  const AccountReportPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final accounts =
    AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Account Reports",
        ),

        backgroundColor:
        Colors.green,
      ),

      body: accounts.isEmpty

          ? const Center(
        child: Text(
          "No Accounts Found",
        ),
      )

          : ListView.builder(

        itemCount:
        accounts.length,

        itemBuilder:
            (context, index) {

          final account =
          accounts[index];

          final balance =
          AccountService
              .getAccountBalance(
            account,
          );

          return Card(

            margin:
            const EdgeInsets.symmetric(

              horizontal: 12,

              vertical: 6,
            ),

            child: ListTile(

              leading:
              CircleAvatar(

                backgroundColor:
                account.type
                    .toLowerCase() ==
                    "cash"

                    ? Colors.green

                    : Colors.blue,

                child: Text(

                  account.name[0]
                      .toUpperCase(),

                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                  ),
                ),
              ),

              title: Text(

                account.name,

                style:
                const TextStyle(

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Text(
                account.type
                    .toUpperCase(),
              ),

              trailing: Text(

                balance
                    .toStringAsFixed(
                  0,
                ),

                style:
                TextStyle(

                  fontWeight:
                  FontWeight.bold,

                  color:
                  balance >= 0

                      ? Colors.green

                      : Colors.red,
                ),
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        AccountLedgerPage(
                          account:
                          account,
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

class AccountLedgerPage
    extends StatelessWidget {

  final Account account;

  const AccountLedgerPage({
    Key? key,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final transactions =
    AccountService
        .getAccountTransactions(
      account.key.toString(),
    );

    final totalIncome =
    ReportService
        .getTotalIncome(
      transactions,
    );

    final totalExpense =
    ReportService
        .getTotalExpense(
      transactions,
    );

    final balance =
    AccountService
        .getAccountBalance(
      account,
    );

    return Scaffold(

      appBar: AppBar(

        title: Text(
          account.name,
        ),

        backgroundColor:
        Colors.green,
      ),

      body: Column(

        children: [

          Container(

            padding:
            const EdgeInsets.all(
              16,
            ),

            color:
            Colors.green
                .withOpacity(
              0.08,
            ),

            child: Column(

              children: [

                buildSummaryRow(

                  "Opening Balance",

                  account
                      .openingBalance
                      .toStringAsFixed(
                    0,
                  ),
                ),

                buildSummaryRow(

                  "Total Income",

                  totalIncome
                      .toStringAsFixed(
                    0,
                  ),
                ),

                buildSummaryRow(

                  "Total Expense",

                  totalExpense
                      .toStringAsFixed(
                    0,
                  ),
                ),

                const Divider(),

                buildSummaryRow(

                  "Current Balance",

                  balance
                      .toStringAsFixed(
                    0,
                  ),

                  isBold: true,
                ),
              ],
            ),
          ),

          Expanded(

            child:
            transactions.isEmpty

                ? const Center(
              child: Text(
                "No Transactions",
              ),
            )

                : ListView.builder(

              itemCount:
              transactions.length,

              itemBuilder:
                  (context, index) {

                final tx =
                transactions[index];

                return Card(

                  margin:
                  const EdgeInsets.symmetric(

                    horizontal: 10,

                    vertical: 4,
                  ),

                  child: ListTile(

                    leading: CircleAvatar(

                      backgroundColor:
                      tx.isExpense

                          ? Colors.red

                          : Colors.green,

                      child: Icon(

                        tx.isExpense

                            ? Icons
                            .arrow_upward

                            : Icons
                            .arrow_downward,

                        color:
                        Colors.white,
                      ),
                    ),

                    title: Text(
                      tx.category,
                    ),

                    subtitle: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          tx.remarks ??
                              "",
                        ),

                        Text(
                          tx.date
                              .toString()
                              .substring(
                            0,
                            10,
                          ),
                        ),
                      ],
                    ),

                    trailing: Text(

                      tx.amount
                          .toStringAsFixed(
                        0,
                      ),

                      style: TextStyle(

                        fontWeight:
                        FontWeight.bold,

                        color:
                        tx.isExpense

                            ? Colors.red

                            : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(

      String title,
      String value, {
        bool isBold = false,
      }) {

    return Padding(

      padding:
      const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(

        mainAxisAlignment:
        MainAxisAlignment
            .spaceBetween,

        children: [

          Text(

            title,

            style: TextStyle(

              fontWeight:
              isBold

                  ? FontWeight.bold

                  : FontWeight.normal,
            ),
          ),

          Text(

            value,

            style: TextStyle(

              fontWeight:
              isBold

                  ? FontWeight.bold

                  : FontWeight.normal,

              fontSize:
              isBold ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}