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
          actions: [

            IconButton(

              icon: const Icon(
                Icons.notifications_none,
              ),

              onPressed: () {},
            ),
          ],
        ),
        drawer: Drawer(

          child: ListView(

            padding: EdgeInsets.zero,

            children: [

              DrawerHeader(

                decoration: BoxDecoration(
                  color: Colors.green[700],
                ),

                child: const Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  mainAxisAlignment:
                  MainAxisAlignment.end,

                  children: [

                    Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 50,
                    ),

                    SizedBox(height: 10),

                    Text(

                      'SVS Finance ERP',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(

                      'School Finance Management',

                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              ListTile(

                leading: const Icon(
                  Icons.dashboard,
                  color: Colors.green,
                ),

                title: const Text(
                  'Dashboard',
                ),

                onTap: () {

                  Navigator.pop(context);
                },
              ),

              ListTile(

                leading: const Icon(
                  Icons.book,
                  color: Colors.green,
                ),

                title: const Text(
                  'Ledger',
                ),

                onTap: () {

                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/ledger',
                  );
                },
              ),

              ListTile(

                leading: const Icon(
                  Icons.account_balance,
                  color: Colors.green,
                ),

                title: const Text(
                  'Accounts',
                ),

                onTap: () {

                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/accounts',
                  );
                },
              ),

              ListTile(

                leading: const Icon(
                  Icons.category,
                  color: Colors.green,
                ),

                title: const Text(
                  'Categories',
                ),

                onTap: () {

                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/categories',
                  );
                },
              ),

              ListTile(

                leading: const Icon(
                  Icons.bar_chart,
                  color: Colors.green,
                ),

                title: const Text(
                  'Reports',
                ),

                onTap: () {

                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/reports',
                  );
                },
              ),

              const Divider(),

              ListTile(

                leading: const Icon(
                  Icons.backup,
                  color: Colors.green,
                ),

                title: const Text(
                  'Backup',
                ),

                onTap: () {

                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/dataBackUp',
                  );
                },
              ),

              ListTile(

                leading: const Icon(
                  Icons.settings,
                  color: Colors.green,
                ),

                title: const Text(
                  'Sessions',
                ),

                onTap: () {

                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/settings',
                  );
                },
              ),
            ],
          ),
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
          SizedBox(height: 24),
          Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Today's Summary",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,

                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                        color.withOpacity(0.15),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        getTodayIncome(
                          transactions,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                        color.withOpacity(0.15),
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        getTodayExpense(
                          transactions,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
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
  String getTodayIncome( List<Expenses> transactions,) {

    double total = 0;
    for (var tx in transactions) {
      if (isToday(tx.date) && !tx.isExpense) {
        total += tx.amount;
      }
    }
    return total.toStringAsFixed(0);
  }
  String getTodayExpense(List<Expenses> transactions,) {

    double total = 0;
    for (var tx in transactions) {
      if (isToday(tx.date) && tx.isExpense) {
        total += tx.amount;
      }
    }
    return total.toStringAsFixed(0);
  }
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
