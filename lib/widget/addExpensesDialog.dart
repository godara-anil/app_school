import 'package:flutter/material.dart';
import '../model/Expenses.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final Expenses? expenses;
  final incomeOrExpense;
  final Function(double amount, String category, bool isExpense, DateTime date) onClickDone;
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

  @override
  void initState (){
    super.initState();
    if (widget.expenses != null) {
      final expenses = widget.expenses!;

      nameController.text = expenses.category;
      amountController.text = expenses.amount.toString();
      isExpense = expenses.isExpense;
      date = expenses.date;
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
              buildRadioButtons(),
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
    children: [
      Text('$formatedDate'),
      FlatButton(onPressed: () async {
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

          widget.onClickDone(amount, name, isExpense, date);

          Navigator.of(context).pop();
        }
      },
    );
  }
}
