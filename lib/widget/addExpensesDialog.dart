import 'package:flutter/material.dart';
import '../model/Expenses.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final Expenses? expenses;
  final incomeOrExpense;
  final Function(double amount, String category, bool isExpense, DateTime date, bool isBank) onClickDone;
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
  final amountController = TextEditingController();
  DateTime date = DateTime.now();
  bool isExpense = true;
  bool isBank = false;

  @override
  void initState (){
    super.initState();
    if (widget.expenses != null) {
      final expenses = widget.expenses!;

      nameController.text = expenses.category;
      amountController.text = expenses.amount.toString();
      isExpense = expenses.isExpense;
      date = expenses.date;
      isBank = expenses.isBank!;
    }
    else {
      isExpense = widget.incomeOrExpense;
    }
  }
  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
     super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenses != null;
    final title = isEditing ? 'Edit Transaction' : 'Add Transaction';
    final formatedDate =  DateFormat.yMMMd().format(date);
    return AlertDialog(
      title: Text(title,
      style: TextStyle(color: isExpense? Colors.red : Colors.green),),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 8),
              buildName(),
              SizedBox(height: 8),
              buildAmount(),
              SizedBox(height: 8),
              buildDate(formatedDate),
              SizedBox(height: 8),
              buildDivider(),
              buildCashBank(),
              SizedBox(height: 8),
              buildDivider(),
              //buildRadioButtons(),
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
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Name',
    ),
    validator: (name) =>
    name != null && name.isEmpty ? 'Enter a name' : null,
  );
  Widget buildDate(formatedDate) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Text('$formatedDate'),
      TextButton(onPressed: () async {
        DateTime? newDate  = await showDatePicker(context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime.now()
        );
        if(newDate == null) return;
        setState(() => date = newDate);
      },
          child: Icon(Icons.calendar_month, color: Colors.green,)),
    ],

  );
  Widget buildAmount() => TextFormField(
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Amount',
    ),
    keyboardType: TextInputType.number,
    validator: (amount) => amount != null && double.tryParse(amount) == null
        ? 'Enter a valid number'
        : null,
    controller: amountController,
  );

  Widget buildRadioButtons() => Column(
    children: [
      RadioListTile<bool>(
        title: Text('Expense'),
        value: true,
        groupValue: isExpense,
        onChanged: (value) => setState(() => isExpense = value!),
      ),
      RadioListTile<bool>(
        title: Text('Income'),
        value: false,
        groupValue: isExpense,
        onChanged: (value) => setState(() => isExpense = value!),
      ),
    ],
  );
  Widget buildChoiceChips() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ChoiceChip(label: Text(
        "Income",
    style: TextStyle(
      fontSize: 18.0,
      color: isExpense ? Colors.black : Colors.white,
    ),
  ),
      selectedColor: Colors.lightGreen,
      onSelected: (val) => setState(() => isExpense = !val),
      selected: isExpense ? false : true,
      ),
      ChoiceChip(label: Text(
        "Expense",
        style: TextStyle(
          fontSize: 18.0,
          color: isExpense ? Colors.white : Colors.black,
        ),
      ),
        selectedColor: Colors.redAccent,
        onSelected: (val) => setState(() => isExpense = val),
        selected: isExpense ? true : false,
      ),
    ],
  );
  Widget buildCashBank() => Row(
    children: [
      Expanded(
        child: RadioListTile<bool>(
          title: Text('Cash'),
          value: false,
          groupValue: isBank,
          onChanged: (value) => setState(() => isBank = value!),
        ),
      ),
      Expanded(
        child: RadioListTile<bool>(
          title: Text('Bank'),
          value: true,
          groupValue: isBank,
          onChanged: (value) => setState(() => isBank = value!),
        ),
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
  Widget buildCancelButton(BuildContext context) => TextButton(
    child: Text('Cancel'),
    onPressed: () => Navigator.of(context).pop(),
  );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text;
          final amount = double.tryParse(amountController.text) ?? 0;

          widget.onClickDone(amount, name, isExpense, date, isBank);

          Navigator.of(context).pop();
        }
      },
    );
  }
}
