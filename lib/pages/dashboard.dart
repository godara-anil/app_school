import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:app_school/boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/getActiveSession.dart';
import 'package:app_school/widget/dataBackupRestore.dart';
import 'package:app_school/pages/settings_sessions.dart';


class dashboard extends StatefulWidget {
  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  @override
  void dispose() {
    Hive.box('expenses').close();
    Hive.box('sessions').close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var  currentSession = getActiveSession.getSession();
    int currentSessionKey = 0;
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
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
                Navigator.pushNamed(context, '/settings').then((value) =>
                    setState(() => {}));
              },
            )
          ],
        ),
        body: ValueListenableBuilder<Box<Expenses>>(
          valueListenable: Boxes.getTransactions().listenable(),
          builder: (context, box, _) {
            final transactions = box.values.where((Expenses) =>
            Expenses.sessionKey == currentSessionKey)
                .toList().cast<Expenses>();
            // transactions.sort((b, a )=> a.date.compareTo(b.date));
            return buildContent(transactions);
          },
        ),
      );
  }
  Widget buildContent(List<Expenses> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: FlatButton(
          child: Text(
          'No data yet click to Add!',
          style: TextStyle(fontSize: 24)),
          onPressed: (){
            Navigator.pushNamed(context, '/expenses', arguments: {'isExpense' : false});
          },
        ),
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
            child: ListTile(
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
          FlatButton(
            onPressed: (){
              dataBackup().backUp();
            },
            child: Text('Data Backup'),
          )
       ],
      );
    }
  }
}
