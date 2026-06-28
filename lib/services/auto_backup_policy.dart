class AutoBackupPolicy {
  static const backupInterval = Duration(hours: 24);

  static bool isDue({
    required bool enabled,
    required DateTime? lastSuccessfulBackup,
    required DateTime now,
  }) {
    if (!enabled) {
      return false;
    }

    if (lastSuccessfulBackup == null) {
      return true;
    }

    return now.difference(lastSuccessfulBackup) >= backupInterval;
  }
}
