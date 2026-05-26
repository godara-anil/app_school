import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_school/model/Expenses.dart';
import 'package:app_school/services/account_service.dart';

class TransactionTile extends StatelessWidget {

  final Expenses transaction;

  final Widget? children;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final color =
    transaction.isExpense
        ? Colors.red
        : Colors.green;

    final date =
    DateFormat.yMMMd()
        .format(transaction.date);

    final amount =
    transaction.amount
        .toStringAsFixed(0);

    final accountName =
    AccountService.getAccountName(
      transaction.accountId,
    );

    return Card(
      color: Colors.white,

      child: ExpansionTile(

        tilePadding:
        const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),

        title: Text(
          transaction.category,

          maxLines: 2,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        subtitle: Text(date),

        trailing: Column(
          crossAxisAlignment:
          CrossAxisAlignment.end,

          children: [

            Text(
              amount,

              style: TextStyle(
                color: color,
                fontWeight:
                FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius:
                BorderRadius.circular(8),
              ),

              padding:
              const EdgeInsets.all(5),

              child: Text(
                accountName,

                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        children: children != null
            ? [children!]
            : [],
      ),
    );
  }
}