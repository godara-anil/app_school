import 'package:app_school/services/app_database_service.dart';
import 'package:app_school/services/auto_backup_policy.dart';
import 'package:app_school/services/drive_backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AutoBackupRunStatus {
  success,
  disabled,
  notDue,
  noInternet,
  signInRequired,
  failed,
}

class AutoBackupService {
  static const _enabledKey = 'auto_drive_backup_enabled';
  static const _lastSuccessKey = 'auto_drive_backup_last_success';
  static const _lastErrorKey = 'auto_drive_backup_last_error';

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static Future<bool> isEnabled() async {
    return await _preferences.getBool(
          _enabledKey,
        ) ??
        false;
  }

  static Future<void> setEnabled(
    bool enabled,
  ) async {
    await _preferences.setBool(
      _enabledKey,
      enabled,
    );

    if (!enabled) {
      await clearLastError();
    }
  }

  static Future<DateTime?> getLastSuccessfulBackup() async {
    final value = await _preferences.getString(
      _lastSuccessKey,
    );
    return value == null
        ? null
        : DateTime.tryParse(
            value,
          )?.toLocal();
  }

  static Future<String?> getLastError() {
    return _preferences.getString(
      _lastErrorKey,
    );
  }

  static Future<void> clearLastError() {
    return _preferences.remove(
      _lastErrorKey,
    );
  }

  static Future<AutoBackupRunStatus> runDueBackup() async {
    final enabled = await isEnabled();
    final lastSuccessfulBackup = await getLastSuccessfulBackup();

    if (!AutoBackupPolicy.isDue(
      enabled: enabled,
      lastSuccessfulBackup: lastSuccessfulBackup,
      now: DateTime.now(),
    )) {
      return enabled
          ? AutoBackupRunStatus.notDue
          : AutoBackupRunStatus.disabled;
    }

    return _runAutomaticBackup(
      allowInteractiveSignIn: false,
    );
  }

  static Future<AutoBackupRunStatus> backupNow() {
    return _runAutomaticBackup(
      allowInteractiveSignIn: true,
    );
  }

  static Future<AutoBackupRunStatus> _runAutomaticBackup({
    required bool allowInteractiveSignIn,
  }) async {
    await AppDatabaseService.initialize();

    final result = await DriveBackupService.uploadBackup(
      automatic: true,
      allowInteractiveSignIn: allowInteractiveSignIn,
    );

    switch (result.status) {
      case DriveBackupStatus.success:
        await _preferences.setString(
          _lastSuccessKey,
          DateTime.now().toUtc().toIso8601String(),
        );
        await clearLastError();
        return AutoBackupRunStatus.success;
      case DriveBackupStatus.signInRequired:
        await _storeError(
          'Google Drive sign-in is required',
        );
        return AutoBackupRunStatus.signInRequired;
      case DriveBackupStatus.noInternet:
        await _storeError(
          'No internet connection',
        );
        return AutoBackupRunStatus.noInternet;
      case DriveBackupStatus.failed:
        await _storeError(
          'Google Drive backup failed',
        );
        return AutoBackupRunStatus.failed;
    }
  }

  static Future<void> _storeError(
    String message,
  ) {
    return _preferences.setString(
      _lastErrorKey,
      '${DateTime.now().toUtc().toIso8601String()}|$message',
    );
  }
}
