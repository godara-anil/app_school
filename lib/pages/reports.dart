import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../boxes.dart';
import '../model/Expenses.dart';
import 'package:app_school/getActiveSession.dart';


class reports extends StatefulWidget {
  const reports({Key? key}) : super(key: key);
  @override
  State<reports> createState() => _reportsState();
}

class _reportsState extends State<reports> {
  final currentSessionKey = getActiveSession.getSession()[0].key;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        backgroundColor: Colors.green[700],
      ),
      body: ValueListenableBuilder<Box<Expenses>>(
        valueListenable: Boxes.getTransactions().listenable(),
        builder: (context, box, _) {
          final transactions = box.values.where((Expenses) => Expenses.isExpense == true)
                 .where((Expenses) => Expenses.sessionKey == currentSessionKey)
             // .where((Expenses) => Expenses.date.isAfter(startDate))
             // .where((Expenses) => Expenses.date.isBefore(endDate))
              .toList().cast<Expenses>();
          return buildContent(transactions);
        },
      ),
    );
  }
  Widget buildContent(List<Expenses> transactions){
        var gpData = groupData(transactions);
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text('Category Wise Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red
              ),),
              SizedBox(height: 24,),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: gpData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final transaction = gpData[index];
                    return buildList(context, transaction);
                  },
                ),
              )
            ],
          ),
        );
  }
  Widget buildList(BuildContext context, data){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data['category'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.red
              ),
            ),
            Text(data['amount'].toStringAsFixed(0),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.red
              ),),
          ],
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(height: 20,)
      ],
    );
  }
  groupData(data) {
    var groupedData = [];
    data.forEach((element) {
      if(groupedData.length == 0){
        groupedData.add({'category' : element.category, 'amount' : element.amount});
      }
      else  {
        final index = groupedData.indexWhere((e) =>
        e['category'] == element.category);
        if(index != -1) {
          groupedData[index]['amount'] += element.amount;
        }
        else {
          groupedData.add({'category' : element.category, 'amount' : element.amount});

        }
      }
    });
    groupedData.sort((b, a )=> b['category'].compareTo(a['category']));
    return groupedData;
  }
}
