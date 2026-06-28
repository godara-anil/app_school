import 'package:app_school/services/auto_backup_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(
    2026,
    6,
    18,
    12,
  );

  test('auto backup off never runs', () {
    expect(
      AutoBackupPolicy.isDue(
        enabled: false,
        lastSuccessfulBackup: now.subtract(
          const Duration(days: 2),
        ),
        now: now,
      ),
      isFalse,
    );
  });

  test('auto backup with no previous success is due', () {
    expect(
      AutoBackupPolicy.isDue(
        enabled: true,
        lastSuccessfulBackup: null,
        now: now,
      ),
      isTrue,
    );
  });

  test('backup newer than 24 hours is skipped', () {
    expect(
      AutoBackupPolicy.isDue(
        enabled: true,
        lastSuccessfulBackup: now.subtract(
          const Duration(hours: 23),
        ),
        now: now,
      ),
      isFalse,
    );
  });

  test('backup at least 24 hours old is due', () {
    expect(
      AutoBackupPolicy.isDue(
        enabled: true,
        lastSuccessfulBackup: now.subtract(
          const Duration(hours: 24),
        ),
        now: now,
      ),
      isTrue,
    );
  });
}
