import 'package:flutter/material.dart';
import 'package:app_school/boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/model/Expenses.dart';
import '../widget/addExpensesDialog.dart';
import 'package:app_school/services/transaction_service.dart';
import 'package:app_school/services/session_service.dart';
import 'package:app_school/widget/transaction_tile.dart';

class dashboard extends StatefulWidget {
  @override
  State<dashboard> createState() => _dashboardState();
}
class _dashboardState extends State<dashboard> {
  int currentSessionKey = 0;
  @override
  void initState() {
    super.initState();

    currentSessionKey =
        SessionService.getActiveSessionKey();
  }


  @override
  Widget build(BuildContext context) {

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
              PopupMenuItem(
                value: 4,
                child: Row(
                  children: [
                    Icon(Icons.account_balance,
                        color: Colors.green),
                    SizedBox(width: 10),
                    Text('Accounts'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 5,
                child: Row(
                  children: [
                    Icon(Icons.book, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Ledger'),
                  ],
                ),
              ),
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
                 else if (value ==4) {
                   Navigator.pushNamed(context, '/accountsSummary');
                 }
                 else if (value == 5) {
                   Navigator.pushNamed(context, '/ledger');
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
          onClickDone:  ( amount, category, isExpense, date, accountId, remarks,
        ) async {
          await TransactionService.addTransaction(
          amount: amount,
          category: category,
          isExpense: isExpense,
          date: date,
          sessionKey: currentSessionKey,
          accountId: accountId,
          remarks: remarks,
          );
          },
        ),


      ),
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),

        ),
        body: ValueListenableBuilder<Box<Expenses>>(
          valueListenable: Boxes.getTransactions().listenable(),
          builder: (context, box, _) {
            final transactions =
            TransactionService.getTransactionsBySession(
                currentSessionKey);
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
      final cashBalance =
      TransactionService.getCashBalance(transactions);

      final bankBalance =
      TransactionService.getBankBalance(transactions);
      final netBalance = TransactionService.getNetBalance(transactions);
      final newBalanceString = '${netBalance.toStringAsFixed(0)}';
      final color = netBalance > 0 ? Colors.green : Colors.red;
      final netExpense = TransactionService.getNetExpense(transactions);
      final netIncome = TransactionService.getNetIncome(transactions);
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
              itemCount:
              transactions.length > 5
                  ? 5
                  : transactions.length,
              itemBuilder: (BuildContext context, int index) {
                final transaction = transactions[index];
                return  TransactionTile(
                  transaction: transaction,
                );;
              },
            ),
          ),
       ],
      );
    }
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
}
