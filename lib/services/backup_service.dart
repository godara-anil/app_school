import 'dart:convert';
import 'dart:io';

import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/model/category_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

enum BackupKind {
  manual,
  automatic,
  safety,
}

class BackupService {
  static const backupVersion = 2;

  static String buildFileName({
    required DateTime createdAt,
    required BackupKind kind,
  }) {
    final timestamp = DateFormat(
      'yyyy_MM_dd_HH_mm',
    ).format(createdAt);

    switch (kind) {
      case BackupKind.automatic:
        return 'auto_school_finance_backup_$timestamp.json';
      case BackupKind.safety:
        return 'safety_school_finance_backup_$timestamp.json';
      case BackupKind.manual:
        return 'school_finance_backup_$timestamp.json';
    }
  }

  static Future<File?> createBackup({
    BackupKind kind = BackupKind.manual,
    bool temporary = false,
  }) async {
    try {
      final createdAt = DateTime.now();
      final packageInfo = await PackageInfo.fromPlatform();
      final backupData = _buildBackupData(
        createdAt: createdAt,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        kind: kind,
      );

      final jsonData = const JsonEncoder.withIndent(
        '  ',
      ).convert(backupData);

      final directory = temporary
          ? await getTemporaryDirectory()
          : await getExternalStorageDirectory();

      if (directory == null) {
        return null;
      }

      final file = File(
        '${directory.path}/${buildFileName(createdAt: createdAt, kind: kind)}',
      );

      await file.writeAsString(
        jsonData,
        flush: true,
      );

      return file;
    } on Object {
      return null;
    }
  }

  static Future<bool> restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      allowMultiple: false,
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      return false;
    }

    return restoreFromFile(
      File(result.files.single.path!),
    );
  }

  static Future<bool> restoreFromFile(
    File sourceFile,
  ) async {
    File? safetyBackup;

    try {
      if (!sourceFile.path.toLowerCase().endsWith('.json')) {
        return false;
      }

      final sourceData = _readBackupData(
        await sourceFile.readAsString(),
      );

      _validateBackupData(sourceData);

      safetyBackup = await createBackup(
        kind: BackupKind.safety,
        temporary: true,
      );

      if (safetyBackup == null) {
        return false;
      }

      await _replaceData(sourceData);
      return true;
    } on Object {
      if (safetyBackup != null) {
        await _tryRestoreSafetyBackup(
          safetyBackup,
        );
      }
      return false;
    }
  }

  static Map<String, dynamic> _buildBackupData({
    required DateTime createdAt,
    required String appVersion,
    required String appBuildNumber,
    required BackupKind kind,
  }) {
    final expenses = Boxes.getTransactions().values.toList();
    final accounts = AccountsBox.getAccounts().values.toList();
    final sessions = Sess.getTransactions().values.toList();
    final categories = CategoryBox.getCategories().values.toList();

    return {
      'backupVersion': backupVersion,
      'metadata': {
        'appVersion': appVersion,
        'appBuildNumber': appBuildNumber,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'backupType': kind.name,
      },
      'expenses': expenses.map((expense) {
        return {
          'amount': expense.amount,
          'category': expense.category,
          'date': expense.date.toIso8601String(),
          'isExpense': expense.isExpense,
          'sessionKey': expense.sessionKey,
          'accountId': expense.accountId,
          'remarks': expense.remarks,
          'transferId': expense.transferId,
        };
      }).toList(),
      'accounts': accounts.map((account) {
        return {
          'key': account.key,
          'name': account.name,
          'type': account.type,
          'openingBalance': account.openingBalance,
        };
      }).toList(),
      'sessions': sessions.map((session) {
        return {
          'key': session.key,
          'session': session.session,
          'isActive': session.isActive,
          'isLocked': session.isLocked,
        };
      }).toList(),
      'categories': categories.map((category) {
        return {
          'name': category.name,
          'isExpense': category.isExpense,
          'isActive': category.isActive,
          'createdAt': category.createdAt.toIso8601String(),
        };
      }).toList(),
    };
  }

  static Future<void> _replaceData(
    Map<String, dynamic> data,
  ) async {
    final sessionData = List<dynamic>.from(
      data['sessions'],
    );
    final accountData = List<dynamic>.from(
      data['accounts'],
    );
    final expenseData = List<dynamic>.from(
      data['expenses'],
    );
    final categoryData = List<dynamic>.from(
      data['categories'],
    );

    final sourceSessionKeys = _getSourceKeys(
      sessionData,
    );
    final sourceAccountKeys = _getSourceKeys(
      accountData,
    );

    _validateTransactionReferences(
      expenses: expenseData,
      sessionKeys: sourceSessionKeys,
      accountKeys: sourceAccountKeys,
    );

    await Boxes.getTransactions().clear();
    await AccountsBox.getAccounts().clear();
    await Sess.getTransactions().clear();
    await CategoryBox.getCategories().clear();

    final sessionKeyMap = <int, int>{};
    for (var index = 0; index < sessionData.length; index++) {
      final record = sessionData[index];
      final session = Sessions()
        ..session = record['session']
        ..isActive = record['isActive']
        ..isLocked = record['isLocked'] ?? false;

      final newKey = await Sess.getTransactions().add(
        session,
      );
      sessionKeyMap[sourceSessionKeys[index]] = newKey;
    }

    for (final record in categoryData) {
      final category = Category(
        name: record['name'],
        isExpense: record['isExpense'],
        isActive: record['isActive'],
      )..createdAt = DateTime.parse(
          record['createdAt'],
        );

      await CategoryBox.getCategories().add(
        category,
      );
    }

    final accountKeyMap = <int, int>{};
    for (var index = 0; index < accountData.length; index++) {
      final record = accountData[index];
      final account = Account(
        name: record['name'],
        openingBalance: (record['openingBalance'] as num).toDouble(),
        type: record['type'],
      );

      final newKey = await AccountsBox.getAccounts().add(
        account,
      );
      accountKeyMap[sourceAccountKeys[index]] = newKey;
    }

    for (final record in expenseData) {
      final oldSessionKey = _readInt(
        record['sessionKey'],
      );
      final oldAccountKey = _readInt(
        record['accountId'],
      );

      final newSessionKey =
          oldSessionKey == null ? null : sessionKeyMap[oldSessionKey];
      final newAccountKey = accountKeyMap[oldAccountKey];

      if (oldSessionKey != null && newSessionKey == null) {
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
        ..amount = (record['amount'] as num).toDouble()
        ..category = record['category']
        ..date = DateTime.parse(record['date'])
        ..isExpense = record['isExpense']
        ..sessionKey = newSessionKey
        ..accountId = newAccountKey.toString()
        ..remarks = record['remarks']
        ..transferId = record['transferId'];

      await Boxes.getTransactions().add(
        expense,
      );
    }

    await Boxes.getTransactions().flush();
    await AccountsBox.getAccounts().flush();
    await Sess.getTransactions().flush();
    await CategoryBox.getCategories().flush();
  }

  static Future<void> _tryRestoreSafetyBackup(
    File safetyBackup,
  ) async {
    try {
      final data = _readBackupData(
        await safetyBackup.readAsString(),
      );
      _validateBackupData(data);
      await _replaceData(data);
    } on Object {
      // The original restore result remains a failure.
    }
  }

  static Map<String, dynamic> _readBackupData(
    String jsonString,
  ) {
    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Backup must be a JSON object.',
      );
    }

    return decoded;
  }

  static void _validateBackupData(
    Map<String, dynamic> data,
  ) {
    const requiredLists = [
      'expenses',
      'accounts',
      'sessions',
      'categories',
    ];

    for (final field in requiredLists) {
      final records = data[field];
      if (records is! List ||
          records.any(
            (record) => record is! Map,
          )) {
        throw FormatException(
          'Backup field "$field" is invalid.',
        );
      }
    }

    final sessions = List<dynamic>.from(
      data['sessions'],
    );
    final accounts = List<dynamic>.from(
      data['accounts'],
    );
    final categories = List<dynamic>.from(
      data['categories'],
    );
    final expenses = List<dynamic>.from(
      data['expenses'],
    );

    for (final session in sessions) {
      if (session['session'] is! String ||
          session['isActive'] is! bool ||
          (session['isLocked'] != null && session['isLocked'] is! bool)) {
        throw const FormatException(
          'Backup contains an invalid session.',
        );
      }
    }

    for (final account in accounts) {
      if (account['name'] is! String ||
          account['type'] is! String ||
          account['openingBalance'] is! num) {
        throw const FormatException(
          'Backup contains an invalid account.',
        );
      }
    }

    for (final category in categories) {
      if (category['name'] is! String ||
          category['isExpense'] is! bool ||
          category['isActive'] is! bool ||
          !_isValidDate(category['createdAt'])) {
        throw const FormatException(
          'Backup contains an invalid category.',
        );
      }
    }

    for (final expense in expenses) {
      if (expense['amount'] is! num ||
          expense['category'] is! String ||
          expense['isExpense'] is! bool ||
          !_isValidDate(expense['date']) ||
          (expense['remarks'] != null && expense['remarks'] is! String) ||
          (expense['transferId'] != null && expense['transferId'] is! String)) {
        throw const FormatException(
          'Backup contains an invalid transaction.',
        );
      }
    }

    _validateTransactionReferences(
      expenses: expenses,
      sessionKeys: _getSourceKeys(sessions),
      accountKeys: _getSourceKeys(accounts),
    );
  }

  static List<int> _getSourceKeys(
    List<dynamic> records,
  ) {
    final keys = <int>[];
    final seenKeys = <int>{};

    for (var index = 0; index < records.length; index++) {
      final key = _readInt(
            records[index]['key'],
          ) ??
          index;

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
    final validSessionKeys = sessionKeys.toSet();
    final validAccountKeys = accountKeys.toSet();

    for (final expense in expenses) {
      final sessionKey = _readInt(
        expense['sessionKey'],
      );
      final accountKey = _readInt(
        expense['accountId'],
      );

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

  static bool _isValidDate(
    dynamic value,
  ) {
    return value is String &&
        DateTime.tryParse(
              value,
            ) !=
            null;
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
