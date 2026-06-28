import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

import 'package:app_school/services/session_service.dart';
import 'package:app_school/services/transaction_service.dart';

class TransferDialog extends StatefulWidget {
  final String? transferId;

  const TransferDialog({
    Key? key,
    this.transferId,
  }) : super(key: key);
  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  @override
  void initState() {
    super.initState();

    final accounts = AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    if (widget.transferId != null) {
      final pair = TransactionService.getTransferPair(widget.transferId!);

      if (pair != null) {
        amountController.text = pair.source.amount.toString();
        date = pair.source.date;
        fromAccount = AccountsBox.getAccounts().get(
          int.tryParse(pair.source.accountId),
        );
        toAccount = AccountsBox.getAccounts().get(
          int.tryParse(pair.destination.accountId),
        );
        remarksController.text = _plainTransferRemarks(
          value: pair.source.remarks,
          accountName: toAccount?.name,
        );
      }
    } else if (accounts.length >= 2) {
      fromAccount = accounts[0];

      toAccount = accounts[1];
    }
  }

  final amountController = TextEditingController();

  final remarksController = TextEditingController();

  DateTime date = DateTime.now();

  Account? fromAccount;

  Account? toAccount;

  @override
  void dispose() {
    amountController.dispose();
    remarksController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transferId != null;

    return AlertDialog(
      title: Text(
        isEditing ? "Edit Transfer" : "Transfer Amount",
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          child: const Text(
            "Cancel",
          ),
        ),
        ElevatedButton(
          onPressed: saveTransfer,
          child: Text(
            isEditing ? "Save" : "Transfer",
          ),
        ),
      ],
    );
  }

  Widget buildFromAccount() {
    final accounts = AccountsBox.getAccounts()
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
    final accounts = AccountsBox.getAccounts()
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
          value: account,
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
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Amount",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildRemarks() {
    return TextFormField(
      controller: remarksController,
      decoration: const InputDecoration(
        labelText: "Remarks",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat.yMMMd().format(date),
        ),
        IconButton(
          icon: const Icon(
            Icons.calendar_month,
          ),
          onPressed: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
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

  Future<void> saveTransfer() async {
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
    final amount = double.tryParse(
      amountController.text,
    );

    if (amount == null || amount <= 0) {
      showError(
        "Enter valid amount",
      );
      return;
    }

    if (fromAccount == null || toAccount == null) {
      showError(
        "Select accounts",
      );
      return;
    }

    if (fromAccount!.key == toAccount!.key) {
      showError(
        "Accounts must be different",
      );
      return;
    }

    if (widget.transferId == null) {
      await TransactionService.transferTransaction(
        amount: amount,
        date: date,
        sessionKey: SessionService.getActiveSessionKey(),
        fromAccountId: fromAccount!.key.toString(),
        toAccountId: toAccount!.key.toString(),
        remarks1:
            "Transfer From: ${fromAccount?.name} ${remarksController.text}",
        remarks2: "Transfer To: ${toAccount?.name} ${remarksController.text}",
      );
    } else {
      try {
        await TransactionService.updateTransfer(
          transferId: widget.transferId!,
          amount: amount,
          date: date,
          fromAccountId: fromAccount!.key.toString(),
          toAccountId: toAccount!.key.toString(),
          remarks: remarksController.text,
        );
      } on StateError {
        showError(
          "Transfer could not be updated because its linked entry is missing.",
        );
        return;
      }
    }

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
        content: Text(message),
      ),
    );
  }

  String _plainTransferRemarks({
    required String? value,
    required String? accountName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final text = value.trim();
    if (accountName != null) {
      final prefix = 'Transfer To: $accountName';
      if (text.startsWith(prefix)) {
        return text.substring(prefix.length).trim();
      }
    }

    final match =
        RegExp(r'^Transfer (?:To|From):\s+.*?\s{2,}(.*)$').firstMatch(text);

    if (match == null) {
      return text;
    }

    return match.group(1)?.trim() ?? '';
  }
}
