import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../model/Expenses.dart';

class PdfService {

  static Future<void> exportAccountLedger({
    required String accountName,
    required String sessionName,
    required double openingBalance,
    required double totalIncome,
    required double totalExpense,
    required double transferBalance,
    required double currentBalance,
    required List<Expenses> transactions,
  }) async {

    final pdf = pw.Document();

    // Load logo
    final ByteData imageData =
    await rootBundle.load(
      'lib/assets/logo.png',
    );

    final Uint8List logoBytes =
    imageData.buffer.asUint8List();

    final logo =
    pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(

        pageFormat:
        PdfPageFormat.a4,

        margin:
        const pw.EdgeInsets.all(24),

        build: (context) => [

          /// HEADER
          pw.Center(

            child: pw.Column(

              children: [

                pw.Image(
                  logo,
                  width: 70,
                  height: 70,
                ),

                pw.SizedBox(height: 10),

                pw.Text(
                  'SWAMI VIVEKANAND SR SEC SCHOOL',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                ),

                pw.Text(
                  'Keharwala',
                ),

                pw.Text(
                  'Mob. 9467738220',
                ),

                pw.SizedBox(height: 15),

                pw.Text(
                  'ACCOUNT LEDGER REPORT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          /// REPORT INFO

          pw.Row(
            mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
            children: [

              pw.Text(
                'Session : $sessionName',
              ),

              pw.Text(
                'Account : $accountName',
              ),
            ],
          ),

          pw.Divider(),

          /// SUMMARY

          pw.Container(

            padding:
            const pw.EdgeInsets.all(10),

            child: pw.Column(

              children: [

                buildSummaryRow(
                  'Opening Balance',
                  openingBalance,
                ),

                buildSummaryRow(
                  'Total Income',
                  totalIncome,
                ),

                buildSummaryRow(
                  'Total Expense',
                  totalExpense,
                ),

                buildSummaryRow(
                  'Transfer Balance',
                  transferBalance,
                ),

                pw.Divider(),

                buildSummaryRow(
                  'Current Balance',
                  currentBalance,
                  isBold: true,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          /// TRANSACTION TABLE

          pw.TableHelper.fromTextArray(

            headers: [

              'Date',
              'Particulars',
              'Income',
              'Expense',
            ],

            data: transactions.map((tx) {

              return [

                tx.date
                    .toString()
                    .substring(0, 10),

                tx.category,

                tx.isExpense
                    ? ''
                    : tx.amount
                    .toStringAsFixed(0),

                tx.isExpense
                    ? tx.amount
                    .toStringAsFixed(0)
                    : '',
              ];

            }).toList(),
          ),
        ],
      ),
    );

    await Printing.sharePdf(

      bytes:
      await pdf.save(),

      filename:
      '${accountName}_Ledger.pdf',
    );
  }

  static pw.Widget buildSummaryRow(
      String title,
      double value, {
        bool isBold = false,
      }) {

    return pw.Padding(

      padding:
      const pw.EdgeInsets.symmetric(
        vertical: 3,
      ),

      child: pw.Row(

        mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,

        children: [

          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight:
              isBold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),

          pw.Text(
            '₹ ${value.toStringAsFixed(0)}',
            style: pw.TextStyle(
              fontWeight:
              isBold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}