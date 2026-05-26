import 'package:flutter/material.dart';
import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/getActiveSession.dart';
import 'package:app_school/pages/account_ledger_page.dart';

class AccountSummaryPage extends StatelessWidget {
  const AccountSummaryPage({super.key});

  double calculateBalance(Account account) {

    final currentSession =
    getActiveSession.getSession();

    if (currentSession.isEmpty) {
      return 0;
    }

    final currentSessionKey =
        currentSession[0].key;

    final transactions =
    Boxes.getTransactions()
        .values
        .where(
          (tx) =>
      tx.sessionKey ==
          currentSessionKey,
    )
        .toList();

    double balance = account.openingBalance;

    for (var tx in transactions) {

      if (tx.accountId != account.key.toString()) {
        continue;
      }

      if (tx.isExpense) {
        balance -= tx.amount;
      } else {
        balance += tx.amount;
      }
    }

    return balance;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Accounts Summary"),
        backgroundColor: Colors.green,
      ),

      body: ValueListenableBuilder(
        valueListenable:
        AccountsBox.getAccounts().listenable(),

        builder: (context, box, _) {

          final accounts =
          box.values
              .where((a) => a.isActive)
              .toList()
              .cast<Account>();

          if (accounts.isEmpty) {

            return const Center(
              child: Text(
                "No accounts found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          double totalBalance = 0;

          for (var acc in accounts) {
            totalBalance += calculateBalance(acc);
          }

          return Column(

            children: [

              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  children: [

                    const Text(
                      "Total Balance",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "₹ ${totalBalance.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(

                  itemCount: accounts.length,

                  itemBuilder: (context, index) {

                    final account = accounts[index];

                    final balance =
                    calculateBalance(account);

                    return Card(

                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      child: ListTile(

                        leading: CircleAvatar(
                          backgroundColor: Colors.green,

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
                          "₹ ${balance.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: balance >= 0
                                ? Colors.green
                                : Colors.red,

                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AccountLedgerPage(
                                accountKey: account.key,
                              ),
                            ),
                          );

                        },
                      ),
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