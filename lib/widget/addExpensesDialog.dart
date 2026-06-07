import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/model/category_model.dart';
import 'package:app_school/services/session_service.dart';

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
  State<AddExpenseDialog> createState() =>
      _AddExpenseDialogState();
}

class _AddExpenseDialogState
    extends State<AddExpenseDialog> {

  final formKey = GlobalKey<FormState>();

  final remarksController =
  TextEditingController();

  final amountController =
  TextEditingController();

  DateTime date = DateTime.now();

  bool isExpense = true;

  Account? selectedAccount;

  Category? selectedCategory;

  @override
  void initState() {

    super.initState();

    final accounts =
    AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();
    final categories =
    CategoryBox.getCategories()
        .values
        .where((c) => c.isActive)
        .toList()
        .cast<Category>();

    try {

      selectedCategory =
          categories.firstWhere(
                (c) =>
            c.name ==
                widget.expenses!.category,
          );

    } catch (e) {

      selectedCategory = null;
    }
    if (widget.expenses != null) {
      final expenses =
      widget.expenses!;
      amountController.text =
          expenses.amount.toString();
      if (expenses.remarks != null) {
        remarksController.text =
        expenses.remarks!;
      }

      isExpense =
          expenses.isExpense;

      date =
          expenses.date;

      selectedAccount =
          AccountsBox.getAccounts().get(
            int.tryParse(
              expenses.accountId,
            ),
          );

      try {
        selectedCategory =
            categories.firstWhere(
                  (c) =>
              c.name ==
                  expenses.category,
            );

      } catch (e) {
        selectedCategory = null;
      }

    } else {

      isExpense =
          widget.incomeOrExpense ?? true;

      if (accounts.isNotEmpty) {
        selectedAccount =
            accounts.first;
      }

      if (categories.isNotEmpty) {
        selectedCategory =
            categories.first;
      }
    }
  }

  @override
  void dispose() {

    amountController.dispose();

    remarksController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final isEditing =
        widget.expenses != null;

    final title = isEditing
        ? 'Edit Transaction'
        : 'Add Transaction';

    final formattedDate =
    DateFormat.yMMMd().format(date);

    final accounts =
    AccountsBox.getAccounts()
        .values
        .where((a) => a.isActive)
        .toList()
        .cast<Account>();

    final categories =
    CategoryBox.getCategories()
        .values
        .where((c) => c.isActive)
        .toList()
        .cast<Category>();
    categories.sort(
          (a, b) => a.name
          .toLowerCase()
          .compareTo(
        b.name.toLowerCase(),
      ),
    );
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: isExpense
              ? Colors.red
              : Colors.green,
        ),
      ),

      content: Form(

        key: formKey,

        child: SingleChildScrollView(

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              buildCategoryDropdown(),
              const SizedBox(height: 8),
              buildAmount(),
              const SizedBox(height: 8),
              buildRemarks(),
              const SizedBox(height: 8),
              buildDate(formattedDate),
              const SizedBox(height: 8),
              buildDivider(),
              const SizedBox(height: 8),
              buildAccountDropdown(
                accounts,
              ),
              const SizedBox(height: 8),
              buildDivider(),
              const SizedBox(height: 8),
              buildChoiceChips(),
            ],
          ),
        ),
      ),

      actions: [

        buildCancelButton(context),

        buildAddButton(
          context,
          isEditing: isEditing,
        ),
      ],
    );
  }

  Widget buildCategoryDropdown() {
    print("this is isExpense" + isExpense.toString());
    final categories =
    CategoryBox.getCategories()
        .values
        .where(
          (c) =>
      c.isActive &&
          c.isExpense == isExpense,
    )
        .toList()
        .cast<Category>();
    categories.sort(
          (a, b) => a.name
          .toLowerCase()
          .compareTo(
        b.name.toLowerCase(),
      ),
    );
    if (
    selectedCategory != null &&

        !categories.contains(selectedCategory)
    ) {
      selectedCategory = null;
    }
    return DropdownButtonFormField<Category>(
      value: selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Select Category',
        border: OutlineInputBorder(),
      ),
      items: categories.map((category) {

        return DropdownMenuItem<Category>(

          value: category,

          child: Text(category.name),
        );

      }).toList(),

      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },

      validator: (value) {

        if (value == null) {
          return 'Please select category';
        }

        return null;
      },
    );
  }

  Widget buildRemarks() =>
      TextFormField(

        controller: remarksController,

        decoration:
        const InputDecoration(

          border: OutlineInputBorder(),

          hintText: 'Remarks',
        ),
      );

  Widget buildDate(
      String formattedDate,
      ) =>
      Row(
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

              if (newDate == null) {
                return;
              }

              setState(() {

                date = newDate;
              });
            },

            child: const Icon(
              Icons.calendar_month,
              color: Colors.green,
            ),
          ),
        ],
      );

  Widget buildAmount() =>
      TextFormField(

        decoration:
        const InputDecoration(

          border: OutlineInputBorder(),

          hintText: 'Enter Amount',
        ),

        keyboardType:
        TextInputType.number,
        validator: (amount) {

          if (amount == null ||
              amount.isEmpty) {

            return 'Enter amount';
          }
          if (double.tryParse(amount)
              == null) {
            return 'Enter valid number';
          }
          if ((double.tryParse(amount) ?? 0) <= 0) {
            return 'Amount must be greater than 0';
          }

          return null;
        },

        controller: amountController,
      );

  Widget buildAccountDropdown(
      List<Account> accounts,
      ) {

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
            fontSize: 18,

            color: isExpense
                ? Colors.black
                : Colors.white,
          ),
        ),

        selectedColor:
        Colors.lightGreen,

        onSelected: (val) {
          setState(() {
            isExpense = !val;
            selectedCategory = null;
          });
        },
        selected: !isExpense,
      ),
      ChoiceChip(
        label: Text(
          "Expense",
          style: TextStyle(
            fontSize: 18,
            color: isExpense
                ? Colors.white
                : Colors.black,
          ),
        ),
        selectedColor:
        Colors.redAccent,
        onSelected: (val) {
          setState(() {
            isExpense = val;
            selectedCategory = null;
          });
        },
        selected: isExpense,
      ),
    ],
  );
  Widget buildDivider() =>
      const Divider(
        color: Colors.grey,
      );

  Widget buildCancelButton(
      BuildContext context,
      ) =>  TextButton(

        child: const Text('Cancel'),

        onPressed: () =>
            Navigator.of(context).pop(),
      );

  Widget buildAddButton(
      BuildContext context, {
        required bool isEditing,
      }) {

    final text =
    isEditing ? 'Save' : 'Add';

    return TextButton(

      child: Text(text),

      onPressed: () async {
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
        final isValid =
        formKey.currentState!.validate();

        if (!isValid) return;

        final amount =
            double.tryParse(
              amountController.text,
            ) ??
                0;

        final remarks =
            remarksController.text;

        widget.onClickDone(

          amount,

          selectedCategory!.name,

          isExpense,

          date,

          selectedAccount!.key.toString(),

          remarks,
        );

        Navigator.of(context).pop();
      },
    );
  }
}