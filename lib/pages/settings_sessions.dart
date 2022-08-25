import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/boxes.dart';
import 'package:app_school/widget/addSessionDialog.dart';


class Settings_session extends StatefulWidget {
  const Settings_session({Key? key}) : super(key: key);

  @override
  State<Settings_session> createState() => _Settings_sessionState();
}

class _Settings_sessionState extends State<Settings_session> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green[700],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
      context: context,
      builder: (context) => AddSessionDialog(
        onClickDone: addTransaction,
      ),

    ),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Sessions>>(
        valueListenable: Sess.getTransactions().listenable(),
        builder: (context, box, _) {
          final sessions = box.values.toList().cast<Sessions>();
          // transactions.sort((b, a )=> a.date.compareTo(b.date));
          return buildContent(sessions);
        },
      ),
    );
  }
  Widget buildContent(List<Sessions> sessions){
    if(sessions.isEmpty){
      return Center(
        child: Text(
          'No Session Defined yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    }
    else {
      return Column(
        children: [
           Expanded(
             child: ListView.builder(
               padding: EdgeInsets.all(8),
               itemCount: sessions.length,
               itemBuilder: (BuildContext context, int index) {
                 final session = sessions[index];
                 return buildTransaction(context, session);
               },
             ),
           )
        ],
      );
    }
  }
  Widget buildTransaction(
      BuildContext context,
      Sessions session,
      ) {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        textColor: Colors.green[900],
        tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          session.session,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: buildIcon(session.isActive),
        children: [
          buildButtons(context, session),
        ],
        ),
      );
  }
  Widget buildIcon (isActive) {
    if(isActive == true) {
      return Icon(Icons.check, color: Colors.green[700],);
    }
    else {
      return Text('');
    }
  }
  Widget buildButtons(BuildContext context, Sessions session) => Row(
    children: [
      Expanded(
        child: TextButton.icon(
          label: Text('Edit'),
          icon: Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddSessionDialog(
                sessions: session,
                onClickDone: (isActive, name) =>
                    editTransaction(session, name, isActive,),
              ),
            ),
          ),
        ),

      ),
      Expanded(
        child: TextButton.icon(
          label: Text('Delete'),
          icon: Icon(Icons.delete,),
          onPressed: () => deleteTransaction(context, session),
        ),
      ),
      Expanded(
        child: checkActive(session),
      )
    ],
  );
  Widget checkActive (session){
    if(session.isActive){
      return Text('');
    }
    else {
      return TextButton.icon(
        label: Text('Active'),
        icon: Icon(Icons.check,),
        onPressed: () => makeActive(session),
      );
    }
  }
  Future addTransaction(isActive, name) async {
    final session = Sessions()
      ..isActive = isActive
      ..session = name;
    final box = Sess.getTransactions();
    box.add(session);
  }
  void editTransaction(
      Sessions session,
      String name,
      bool isActive,
      ) {
    session.session = name;
    session.isActive = isActive;
    session.save();
  }

  void deleteTransaction(context, Sessions transaction) async{
    final expenseBox = await Boxes.getTransactions().values
        .where((Expenses) => Expenses.sessionKey == transaction.key)
        .toList().cast<Expenses>();
    if(transaction.isActive) {
      showAlertDialog(context, true);
    }
    else if (expenseBox.length != 0){
      showAlertDialog(context, false);
    }
    else {
      transaction.delete();
       }
  }
  showAlertDialog(BuildContext context, reason) {

    String textShow = reason ? "Can not delete active session." : "Can not delete session.";
    // Create button

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert",
      style: TextStyle(color: Colors.red)),
      content: Text('$textShow'),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void makeActive(Sessions session){
    final box = Sess.getTransactions().values.where((Sessions) => Sessions.isActive == true)
        .toList().cast<Sessions>();
    session.isActive = true;
    if(box.length == 1) {
      makeInactive(Sessions, box[0]);
    }
    session.save();
  }
  void makeInactive(Sessions, session){
    session.isActive = false;
    session.save();
  }
}

