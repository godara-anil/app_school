import 'package:flutter/material.dart';

import 'package:app_school/pages/report_page.dart';
import 'package:app_school/pages/monthly_report_page.dart';
import 'package:app_school/pages/account_report_page.dart';
import 'package:app_school/pages/expense_pie_chart_page.dart';

class ReportsHomePage
    extends StatelessWidget {

  const ReportsHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Reports & Analytics",
        ),

        backgroundColor:
        Colors.green,
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(12),

        child: GridView.count(

          crossAxisCount: 2,

          crossAxisSpacing: 12,

          mainAxisSpacing: 12,

          children: [

            buildTile(

              context: context,

              title:
              "Category Report",

              icon:
              Icons.category,

              color:
              Colors.red,

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const ReportPage(),
                  ),
                );
              },
            ),

            buildTile(

              context: context,

              title:
              "Monthly Report",

              icon:
              Icons.calendar_month,

              color:
              Colors.blue,

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const MonthlyReportPage(),
                  ),
                );
              },
            ),

            buildTile(

              context: context,

              title:
              "Account Report",

              icon:
              Icons.account_balance_wallet,

              color:
              Colors.green,

              onTap: () {
                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const AccountReportPage(),
                  ),
                );
              },
            ),

            buildTile(

              context: context,

              title:
              "Charts & Analytics",

              icon:
              Icons.pie_chart,

              color:
              Colors.purple,

              onTap: () {
                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const ExpensePieChartPage(),
                  ),
                );
              },
            ),

            buildTile(

              context: context,

              title:
              "Export PDF",

              icon:
              Icons.picture_as_pdf,

              color:
              Colors.orange,

              onTap: () {

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(

                  const SnackBar(
                    content: Text(
                      "Coming Soon",
                    ),
                  ),
                );
              },
            ),

            buildTile(

              context: context,

              title:
              "Export Excel",

              icon:
              Icons.table_chart,

              color:
              Colors.teal,

              onTap: () {

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(

                  const SnackBar(
                    content: Text(
                      "Coming Soon",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile({

    required BuildContext context,

    required String title,

    required IconData icon,

    required Color color,

    required VoidCallback onTap,
  }) {

    return InkWell(

      onTap: onTap,

      borderRadius:
      BorderRadius.circular(20),

      child: Container(

        decoration: BoxDecoration(

          color:
          color.withOpacity(0.12),

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color:
            color.withOpacity(0.5),
          ),
        ),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(

              icon,

              size: 50,

              color: color,
            ),

            const SizedBox(
              height: 15,
            ),

            Text(

              title,

              textAlign:
              TextAlign.center,

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                FontWeight.bold,

                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}