import 'package:app_school/model/Expenses.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:app_school/widget/addExpensesDialog.dart';
import 'package:app_school/boxes.dart';
import 'package:app_school/getActiveSession.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class expenses extends StatefulWidget {
  const expenses({Key? key}) : super(key: key);

  @override
  State<expenses> createState() => _expensesState();
}

class _expensesState extends State<expenses> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  DateTime date = DateTime.now();
  bool isExpense = true;
  final currentSessionKey = getActiveSession.getSession()[0].key;
  DateTimeRange? _selectedDateRange;

  // This function will be triggered when the floating button is pressed
  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2021, 1, 1),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      // Rebuild the UI
      // print('result');
      print(result);
      setState(() {
        _selectedDateRange = result;
      });
    }
  }
  @override
  void initState (){
    super.initState();
   // controller = TextEditingController();
  }
  @override
  void dispose() {
    Hive.box('expenses').close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
   final incomOrExpense = ModalRoute.of(context)?.settings.arguments as Map?;
     isExpense = incomOrExpense?['isExpense'];
   //isExpense = true;
   final appBarText = isExpense ? 'Expenses' : 'Incomes';
   final appBarColor = isExpense ? Colors.red : Colors.green;
  final cYear = DateTime.now().year;
   DateTime startDate = DateTime(cYear, 3, 31);
   DateTime endDate = DateTime.now().add(const Duration(days: 1));
   if(_selectedDateRange != null){
     startDate = _selectedDateRange!.start.subtract(const Duration(days: 1));
     endDate = _selectedDateRange!.end.add(const Duration(days: 1));
   }
   String btnText1 = DateFormat('d MMM').format(startDate.add(const Duration(days: 1)));
   String btnText2 = DateFormat('d MMM').format(endDate.subtract(const Duration(days: 1)));
   // final currentSession = '2022-23';
     return Scaffold(
      appBar: AppBar(
        title: Text('$appBarText'),
        actions: <Widget>[
          IconButton(onPressed: (){},
              icon: Icon(Icons.search)),
          TextButton(onPressed: _show,
              child: Text(
                  '$btnText1 - $btnText2',
              style: TextStyle(color: Colors.white),)),

        ],
        backgroundColor: appBarColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(
        incomeOrExpense : isExpense,
        onClickDone: addTransaction,
      ),

    ),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Expenses>>(
        valueListenable: Boxes.getTransactions().listenable(),
        builder: (context, box, _) {
          final transactions = box.values.where((Expenses) => Expenses.isExpense == isExpense)
              .where((Expenses) => Expenses.sessionKey == currentSessionKey)
              .where((Expenses) => Expenses.date.isAfter(startDate))
              .where((Expenses) => Expenses.date.isBefore(endDate))
              .toList().cast<Expenses>();
          transactions.sort((b, a )=> a.date.compareTo(b.date));
          return buildContent(transactions);
        },
      ),
    );

  }
  Widget buildContent(List<Expenses> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No Transactions yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final netExpense = transactions.fold<double>(
        0,
            (previousValue, transaction) => previousValue + transaction.amount,
      );
      final newExpenseString = '${netExpense.toStringAsFixed(0)}';
      final color = isExpense ? Colors.red : Colors.green;

      return Column(
        children: [
          SizedBox(height: 24),
          Text(
            'Total: $newExpenseString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                final transaction = transactions[index];

                return buildTransaction(context, transaction);
              },
            ),
          ),
        ],
      );
    }
  }
    Widget buildTransaction(
      BuildContext context,
      Expenses transaction,
      ) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.date);
    final amount = transaction.amount.toStringAsFixed(0);
    final bankCash = transaction.isBank! ? "Bank" : "Cash";
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          transaction.category,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8.0,),
            Container(
              decoration: BoxDecoration (
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(5.0),
              child: Text(
                bankCash,
                style: TextStyle(
                    fontSize: 13.0,
                  color: Colors.white,
                  ),
              ),
            )
          ],
        ),
        children: [
          buildButtons(context, transaction),
        ],
      ),
    );
  }

  Widget buildButtons(BuildContext context, Expenses transaction) => Row(
    children: [
      Expanded(
        child: TextButton.icon(
          label: Text('Edit'),
          icon: Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddExpenseDialog(
                expenses: transaction,
                onClickDone: (amount, name, isExpense, date, isBank) =>
                    editTransaction(transaction, name, amount, isExpense, date, isBank),
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: TextButton.icon(
          label: Text('Delete'),
          icon: Icon(Icons.delete),
          onPressed: () => deleteTransaction(transaction),
        ),
      )
    ],
  );
  Future addTransaction(double amount, String name, bool isExpense, DateTime date, bool isBank) async {
    final expenses = Expenses()
      ..amount = amount
      ..category = name
      ..date = date
      ..isExpense = isExpense
      ..sessionKey = currentSessionKey
      ..isBank = isBank;

    final box = Boxes.getTransactions();
    box.add(expenses);
    // print(amount);
    // print(name);
    // print(date);
}
  void editTransaction(
      Expenses transaction,
      String name,
      double amount,
      bool isExpense,
      DateTime date,
      bool isBank
      ) {
    transaction.category = name;
    transaction.amount = amount;
    transaction.isExpense = isExpense;
    transaction.isBank = isBank;
    transaction.date = date;
    transaction.save();
  }

  void deleteTransaction(Expenses transaction) async{
    // final box = Boxes.getTransactions();
    // box.delete(transaction.key);
    final response = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Are you sure you want to delete this transaction!'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if(response != null && response == true) {
       transaction.delete();
      //print(response);
    }
   //
    //setState(() => transactions.remove(transaction));
  }

}
