import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

import 'package:app_school/services/session_service.dart';
import 'package:app_school/services/transaction_service.dart';

class TransferDialog
    extends StatefulWidget {

  const TransferDialog({
    Key? key,
  }) : super(key: key);
  @override
  State<TransferDialog> createState() =>
      _TransferDialogState();
}

class _TransferDialogState
    extends State<TransferDialog> {
  @override
  void initState() {

    super.initState();

    final accounts =
    AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    if (accounts.length >= 2) {

      fromAccount = accounts[0];

      toAccount = accounts[1];
    }
  }
  final amountController =
  TextEditingController();

  final remarksController =
  TextEditingController();

  DateTime date =
  DateTime.now();

  Account? fromAccount;

  Account? toAccount;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text(
        "Transfer Amount",
      ),

      content: SingleChildScrollView(

        child: Column(

          mainAxisSize:
          MainAxisSize.min,

          children: [

            buildFromAccount(),

            const SizedBox(height: 10),

            buildToAccount(),

            const SizedBox(height: 10),

            buildAmount(),

            const SizedBox(height: 10),

            buildRemarks(),

            const SizedBox(height: 10),

            buildDate(),
            const SizedBox(height: 10),
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

          onPressed:
          saveTransfer,

          child:
          const Text(
            "Transfer",
          ),
        ),
      ],
    );
  }

  Widget buildFromAccount() {

    final accounts =
    AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();
    return DropdownButtonFormField<Account>(

      value: fromAccount,

      decoration: const InputDecoration(

        labelText: "From Account",

        border: OutlineInputBorder(),
      ),

      items: accounts.map((account) {

        return DropdownMenuItem(

          value: account,

          child: Text(account.name),
        );

      }).toList(),

      onChanged: (value) {

        setState(() {

          fromAccount = value;
        });
      },
    );
  }
  Widget buildToAccount() {

    final accounts =
    AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    return DropdownButtonFormField<Account>(

      value: toAccount,

      decoration: const InputDecoration(

        labelText: "To Account",

        border: OutlineInputBorder(),
      ),

      items: accounts.map((account) {

        return DropdownMenuItem(
            value : account,
          child: Text(account.name),
        );

      }).toList(),

      onChanged: (value) {

        setState(() {
          toAccount = value;
        });
      },
    );
  }
  Widget buildAmount() {

    return TextFormField(

      controller:
      amountController,

      keyboardType:
      TextInputType.number,

      decoration:
      const InputDecoration(

        labelText: "Amount",

        border:
        OutlineInputBorder(),
      ),
    );
  }
  Widget buildRemarks() {

    return TextFormField(

      controller:
      remarksController,

      decoration:
      const InputDecoration(

        labelText: "Remarks",

        border:
        OutlineInputBorder(),
      ),
    );
  }
  Widget buildDate() {

    return Row(

      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

      children: [

        Text(
          DateFormat
              .yMMMd()
              .format(date),
        ),

        IconButton(

          icon: const Icon(
            Icons.calendar_month,
          ),

          onPressed: () async {

            final selected =
            await showDatePicker(

              context: context,

              initialDate: date,

              firstDate:
              DateTime(2020),

              lastDate:
              DateTime.now(),
            );

            if (selected == null) {
              return;
            }

            setState(() {

              date = selected;
            });
          },
        ),
      ],
    );
  }
  Future<void>  saveTransfer() async {
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
    final amount =
    double.tryParse(
      amountController.text,
    );

    if (amount == null ||
        amount <= 0) {
      showError(
        "Enter valid amount",
      );
      return;
    }

    if (fromAccount == null ||
        toAccount == null) {
      showError(
        "Select accounts",
      );
      return;
    }

    if (fromAccount!.key ==
        toAccount!.key) {
      showError(
        "Accounts must be different",
      );
      return;
    }
    await TransactionService
        .transferTransaction(

      amount: amount,

      date: date,

      sessionKey:
      SessionService
          .getActiveSessionKey(),

      fromAccountId:
      fromAccount!
          .key
          .toString(),

      toAccountId:
      toAccount!
          .key
          .toString(),

      remarks:
      remarksController.text,
    );

    if (!mounted) return;

    Navigator.pop(
      context,
    );
  }
  void showError(
      String message,
      ) {

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(
        content:
        Text(message),
      ),
    );
  }
}