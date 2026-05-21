import 'package:flutter/material.dart';
import 'package:app_school/boxes.dart';
import 'package:intl/intl.dart';
import 'package:app_school/model/Expenses.dart';


class AddExpenseDialog extends StatefulWidget {
  final Expenses? expenses;
  final incomeOrExpense;

  final Function(
      double amount,
      String category,
      bool isExpense,
      DateTime date,
      String accountId,
      String remarks,
      ) onClickDone;

  const AddExpenseDialog({
    Key? key,
    this.expenses,
    this.incomeOrExpense,
    required this.onClickDone,
  }) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final remarksController = TextEditingController();
  final amountController = TextEditingController();

  DateTime date = DateTime.now();

  bool isExpense = true;

  Account? selectedAccount;

  @override
  void initState() {
    super.initState();

    final accounts = AccountsBox.getAccounts().values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    if (widget.expenses != null) {
      final expenses = widget.expenses!;

      nameController.text = expenses.category;

      if (expenses.remarks != null) {
        remarksController.text = expenses.remarks!;
      }

      amountController.text = expenses.amount.toString();

      isExpense = expenses.isExpense;

      date = expenses.date;

      // Load selected account in edit mode
      selectedAccount = AccountsBox.getAccounts()
          .get(int.tryParse(expenses.accountId));
    } else {
      isExpense = widget.incomeOrExpense ?? true;

      // Default account
      if (accounts.isNotEmpty) {
        selectedAccount = accounts.first;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    remarksController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenses != null;

    final title = isEditing
        ? 'Edit Transaction'
        : 'Add Transaction';

    final formattedDate = DateFormat.yMMMd().format(date);

    final accounts = AccountsBox.getAccounts().values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: isExpense ? Colors.red : Colors.green,
        ),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),

              buildName(),

              const SizedBox(height: 8),

              buildAmount(),

              const SizedBox(height: 8),

              buildRemarks(),

              const SizedBox(height: 8),

              buildDate(formattedDate),

              const SizedBox(height: 8),

              buildDivider(),

              const SizedBox(height: 8),

              buildAccountDropdown(accounts),

              const SizedBox(height: 8),

              buildDivider(),

              const SizedBox(height: 8),

              buildChoiceChips(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  Widget buildName() => TextFormField(
    controller: nameController,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Name',
    ),
    validator: (name) =>
    name != null && name.isEmpty
        ? 'Enter a name'
        : null,
  );

  Widget buildRemarks() => TextFormField(
    controller: remarksController,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Remarks',
    ),
  );

  Widget buildDate(String formattedDate) => Row(
    mainAxisAlignment:
    MainAxisAlignment.spaceEvenly,
    children: [
      Text(formattedDate),
      TextButton(
        onPressed: () async {
          DateTime? newDate =
          await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );

          if (newDate == null) return;

          setState(() => date = newDate);
        },
        child: const Icon(
          Icons.calendar_month,
          color: Colors.green,
        ),
      ),
    ],
  );

  Widget buildAmount() => TextFormField(
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Amount',
    ),
    keyboardType: TextInputType.number,
    validator: (amount) =>
    amount != null &&
        double.tryParse(amount) == null
        ? 'Enter a valid number'
        : null,
    controller: amountController,
  );

  Widget buildAccountDropdown(
      List<Account> accounts) {
    return DropdownButtonFormField<Account>(
      value: selectedAccount,
      decoration: const InputDecoration(
        labelText: 'Select Account',
        border: OutlineInputBorder(),
      ),
      items: accounts.map((account) {
        return DropdownMenuItem<Account>(
          value: account,
          child: Text(
            '${account.name} (${account.type})',
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedAccount = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select account';
        }
        return null;
      },
    );
  }

  Widget buildChoiceChips() => Row(
    mainAxisAlignment:
    MainAxisAlignment.spaceEvenly,
    children: [
      ChoiceChip(
        label: Text(
          "Income",
          style: TextStyle(
            fontSize: 18.0,
            color: isExpense
                ? Colors.black
                : Colors.white,
          ),
        ),
        selectedColor: Colors.lightGreen,
        onSelected: (val) =>
            setState(() => isExpense = !val),
        selected: !isExpense,
      ),
      ChoiceChip(
        label: Text(
          "Expense",
          style: TextStyle(
            fontSize: 18.0,
            color: isExpense
                ? Colors.white
                : Colors.black,
          ),
        ),
        selectedColor: Colors.redAccent,
        onSelected: (val) =>
            setState(() => isExpense = val),
        selected: isExpense,
      ),
    ],
  );

  Widget buildDivider() => const Divider(
    color: Colors.grey,
    height: 5,
    thickness: 1,
    indent: 5,
    endIndent: 5,
  );

  Widget buildCancelButton(
      BuildContext context) =>
      TextButton(
        child: const Text('Cancel'),
        onPressed: () =>
            Navigator.of(context).pop(),
      );

  Widget buildAddButton(
      BuildContext context, {
        required bool isEditing,
      }) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid =
        formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text;

          final remarks =
              remarksController.text;

          final amount =
              double.tryParse(
                amountController.text,
              ) ??
                  0;

          widget.onClickDone(
            amount,
            name,
            isExpense,
            date,
            selectedAccount!.key.toString(),
            remarks,
          );

          Navigator.of(context).pop();
        }
      },
    );
  }
}
