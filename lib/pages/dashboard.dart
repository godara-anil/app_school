import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:app_school/boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/getActiveSession.dart';
import '../widget/addExpensesDialog.dart';

class dashboard extends StatefulWidget {
  @override
  State<dashboard> createState() => _dashboardState();
}
class _dashboardState extends State<dashboard> {
  int currentSessionKey = 0;
  @override
  void dispose() {
    Hive.box('expenses').close();
    Hive.box('sessions').close();
    super.dispose();
  }
  double cashBalance = 0;
  double bankBalance = 0;
  getCashBankBalance(List<Expenses> transactions) {
    cashBalance = 0;
    bankBalance = 0;
    for (Expenses data in transactions) {
      if (data.isExpense) {
        if (data.isBank!) {
          bankBalance -= data.amount;
        }
        else {
          cashBalance -= data.amount;
        }
      }
      else {
        if (data.isBank!) {
          bankBalance += data.amount;
        }
        else {
          cashBalance += data.amount;
        }

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    var  currentSession = getActiveSession.getSession();
    if(currentSession.length == 0){
      final session = Sessions()
      ..isActive = true
      ..session = '2020-21';
      final box = Sess.getTransactions();
      box.add(session);
      currentSession = getActiveSession.getSession();
      currentSessionKey = currentSession[0].key;
    }
    else {
       currentSessionKey = currentSession[0].key;
    }
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          backgroundColor: Colors.green[700],
          actions: <Widget>[
            PopupMenuButton <int> (itemBuilder: (context) => [
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10,),
                      Text('Sessions'),
                    ],
                  )
              ),
              PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.backup,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10,),
                      Text('Data Backup'),
                    ],
                  )),
              PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(
                        Icons.data_thresholding,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10,),
                      Text('Reports'),
                    ],
                  )),
            ],
              onSelected: (value) {
                 if(value == 1) {
                   Navigator.pushNamed(context, '/settings').then((value) =>
                       setState(() => {}));
                 }
                 else if (value ==2) {
                   Navigator.pushNamed(context, '/dataBackUp');
                 }
                 else if (value ==3) {
                   Navigator.pushNamed(context, '/reports');
                 }

              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
        context: context,
        builder: (context) => AddExpenseDialog(
          incomeOrExpense : false,
          onClickDone: addTransaction,
        ),


      ),
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),

        ),
        body: ValueListenableBuilder<Box<Expenses>>(
          valueListenable: Boxes.getTransactions().listenable(),
          builder: (context, box, _) {
            final transactions = box.values.where((Expenses) =>
            Expenses.sessionKey == currentSessionKey)
                .toList().cast<Expenses>();
            transactions.sort((b, a )=> a.date.compareTo(b.date));
            getCashBankBalance(transactions);
            return buildContent(transactions);
          },
        ),
      );

  }
  Widget buildContent(List<Expenses> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
        'No data to display',
        style: TextStyle(fontSize: 24)),

      );
    } else {
      final netBalance = transactions.fold<double>(
        0,
            (previousValue, transaction) => transaction.isExpense
            ? previousValue - transaction.amount
            : previousValue + transaction.amount,
      );
      final newBalanceString = '${netBalance.toStringAsFixed(0)}';
      final color = netBalance > 0 ? Colors.green : Colors.red;
      final netExpense = transactions.fold<double>(
        0,
            (previousValue, transaction) => transaction.isExpense
            ? previousValue + transaction.amount
            : previousValue,
      );
      final netIncome = transactions.fold<double>(
        0,
            (previousValue, transaction) => transaction.isExpense
            ? previousValue
            : previousValue + transaction.amount,
      );
      final newExpenseString = '${netExpense.toStringAsFixed(0)}';
      final newIncomeString = '${netIncome.toStringAsFixed(0)}';
      return Column(
        children: [
          SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.currency_rupee_rounded, color: Colors.white,),
                      Text(
                        "$newBalanceString",
                         style: TextStyle(fontSize: 30.0, color: Colors.white,),),
                    ],
                  ),
                  subtitle: Text('Net Balance',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cardCash(
                         cashBalance.toStringAsFixed(0)
                        ),
                        cardBank (
                          bankBalance.toStringAsFixed(0)
                        )
                      ],
                    ),
                )
              ],
            ),
            elevation: 8,
            color: color,
            shadowColor: color,
            margin: EdgeInsets.all(20),
            shape:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white)
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/expenses', arguments: {'isExpense' : false},),
                  child: Card(
                      child: ListTile(
                        title:  Text(
                          "$newIncomeString",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20.0, color: Colors.green,),),
                        subtitle: Text('Net Income',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    color: Colors.white,
                    elevation: 8,
                      shadowColor: Colors.green,
                      margin: EdgeInsets.fromLTRB(20,0,10,0),
                      shape:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white)
                      ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/expenses', arguments: {'isExpense' : true},),
                  child: Card(
                      child: ListTile(
                        title:  Text(
                          "$newExpenseString",
                           textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20.0, color: Colors.red,),),
                        subtitle: Text('Net Expenses',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      color: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.red,
                      margin: EdgeInsets.fromLTRB(10,0,20,0),
                      shape:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white)
                      ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24,),
          Text(
              "Latest Transactions",
          style: TextStyle(fontSize:20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: transactions.length > 5? 5 : transactions.length,
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),
        ),
        subtitle: Text(
            date,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                color: Colors.green,
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
      ),
    );
  }
  Widget cardCash(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(
            6.0,
          ),
          child: Icon(
            Icons.currency_rupee,
            size: 28.0,
            color: Colors.green[700],
          ),
          margin: EdgeInsets.only(
            right: 8.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cash",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget cardBank(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(
            6.0,
          ),
          child: Icon(
            Icons.money,
            size: 28.0,
            color: Colors.green[700],
          ),
          margin: EdgeInsets.only(
            right: 8.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " Bank",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Future addTransaction(double amount, String name, bool isExpense, DateTime date, bool isBank, String remarks) async {
    //print(currentSessionKey);
    final expenses = Expenses()
      ..amount = amount
      ..category = name
      ..date = date
      ..isExpense = isExpense
      ..sessionKey = currentSessionKey
      ..isBank = isBank
      ..remarks = remarks;

    final box = Boxes.getTransactions();
    box.add(expenses);
  }
}
