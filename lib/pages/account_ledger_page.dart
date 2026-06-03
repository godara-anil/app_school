import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/getActiveSession.dart';
import 'package:app_school/widget/transaction_tile.dart';
import 'package:app_school/services/transaction_service.dart';

class AccountLedgerPage extends StatefulWidget {

  final int accountKey;

  const AccountLedgerPage({
    Key? key,
    required this.accountKey,
  }) : super(key: key);

  @override
  State<AccountLedgerPage> createState() =>
      _AccountLedgerPageState();
}
class _AccountLedgerPageState
    extends State<AccountLedgerPage> {

  int currentSessionKey = 0;

  @override
  void initState() {
    super.initState();

    final currentSession =
    getActiveSession.getSession();

    if (currentSession.isNotEmpty) {
      currentSessionKey =
          currentSession[0].key;
    }
  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Account Ledger"),
        backgroundColor: Colors.green,

      ),

      body: ValueListenableBuilder(

        valueListenable:
        Boxes.getTransactions().listenable(),

        builder: (context, box, _) {

          final account =
          AccountsBox.getAccounts()
              .get(widget.accountKey);

          if (account == null) {
            return const Center(
              child: Text("Account not found"),
            );
          }

          final transactions =
          TransactionService.getAccountTransactions(
            sessionKey: currentSessionKey,
            accountId: account.key.toString(),
          );

          final balance =
          TransactionService.getAccountBalance(
            openingBalance:
            account.openingBalance,
            transactions: transactions,
          );

          return Column(
            children: [

              Card(
                margin:
                const EdgeInsets.all(12),

                child: ListTile(

                  title: Text(
                    account.name,

                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,

                      fontSize: 20,
                    ),
                  ),

                  subtitle: Text(
                    account.type.toUpperCase(),
                  ),

                  trailing: Column(

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    crossAxisAlignment:
                    CrossAxisAlignment.end,

                    children: [

                      const Text("Balance"),

                      Text(
                        balance.toStringAsFixed(0),

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,

                          color:
                          balance >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(

                child: transactions.isEmpty

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

                    final transaction =
                    transactions[index];
                    return TransactionTile(
                      transaction: transaction,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}