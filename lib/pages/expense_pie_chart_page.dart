import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:app_school/boxes.dart';

import 'package:app_school/model/Expenses.dart';

import 'package:app_school/services/report_service.dart';

class ExpensePieChartPage extends StatefulWidget {

  const ExpensePieChartPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ExpensePieChartPage> createState() =>
      _ExpensePieChartPageState();
}

class _ExpensePieChartPageState
    extends State<ExpensePieChartPage> {

  DateTime selectedMonth =
  DateTime.now();

  @override
  Widget build(BuildContext context) {

    final allTransactions =
    Boxes.getTransactions()
        .values
        .toList()
        .cast<Expenses>();

    final transactions =
    allTransactions.where((tx) {

      return

        tx.isExpense &&

            tx.date.month ==
                selectedMonth.month &&

            tx.date.year ==
                selectedMonth.year;

    }).toList();

    final data =
    ReportService
        .getCategoryWiseExpense(
      transactions,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Expense Analytics',
        ),

        backgroundColor:
        Colors.green,
      ),

      body: data.isEmpty

          ? const Center(

        child: Text(

          'No Expense Data',

          style: TextStyle(
            fontSize: 20,
          ),
        ),
      )

          : SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.calendar_month,
                  color: Colors.green,
                ),

                title: const Text(
                  'Selected Month',
                ),

                subtitle: Text(
                  '${selectedMonth.month}-${selectedMonth.year}',
                ),

                trailing: TextButton(

                  onPressed: () async {

                    final picked =
                    await showDatePicker(

                      context: context,

                      initialDate:
                      selectedMonth,

                      firstDate:
                      DateTime(2020),

                      lastDate:
                      DateTime.now(),

                      initialDatePickerMode:
                      DatePickerMode.year,
                    );

                    if (picked != null) {

                      setState(() {

                        selectedMonth = picked;
                      });
                    }
                  },

                  child: const Text(
                    'Change',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              height: 300,

              child: PieChart(

                PieChartData(

                  sectionsSpace: 3,

                  centerSpaceRadius: 50,

                  sections:
                  buildPieSections(
                    data,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Align(

              alignment:
              Alignment.centerLeft,

              child: const Text(

                "Category Breakdown",

                style: TextStyle(

                  fontSize: 20,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            ...buildLegend(data),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData>
  buildPieSections(
      Map<String, double> data,
      ) {

    final colors = [

      Colors.red,

      Colors.blue,

      Colors.orange,

      Colors.green,

      Colors.purple,

      Colors.teal,

      Colors.pink,

      Colors.brown,
    ];

    final total =
    data.values.fold(
      0.0,
          (a, b) => a + b,
    );

    int index = 0;

    return data.entries.map((entry) {

      final color =
      colors[
      index % colors.length
      ];

      index++;

      final percentage =
          (entry.value / total) * 100;

      return PieChartSectionData(

        color: color,

        value: entry.value,

        title:
        '${percentage.toStringAsFixed(1)}%',

        radius: 90,

        titleStyle:
        const TextStyle(

          fontSize: 14,

          fontWeight:
          FontWeight.bold,

          color: Colors.white,
        ),
      );

    }).toList();
  }

  List<Widget> buildLegend(
      Map<String, double> data,
      ) {

    final colors = [

      Colors.red,

      Colors.blue,

      Colors.orange,

      Colors.green,

      Colors.purple,

      Colors.teal,

      Colors.pink,

      Colors.brown,
    ];

    int index = 0;

    return data.entries.map((entry) {

      final color =
      colors[
      index % colors.length
      ];

      index++;

      return Card(

        margin:
        const EdgeInsets.only(
          bottom: 10,
        ),

        child: ListTile(

          leading: CircleAvatar(
            backgroundColor: color,
          ),

          title: Text(
            entry.key,
          ),

          trailing: Text(

            entry.value
                .toStringAsFixed(0),

            style: const TextStyle(

              fontWeight:
              FontWeight.bold,

              fontSize: 16,
            ),
          ),
        ),
      );

    }).toList();
  }
}