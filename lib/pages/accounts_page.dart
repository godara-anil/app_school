import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({Key? key}) : super(key: key);

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {

  final nameController = TextEditingController();
  final openingBalanceController = TextEditingController();

  String selectedType = 'cash';

  final List<String> accountTypes = [
    'cash',
    'bank',
    'upi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: Colors.green,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          showAccountDialog();
        },
      ),

      body: ValueListenableBuilder(
        valueListenable: AccountsBox.getAccounts().listenable(),
        builder: (context, box, _) {

          final accounts = box.values.toList().cast<Account>();

          if(accounts.isEmpty) {
            return const Center(
              child: Text(
                'No Accounts Added',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {

              final account = accounts[index];

              final balance = getAccountBalance(account.id);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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

                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Text(
                        balance.toStringAsFixed(0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        account.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: account.isActive
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  onTap: () {
                    showAccountDialog(account: account);
                  },

                  onLongPress: () async {

                    final response = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                          'Are you sure you want to delete this account?',
                        ),
                        actions: [

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancel'),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if(response == true) {
                      account.delete();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showAccountDialog({Account? account}) {

    if(account != null) {
      nameController.text = account.name;
      openingBalanceController.text =
          account.openingBalance.toString();

      selectedType = account.type;
    }
    else {
      nameController.clear();
      openingBalanceController.clear();
      selectedType = 'cash';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(

        title: Text(
          account == null
              ? 'Add Account'
              : 'Edit Account',
        ),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: openingBalanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Opening Balance',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedType,

                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account Type',
                ),

                items: accountTypes.map((type) {

                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );

                }).toList(),

                onChanged: (value) {
                  selectedType = value!;
                },
              ),
            ],
          ),
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {

              final name = nameController.text.trim();

              final openingBalance =
                  double.tryParse(
                    openingBalanceController.text,
                  ) ?? 0;

              if(name.isEmpty) {
                return;
              }

              if(account == null) {

                final newAccount = Account()
                  ..id = DateTime.now()
                      .millisecondsSinceEpoch
                      .toString()
                  ..name = name
                  ..openingBalance = openingBalance
                  ..type = selectedType
                  ..isActive = true;

                AccountsBox.getAccounts().add(newAccount);

              }
              else {

                account.name = name;
                account.openingBalance = openingBalance;
                account.type = selectedType;

                account.save();
              }

              Navigator.pop(context);
            },

            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double getAccountBalance(String accountId) {

    final transactions =
    AccountsBox.getTransactions().values
            .where((e) => e.accountId == accountId)
            .toList();

    double balance = 0;

    for(final tx in transactions) {

      if(tx.isExpense) {
        balance -= tx.amount;
      }
      else {
        balance += tx.amount;
      }
    }

    final account =
              AccountsBox.getAccounts().values.firstWhere(
              (e) => e.id == accountId,
    );

    balance += account.openingBalance;

    return balance;
  }
}