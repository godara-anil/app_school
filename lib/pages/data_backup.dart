import 'package:app_school/services/backup_service.dart';
import 'package:app_school/services/auto_backup_service.dart';
import 'package:app_school/services/background_backup_service.dart';
import 'package:app_school/services/drive_backup_service.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class DataBackupPage extends StatefulWidget {
  const DataBackupPage({super.key});

  @override
  State<DataBackupPage> createState() => _DataBackupPageState();
}

class _DataBackupPageState extends State<DataBackupPage> {
  bool isLoading = false;
  bool autoBackupEnabled = false;
  DateTime? lastSuccessfulBackup;

  @override
  void initState() {
    super.initState();
    _loadAutoBackupState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Protect your finance data',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Backups are saved as JSON files containing your '
                  'transactions, accounts, sessions, and categories.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 24),
                _buildAutoBackupCard(),
                const SizedBox(height: 24),
                _buildActionCard(
                  icon: Icons.save_alt_rounded,
                  title: 'Backup Local',
                  subtitle: 'Save JSON backup on this device',
                  onTap: backupLocal,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.share_rounded,
                  title: 'Share',
                  subtitle: 'Share backup file using WhatsApp, Drive, etc.',
                  onTap: shareBackup,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.restore_rounded,
                  title: 'Restore',
                  subtitle: 'Restore data from JSON backup',
                  onTap: restoreBackup,
                  isDestructive: true,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.cloud_upload_rounded,
                  title: 'Backup to Drive',
                  subtitle: 'Upload backup to Google Drive',
                  onTap: backupToDrive,
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: colorScheme.scrim.withValues(alpha: 0.32),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAutoBackupCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final lastBackupText = lastSuccessfulBackup == null
        ? 'Never'
        : DateFormat(
            'd MMM yyyy, h:mm a',
          ).format(lastSuccessfulBackup!);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(
        alpha: 0.45,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.cloud_sync_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Backup',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text('Backup location: Google Drive'),
                    ],
                  ),
                ),
                Switch(
                  value: autoBackupEnabled,
                  onChanged: isLoading ? null : _setAutoBackupEnabled,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 19,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Last successful backup: $lastBackupText',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading || !autoBackupEnabled ? null : backupNow,
                icon: const Icon(Icons.backup_rounded),
                label: const Text('Backup Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> backupLocal() async {
    await _runAction(() async {
      final file = await BackupService.createBackup();

      if (file == null) {
        _showMessage('Backup failed');
        return;
      }

      _showMessage(
        'JSON backup saved at:\n${file.path}',
        isSuccess: true,
      );
    });
  }

  Future<void> shareBackup() async {
    await _runAction(() async {
      final file = await BackupService.createBackup();

      if (file == null) {
        _showMessage('Backup failed');
        return;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'School Finance JSON Backup',
      );
    });
  }

  Future<void> restoreBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Restore JSON backup?'),
        content: const Text(
          'Current data will be replaced by the selected backup. '
          'Only choose a trusted School Finance JSON backup file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _runAction(() async {
      final success = await BackupService.restoreBackup();

      _showMessage(
        success
            ? 'Backup restored successfully'
            : 'Restore cancelled or the JSON backup is invalid',
        isSuccess: success,
      );
    });
  }

  Future<void> backupToDrive() async {
    await _runAction(() async {
      final result = await DriveBackupService.uploadBackup();

      _showMessage(
        result.isSuccess
            ? 'JSON backup uploaded to Google Drive'
            : _driveFailureMessage(result.status),
        isSuccess: result.isSuccess,
      );
    });
  }

  Future<void> backupNow() async {
    await _runAction(() async {
      final status = await AutoBackupService.backupNow();
      await _loadAutoBackupState();

      _showMessage(
        _autoBackupMessage(status),
        isSuccess: status == AutoBackupRunStatus.success,
      );
    });
  }

  Future<void> _setAutoBackupEnabled(
    bool enabled,
  ) async {
    await _runAction(() async {
      if (enabled) {
        final enabledSuccessfully = await BackgroundBackupService.enable();

        if (!enabledSuccessfully) {
          _showMessage(
            'Google Drive sign-in is required to enable auto backup',
          );
          return;
        }

        final status = await AutoBackupService.backupNow();
        if (status != AutoBackupRunStatus.success) {
          _showMessage(
            _autoBackupMessage(status),
          );
        }
      } else {
        await BackgroundBackupService.disable();
      }

      await _loadAutoBackupState();
    });
  }

  Future<void> _loadAutoBackupState() async {
    final enabled = await AutoBackupService.isEnabled();
    final lastBackup = await AutoBackupService.getLastSuccessfulBackup();

    if (!mounted) {
      return;
    }

    setState(() {
      autoBackupEnabled = enabled;
      lastSuccessfulBackup = lastBackup;
    });
  }

  Future<void> _runAction(
    Future<void> Function() action,
  ) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await action();
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isSuccess = false,
  }) {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? colorScheme.primary : colorScheme.error,
        ),
      );
  }

  String _driveFailureMessage(
    DriveBackupStatus status,
  ) {
    switch (status) {
      case DriveBackupStatus.signInRequired:
        return 'Google Drive sign-in is required';
      case DriveBackupStatus.noInternet:
        return 'No internet connection';
      case DriveBackupStatus.failed:
        return 'Google Drive backup could not be completed';
      case DriveBackupStatus.success:
        return 'Backup completed';
    }
  }

  String _autoBackupMessage(
    AutoBackupRunStatus status,
  ) {
    switch (status) {
      case AutoBackupRunStatus.success:
        return 'Automatic JSON backup completed';
      case AutoBackupRunStatus.noInternet:
        return 'No internet connection';
      case AutoBackupRunStatus.signInRequired:
        return 'Google Drive sign-in is required';
      case AutoBackupRunStatus.failed:
        return 'Google Drive backup could not be completed';
      case AutoBackupRunStatus.disabled:
        return 'Auto backup is turned off';
      case AutoBackupRunStatus.notDue:
        return 'The latest automatic backup is less than 24 hours old';
    }
  }
}
