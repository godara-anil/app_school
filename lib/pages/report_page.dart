import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_school/model/Expenses.dart';
import 'package:app_school/services/report_service.dart';
import 'package:app_school/services/session_service.dart';
import 'package:app_school/services/transaction_service.dart';

class ReportPage extends StatefulWidget {

  const ReportPage({Key? key})
      : super(key: key);

  @override
  State<ReportPage> createState() =>
      _ReportPageState();
}

class _ReportPageState
    extends State<ReportPage> {

  late int currentSessionKey;

  bool isExpense = true;

  DateTimeRange? selectedDateRange;

  @override
  void initState() {

    super.initState();

    currentSessionKey =
        SessionService
            .getActiveSessionKey();
  }

  Future<void> pickDateRange() async {

    final result =
    await showDateRangePicker(

      context: context,

      firstDate: DateTime(2020),

      lastDate: DateTime.now(),

      currentDate: DateTime.now(),
    );

    if (result != null) {

      setState(() {

        selectedDateRange = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Expenses> transactions =
    TransactionService
        .getSessionTransactions(
        currentSessionKey);

    if (selectedDateRange != null) {

      transactions =
          transactions.where((tx) {

            return tx.date.isAfter(
              selectedDateRange!
                  .start
                  .subtract(
                const Duration(days: 1),
              ),
            ) &&
                tx.date.isBefore(
                  selectedDateRange!
                      .end
                      .add(
                    const Duration(days: 1),
                  ),
                );
          }).toList();
    }

    final reportData =
    isExpense

        ? ReportService
        .getCategoryWiseExpense(
        transactions)

        : ReportService
        .getCategoryWiseIncome(
        transactions);

    double total = 0;

    for (var amount
    in reportData.values) {

      total += amount;
    }

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Reports",
        ),

        backgroundColor:
        Colors.green,
      ),

      body: Column(

        children: [

          const SizedBox(height: 15),

          buildDateButton(),

          const SizedBox(height: 10),

          buildChoiceChips(),

          const SizedBox(height: 10),

          Expanded(

            child: reportData.isEmpty

                ? const Center(
              child: Text(
                "No Data",
              ),
            )

                : ListView.builder(

              itemCount:
              reportData.length,

              itemBuilder:
                  (context, index) {

                final key =
                reportData.keys
                    .elementAt(index);

                final value =
                reportData[key]!;

                return Card(

                  margin:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),

                  child: ListTile(

                    title: Text(
                      key,
                    ),

                    trailing: Text(

                      value
                          .toStringAsFixed(0),

                      style: TextStyle(

                        fontWeight:
                        FontWeight.bold,

                        fontSize: 18,

                        color:
                        isExpense
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(

            padding:
            const EdgeInsets.all(15),

            color: Colors.black12,

            child: Row(

              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

              children: [

                const Text(

                  "TOTAL",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                Text(

                  total.toStringAsFixed(0),

                  style: TextStyle(

                    fontSize: 22,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    isExpense
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateButton() {

    String text = "Select Date Range";

    if (selectedDateRange != null) {

      text =
      "${DateFormat('d MMM').format(selectedDateRange!.start)}"
          " - "
          "${DateFormat('d MMM').format(selectedDateRange!.end)}";
    }

    return TextButton.icon(

      onPressed: pickDateRange,

      icon:
      const Icon(Icons.calendar_month),

      label: Text(text),
    );
  }

  Widget buildChoiceChips() {

    return Row(

      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [

        ChoiceChip(

          label: const Text(
            "Income",
          ),

          selected: !isExpense,

          onSelected: (val) {

            setState(() {

              isExpense = false;
            });
          },
        ),

        const SizedBox(width: 15),

        ChoiceChip(

          label: const Text(
            "Expense",
          ),

          selected: isExpense,

          onSelected: (val) {

            setState(() {

              isExpense = true;
            });
          },
        ),
      ],
    );
  }
}