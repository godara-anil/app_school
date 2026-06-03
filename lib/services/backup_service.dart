import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/model/category_model.dart';
import 'package:app_school/boxes.dart';

class BackupService {

  // EXPORT BACKUP
  static Future<File?> createBackup() async {

    try {

      final expenses =
      Boxes.getTransactions()
          .values
          .toList();

      final accounts =
      AccountsBox.getAccounts()
          .values
          .toList();

      final sessions =
      Sess.getTransactions()
          .values
          .toList();

      final categories =
      CategoryBox.getCategories()
          .values
          .toList();

      final backupData = {

        "expenses": expenses.map((e) {

          return {

            "amount": e.amount,
            "category": e.category,
            "date": e.date.toIso8601String(),
            "isExpense": e.isExpense,
            "sessionKey": e.sessionKey,
            "accountId": e.accountId,
            "remarks": e.remarks,
          };

        }).toList(),

        "accounts": accounts.map((a) {

          return {

            "name": a.name,
            "type": a.type,
            "openingBalance":
            a.openingBalance,
          };

        }).toList(),

        "sessions": sessions.map((s) {

          return {

            "session": s.session,
            "isActive": s.isActive,
            "isLocked": s.isLocked,

          };

        }).toList(),

        "categories": categories.map((c) {

          return {

            "name": c.name,
            "isExpense": c.isExpense,
            "isActive": c.isActive,
            "createdAt":
            c.createdAt.toIso8601String(),

          };

        }).toList(),
      };

      final jsonData =
      const JsonEncoder.withIndent('  ')
          .convert(backupData);

      final directory =
      await getExternalStorageDirectory();

      final file = File(
        "${directory!.path}/school_backup.json",
      );

      await file.writeAsString(jsonData);

      return file;

    } catch (e) {

      print(e);

      return null;
    }
  }

  // RESTORE BACKUP
  static Future<bool> restoreBackup() async {

    try {

      FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        return false;
      }

      final file =
      File(result.files.single.path!);

      final jsonString =
      await file.readAsString();

      final data =
      jsonDecode(jsonString);

      // CLEAR OLD DATA

      await Boxes.getTransactions().flush();
      await AccountsBox.getAccounts().flush();
      await Sess.getTransactions().flush();
      await CategoryBox.getCategories().flush();

      await Boxes.getTransactions().clear();
      await AccountsBox.getAccounts().clear();
      await Sess.getTransactions().clear();
      await CategoryBox.getCategories().clear();

      // RESTORE SESSIONS

      for (var s in data['sessions']) {

        final session = Sessions()

          ..session = s['session']
          ..isActive = s['isActive']
          ..isLocked =
              s['isLocked'] ?? false;

        await Sess.getTransactions()
            .add(session);
      }

      // RESTORE CATEGORIES

      for (var c in data['categories'] ?? []) {

        final category = Category(
          name: c['name'],
          isExpense: c['isExpense'],
          isActive: c['isActive'] ?? true,
        );

        category.createdAt =
            DateTime.parse(
              c['createdAt'],
            );

        await CategoryBox
            .getCategories()
            .add(category);
      }

      // RESTORE ACCOUNTS

      for (var a in data['accounts']) {

        final account = Account(
          name: a['name'],
          openingBalance:
          (a['openingBalance'] ?? 0)
              .toDouble(),
          type: a['type'],
        );

        await AccountsBox
            .getAccounts()
            .add(account);
      }

      // RESTORE TRANSACTIONS

      for (var e in data['expenses']) {

        final expense = Expenses()

          ..amount =
          (e['amount'] ?? 0)
              .toDouble()
          ..category = e['category']
          ..date =
          DateTime.parse(
            e['date'],
          )
          ..isExpense = e['isExpense']
          ..sessionKey = e['sessionKey']
          ..accountId = e['accountId']
          ..remarks = e['remarks'];

        await Boxes
            .getTransactions()
            .add(expense);
      }

      return true;

    } catch (e) {

      print(e);

      return false;
    }
  }
}