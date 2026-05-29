import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_school/model/Expenses.dart';
import 'package:app_school/services/report_service.dart';
import 'package:app_school/services/session_service.dart';
import 'package:app_school/services/transaction_service.dart';

class MonthlyReportPage
    extends StatefulWidget {

  const MonthlyReportPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyReportPage>
  createState() =>
      _MonthlyReportPageState();
}

class _MonthlyReportPageState
    extends State<MonthlyReportPage> {

  late int currentSessionKey;

  @override
  void initState() {

    super.initState();

    currentSessionKey =
        SessionService
            .getActiveSessionKey();
  }

  @override
  Widget build(BuildContext context) {

    final transactions =
    TransactionService
        .getSessionTransactions(
        currentSessionKey);

    final report =
    ReportService
        .getMonthlyReport(
        transactions);

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Monthly Report",
        ),

        backgroundColor:
        Colors.green,
      ),

      body: report.isEmpty

          ? const Center(
        child: Text(
          "No Data",
        ),
      )

          : ListView.builder(

        itemCount: report.length,

        itemBuilder:
            (context, index) {

          final item =
          report[index];

          final monthParts =
          item["month"]
              .split("-");

          final year =
          int.parse(
            monthParts[0],
          );

          final month =
          int.parse(
            monthParts[1],
          );

          final monthName =
          DateFormat('MMMM yyyy')
              .format(
            DateTime(
              year,
              month,
            ),
          );

          final income =
          item["income"];

          final expense =
          item["expense"];

          final balance =
          item["balance"];

          return Card(

            margin:
            const EdgeInsets
                .symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            child: Padding(

              padding:
              const EdgeInsets.all(15),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(

                    monthName,

                    style:
                    const TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  buildRow(
                    "Income",
                    income,
                    Colors.green,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  buildRow(
                    "Expense",
                    expense,
                    Colors.red,
                  ),

                  const Divider(
                    height: 25,
                  ),

                  buildRow(
                    "Balance",
                    balance,

                    balance >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(
      String title,
      double amount,
      Color color,
      ) {

    return Row(

      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,

      children: [

        Text(

          title,

          style: const TextStyle(
            fontSize: 18,
          ),
        ),

        Text(

          amount
              .toStringAsFixed(0),

          style: TextStyle(

            fontSize: 20,

            fontWeight:
            FontWeight.bold,

            color: color,
          ),
        ),
      ],
    );
  }
}