import 'package:app_school/model/Expenses.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:app_school/widget/addExpensesDialog.dart';
import 'package:app_school/boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:app_school/services/account_service.dart';
import 'package:app_school/services/transaction_service.dart';
import 'package:app_school/services/session_service.dart';
import 'package:app_school/widget/transaction_tile.dart';



class ExpensesPage  extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String searchQuery = '';
  final searchText = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  DateTime date = DateTime.now();
  bool isExpense = true;
 late int currentSessionKey;
  // final currentSessionKey = getActiveSession.getSession()[0].key;
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
      setState(() {
        _selectedDateRange = result;
      });
    }
  }
  @override
  void initState (){
    super.initState();
    currentSessionKey =
        SessionService.getActiveSessionKey();
  }
  @override
  void dispose() {
    super.dispose();
  }
  Widget cusAppBarText = Text('Transaction');
  Icon cusIconSearch = Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
   final incomOrExpense = ModalRoute.of(context)?.settings.arguments as Map?;
     isExpense = incomOrExpense?['isExpense'];
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
   if(this.cusAppBarText.runtimeType == Text) { cusAppBarText = Text(appBarText); }
     return Scaffold(
      appBar: AppBar(
        title: cusAppBarText,
        actions: <Widget>[
          IconButton(onPressed: (){
            setState(() {
              if(this.cusIconSearch.icon == Icons.search) {
                this.cusIconSearch = Icon(Icons.clear);
                this.cusAppBarText = TextField(
                  controller: searchText,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Here ...',
                    hintStyle:  TextStyle(
                      color: Colors.white
                    )
                  ),
                  autofocus: true,
                );
              }
              else {
                this.cusIconSearch = Icon(Icons.search);
                this.cusAppBarText = Text(appBarText);
                setState(() {
                  searchQuery = '';
                });
              }
            });
          },
              icon: cusIconSearch),
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
        onClickDone: (
            amount,
            name,
            isExpense,
            date,
            accountId,
            remarks,
            ) async {

          await TransactionService.addTransaction(
            amount: amount,
            category: name,
            isExpense: isExpense,
            date: date,
            sessionKey: currentSessionKey,
            accountId: accountId,
            remarks: remarks,
          );
        },
      ),
    ),
        backgroundColor: appBarColor,
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Expenses>>(
        valueListenable: Boxes.getTransactions().listenable(),
        builder: (context, box, _) {
          final transactions =
          TransactionService
              .getTransactionsBySession(
              currentSessionKey)
              .where(
                (tx) =>
            tx.isExpense == isExpense,
          )
              .where(
                (tx) => tx.date.isAfter(startDate)
          )
              .where(
                (tx) => tx.date.isBefore(endDate),
          )

              .where(
                (tx) => tx.category
                .toLowerCase()
                .contains(
              searchQuery.toLowerCase(),
            ),
          )
              .toList();
          transactions.sort((b, a )=> a.date.compareTo(b.date));
          return buildContent(transactions);
        },
      ),
    );
  }
  Widget buildContent(List<Expenses> transactions) {
    final newTransactions =  transactions.where(
          (tx) => !TransactionService.isTransfer(tx)
    ).toList();
    if (newTransactions.isEmpty) {
      return Center(
        child: Text(
          'No Transactions yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    }
    else {
      final netExpense = newTransactions.fold<double>(
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
              itemCount: newTransactions.length,
              itemBuilder: (BuildContext context, int index) {
                final transaction = newTransactions[index];
                return TransactionTile(
                  transaction: transaction,
                  children: buildButtons(
                    context,
                    transaction,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildButtons(BuildContext context, Expenses transaction) => Column(
    children: [
      Row(
        children: [
          getRemarks(transaction.remarks)
        ],

      ),
      Row(
        children: [
          Expanded(
            child: TextButton.icon(
              label: Text('Edit'),
              icon: Icon(Icons.edit),
              onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddExpenseDialog(
                    expenses: transaction,
                    onClickDone: (amount, name, isExpense, date, accountId, remarks) =>
                        TransactionService.updateTransaction(
                          expense: transaction,
                          amount: amount,
                          category: name,
                          isExpense: isExpense,
                          date: date,
                          accountId: accountId,
                          remarks: remarks,
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
      ),
    ],
  );

  void deleteTransaction(Expenses transaction) async{
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
      TransactionService.deleteTransaction(
          transaction);
      //print(response);
    }
   //
    //setState(() => transactions.remove(transaction));
  }
  Widget getRemarks(remark) {
    if(remark != null) {
       return Expanded(
          child:  Padding(
            padding: const EdgeInsets.fromLTRB(25.0,0,0,0),
            child: Text(remark,
            style: const TextStyle(
              fontSize: 16,
            ),),
          )
      );
    }
    else {
      return Column();
    }
  }
}