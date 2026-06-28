import 'dart:ui';

import 'package:app_school/services/auto_backup_service.dart';
import 'package:app_school/services/drive_backup_service.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

const autoBackupTaskName = 'automaticGoogleDriveBackup';
const autoBackupUniqueName = 'schoolFinanceDailyDriveBackup';

@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != autoBackupTaskName) {
      return true;
    }

    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final status = await AutoBackupService.runDueBackup();
    return status != AutoBackupRunStatus.failed;
  });
}

class BackgroundBackupService {
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        backupCallbackDispatcher,
        isInDebugMode: false,
      );
      await syncSchedule();
    } on Object {
      // App launch/resume checks remain available if scheduling is unavailable.
    }
  }

  static Future<bool> enable() async {
    final signedIn = await DriveBackupService.signInForBackup();
    if (!signedIn) {
      return false;
    }

    await AutoBackupService.setEnabled(true);
    await schedule();
    return true;
  }

  static Future<void> disable() async {
    await AutoBackupService.setEnabled(false);
    await Workmanager().cancelByUniqueName(
      autoBackupUniqueName,
    );
  }

  static Future<void> syncSchedule() async {
    if (await AutoBackupService.isEnabled()) {
      await schedule();
    } else {
      await Workmanager().cancelByUniqueName(
        autoBackupUniqueName,
      );
    }
  }

  static Future<void> schedule() {
    return Workmanager().registerPeriodicTask(
      autoBackupUniqueName,
      autoBackupTaskName,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
    );
  }
}
