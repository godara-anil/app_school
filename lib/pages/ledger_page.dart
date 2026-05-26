import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/services/account_service.dart';
import 'package:app_school/getActiveSession.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({Key? key}) : super(key: key);

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {

  int currentSessionKey = 0;

  @override
  void initState() {
    super.initState();

    final currentSession = getActiveSession.getSession();

    if (currentSession.isNotEmpty) {
      currentSessionKey = currentSession[0].key;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ledger"),
        backgroundColor: Colors.green,
      ),

      body: ValueListenableBuilder(
        valueListenable: Boxes.getTransactions().listenable(),

        builder: (context, box, _) {

          final transactions = box.values
              .where((e) => e.sessionKey == currentSessionKey)
              .toList()
              .cast<Expenses>();

          transactions.sort(
                  (a, b) => b.date.compareTo(a.date));

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No Transactions Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          double runningBalance = 0;

          List<Widget> ledgerTiles = [];

          for (var transaction in transactions.reversed) {

            if (transaction.isExpense) {
              runningBalance -= transaction.amount;
            } else {
              runningBalance += transaction.amount;
            }

            ledgerTiles.add(
              buildLedgerTile(
                transaction,
                runningBalance,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: ledgerTiles.reversed.toList(),
          );
        },
      ),
    );
  }

  Widget buildLedgerTile(
      Expenses transaction,
      double runningBalance,
      ) {

    final isExpense = transaction.isExpense;

    final amountColor =
    isExpense ? Colors.red : Colors.green;

    final accountName =
    AccountService.getAccountName(
      transaction.accountId,
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                Expanded(
                  child: Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  "${isExpense ? "-" : "+"}${transaction.amount.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  DateFormat.yMMMd()
                      .format(transaction.date),
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius:
                    BorderRadius.circular(8),
                  ),

                  child: Text(
                    accountName,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  "Running Balance",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  runningBalance
                      .toStringAsFixed(0),

                  style: TextStyle(
                    color: runningBalance >= 0
                        ? Colors.green
                        : Colors.red,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (transaction.remarks != null &&
                transaction.remarks!.isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.only(top: 10),

                child: Text(
                  "Remarks: ${transaction.remarks!}",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}