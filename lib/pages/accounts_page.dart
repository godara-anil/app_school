import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/services/transaction_service.dart';
import 'package:app_school/services/session_service.dart';
import 'package:app_school/widget/transfer_dialog.dart';



class AccountsPage extends StatefulWidget {
  const AccountsPage({Key? key}) : super(key: key);

  @override
  State<AccountsPage> createState() =>
      _AccountsPageState();
}

class _AccountsPageState
    extends State<AccountsPage> {

  final nameController =
  TextEditingController();

  final openingBalanceController =
  TextEditingController();

  String selectedType = 'cash';

  final List<String> accountTypes = [

    'cash',

    'bank',

    'upi',

    'card',

    'other',
  ];

  @override
  void dispose() {

    nameController.dispose();

    openingBalanceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Accounts',
        ),

        backgroundColor:
        Colors.green,

        actions: [

          IconButton(

            icon: const Icon(
              Icons.swap_horiz,
            ),

            onPressed: () {

              showDialog(

                context: context,

                builder: (_) =>
                const TransferDialog(),
              );
            },
          ),
        ],
      ),

      floatingActionButton:
      FloatingActionButton(

        backgroundColor:
        Colors.green,

        child: const Icon(
          Icons.add,
        ),

        onPressed: () {

          showAccountDialog();
        },
      ),

      body:
      ValueListenableBuilder(
        valueListenable:
        AccountsBox
            .getAccounts()
            .listenable(),
        builder:
            (context, box, _) {
              return ValueListenableBuilder(

                valueListenable:
                Boxes.getTransactions()
                    .listenable(),
                builder: (
                    context,
                    transactionBox,
                    __,
                    ) {
                  final accounts =
                  box.values
                      .toList()
                      .cast<Account>();
                  if (accounts.isEmpty) {
                    return const Center(

                      child: Text(

                        'No Accounts Added',

                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(

                    itemCount:
                    accounts.length,

                    itemBuilder:
                        (context, index) {
                      final account =
                      accounts[index];

                      final balance =
                      getAccountBalance(
                        account.key.toString(),
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

                          subtitle: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              Text(
                                account.type
                                    .toUpperCase(),
                              ),

                              Text(

                                account.isActive

                                    ? "Active"

                                    : "Inactive",

                                style: TextStyle(

                                  color:
                                  account.isActive

                                      ? Colors.green

                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),

                          trailing: Text(

                            balance
                                .toStringAsFixed(
                              0,
                            ),

                            style:
                            TextStyle(

                              fontSize: 18,

                              fontWeight:
                              FontWeight.bold,

                              color:
                              balance >= 0

                                  ? Colors.green

                                  : Colors.red,
                            ),
                          ),

                          onTap: () {
                            showAccountDialog(
                              account: account,
                            );
                          },
                          onLongPress: () async {
                            final confirm =
                            await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Delete Account",
                                  ),
                                  content:
                                  const Text(
                                    "Are you sure you want to delete this account?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          false,
                                        );
                                      },
                                      child:
                                      const Text(
                                        "Cancel",
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          true,
                                        );
                                      },
                                      child:
                                      const Text(
                                        "Delete",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm == true) {
                              final hasTransactions =
                              Boxes
                                  .getTransactions()
                                  .values
                                  .any((tx) =>
                              tx.accountId == account.key.toString(),);
                              if (hasTransactions) {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      AlertDialog(
                                        title: const Text(
                                          "Cannot Delete Account",
                                        ),
                                        content: const Text(
                                          "This account contains transactions.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      ),
                                );
                                return;
                                await account.delete();
                              }
                            };
                          },
                        ),
                      );
                    },
                  );
                },
              );
        },
      ),
    );
  }

  void showAccountDialog({
    Account? account,
  }) {

    if (account != null) {

      nameController.text =
          account.name;

      openingBalanceController
          .text =
          account.openingBalance
              .toString();

      selectedType =
          account.type;
    }
    else {

      nameController.clear();

      openingBalanceController
          .clear();

      selectedType = 'cash';
    }

    showDialog(

      context: context,

      builder:
          (context) {

        return AlertDialog(

          title: Text(

            account == null

                ? "Add Account"

                : "Edit Account",
          ),

          content:
          SingleChildScrollView(

            child: Column(

              mainAxisSize:
              MainAxisSize.min,

              children: [

                TextField(

                  controller:
                  nameController,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Account Name",

                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(

                  controller:
                  openingBalanceController,

                  keyboardType:
                  TextInputType.number,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Opening Balance",

                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                DropdownButtonFormField<String>(

                  value:
                  selectedType,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Account Type",

                    border:
                    OutlineInputBorder(),
                  ),

                  items:
                  accountTypes.map(
                        (type) {

                      return DropdownMenuItem(

                        value: type,

                        child: Text(
                          type
                              .toUpperCase(),
                        ),
                      );
                    },
                  ).toList(),

                  onChanged:
                      (value) {

                    selectedType =
                    value!;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                if (account != null)

                  SwitchListTile(

                    value:
                    account.isActive,

                    title: const Text(
                      "Active",
                    ),

                    onChanged:
                        (value) {

                      setState(() {

                        account.isActive =
                            value;
                      });
                    },
                  ),
              ],
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child:
              const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(

              onPressed: () async {

                final name =
                nameController.text
                    .trim();

                final openingBalance =
                    double.tryParse(
                      openingBalanceController
                          .text,
                    ) ??
                        0;

                if (name.isEmpty) {
                  return;
                }

                if (account == null) {

                  final newAccount =
                  Account(

                    name: name,

                    openingBalance:
                    0,

                    type:
                    selectedType,
                  );
                  await AccountsBox
                      .getAccounts()
                      .add(newAccount);
                  await SessionService
                      .ensureOpeningBalanceCategory();

                  if(openingBalance != 0){
                    final tx = Expenses()
                      ..amount = openingBalance
                      ..isExpense = false
                      ..date = DateTime.now()
                      ..category = "Opening Balance"
                      ..sessionKey =
                      SessionService.getActiveSessionKey()
                      ..accountId =
                      newAccount.key.toString()
                      ..remarks =
                          "Opening Balance";
                    await Boxes
                        .getTransactions()
                        .add(tx);
                  }
                }
                else {
                  account.name =
                      name;
                  account.openingBalance =
                      0;
                  account.type =
                      selectedType;
                  await account
                      .save();
                }

                Navigator.pop(
                  context,
                );
              },

              child:
              const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  double getAccountBalance(
      String accountId,
      ) {

    final activeSessionKey =
    SessionService
        .getActiveSessionKey();

    final transactions =
    Boxes.getTransactions()
        .values
        .where(
          (e) =>
      e.accountId ==
          accountId &&
          e.sessionKey ==
              activeSessionKey,
    )
        .toList();

    double balance = 0;

    for (final tx in transactions) {

      if (tx.isExpense) {

        balance -= tx.amount;

      } else {

        balance += tx.amount;
      }
    }

    final account =
    AccountsBox
        .getAccounts()
        .values
        .firstWhere(
          (e) =>
      e.key.toString() ==
          accountId,
    );

    // balance += account.openingBalance;

    return balance;
  }
}