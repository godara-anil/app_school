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

        "backupVersion": 2,

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

            "key": a.key,
            "name": a.name,
            "type": a.type,
            "openingBalance":
            a.openingBalance,
          };

        }).toList(),

        "sessions": sessions.map((s) {

          return {

            "key": s.key,
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

      final sessionData =
      List<dynamic>.from(
        data['sessions'] ?? [],
      );

      final accountData =
      List<dynamic>.from(
        data['accounts'] ?? [],
      );

      final expenseData =
      List<dynamic>.from(
        data['expenses'] ?? [],
      );

      final sourceSessionKeys =
      _getSourceKeys(sessionData);

      final sourceAccountKeys =
      _getSourceKeys(accountData);

      _validateTransactionReferences(
        expenses: expenseData,
        sessionKeys: sourceSessionKeys,
        accountKeys: sourceAccountKeys,
      );

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

      final sessionKeyMap = <int, int>{};

      for (var i = 0; i < sessionData.length; i++) {

        final s = sessionData[i];

        final session = Sessions()

          ..session = s['session']
          ..isActive = s['isActive']
          ..isLocked =
              s['isLocked'] ?? false;

        final newKey =
        await Sess.getTransactions()
            .add(session);

        sessionKeyMap[
          sourceSessionKeys[i]
        ] = newKey;
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

      final accountKeyMap = <int, int>{};

      for (var i = 0; i < accountData.length; i++) {

        final a = accountData[i];

        final account = Account(
          name: a['name'],
          openingBalance:
          (a['openingBalance'] ?? 0)
              .toDouble(),
          type: a['type'],
        );

        final newKey =
        await AccountsBox
            .getAccounts()
            .add(account);

        accountKeyMap[
          sourceAccountKeys[i]
        ] = newKey;
      }

      // RESTORE TRANSACTIONS

      for (var e in expenseData) {

        final oldSessionKey =
        _readInt(e['sessionKey']);

        final oldAccountKey =
        _readInt(e['accountId']);

        final newSessionKey =
        oldSessionKey == null
            ? null
            : sessionKeyMap[oldSessionKey];

        final newAccountKey =
        accountKeyMap[oldAccountKey];

        if (oldSessionKey != null &&
            newSessionKey == null) {
          throw const FormatException(
            'Could not restore a transaction session relationship.',
          );
        }

        if (newAccountKey == null) {
          throw const FormatException(
            'Could not restore a transaction account relationship.',
          );
        }

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
          ..sessionKey = newSessionKey
          ..accountId = newAccountKey
              .toString()
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

  static List<int> _getSourceKeys(
      List<dynamic> records,
      ) {

    final keys = <int>[];
    final seenKeys = <int>{};

    for (var i = 0; i < records.length; i++) {

      final record = records[i];
      final key =
      _readInt(record['key']) ?? i;

      if (!seenKeys.add(key)) {
        throw const FormatException(
          'Backup contains duplicate record keys.',
        );
      }

      keys.add(key);
    }

    return keys;
  }

  static void _validateTransactionReferences({
    required List<dynamic> expenses,
    required List<int> sessionKeys,
    required List<int> accountKeys,
  }) {

    final validSessionKeys =
    sessionKeys.toSet();

    final validAccountKeys =
    accountKeys.toSet();

    for (final expense in expenses) {

      final sessionKey =
      _readInt(expense['sessionKey']);

      final accountKey =
      _readInt(expense['accountId']);

      if (sessionKey != null &&
          !validSessionKeys.contains(
            sessionKey,
          )) {
        throw const FormatException(
          'A transaction references a missing session.',
        );
      }

      if (accountKey == null ||
          !validAccountKeys.contains(
            accountKey,
          )) {
        throw const FormatException(
          'A transaction references a missing account.',
        );
      }
    }
  }

  static int? _readInt(
      dynamic value,
      ) {

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }
}
