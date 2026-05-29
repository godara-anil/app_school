import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:app_school/services/backup_service.dart';
import 'package:app_school/services/drive_backup_service.dart';

class DataBackupPage extends StatefulWidget {

  const DataBackupPage({Key? key})
      : super(key: key);

  @override
  State<DataBackupPage> createState() =>
      _DataBackupPageState();
}

class _DataBackupPageState
    extends State<DataBackupPage> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Backup & Restore"),
        backgroundColor: Colors.green,
      ),

      body: Center(

        child: Padding(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              buildButton(
                title: "Store Locally",
                icon: Icons.backup,
                color: Colors.green,
                onTap: storeLocal,
              ),

              const SizedBox(height: 20),
              buildButton(
                title: "Share Backup",
                icon: Icons.backup,
                color: Colors.green,
                onTap: createBackup,
              ),

              const SizedBox(height: 20),

              buildButton(
                title: "Restore Backup",
                icon: Icons.restore,
                color: Colors.blue,
                onTap: restoreBackup,
              ),

              const SizedBox(height: 20),

              buildButton(
                title: "Drive Backup",
                icon: Icons.restore,
                color: Colors.purple,
                onTap: driveBackup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton({

    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,

  }) {

    return SizedBox(

      width: double.infinity,
      height: 60,

      child: ElevatedButton.icon(

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),

        onPressed:
        isLoading ? null : onTap,

        icon: Icon(icon),

        label: Text(
          title,

          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // CREATE BACKUP

  Future<void> createBackup() async {

    setState(() {
      isLoading = true;
    });

    try {

      final file =
      await BackupService.createBackup();

      if (file == null) {

        showMessage(
          "Backup Failed",
          Colors.red,
        );

        return;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "School Backup File",
      );

      showMessage(
        "Backup Created Successfully",
        Colors.green,
      );

    } catch (e) {

      showMessage(
        "Something went wrong",
        Colors.red,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // RESTORE BACKUP

  Future<void> restoreBackup() async {

    final confirm =
    await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title:
          const Text("Restore Backup"),

          content: const Text(
            "Current data will be replaced. Continue?",
          ),

          actions: [

            TextButton(
              onPressed: () {

                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
              const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {

                Navigator.pop(
                  context,
                  true,
                );
              },

              child:
              const Text("Restore"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isLoading = true;
    });

    try {

      final success =
      await BackupService.restoreBackup();

      if (success) {

        showMessage(
          "Backup Restored Successfully",
          Colors.green,
        );

      } else {

        showMessage(
          "Restore Failed",
          Colors.red,
        );
      }

    } catch (e) {

      showMessage(
        "Something went wrong",
        Colors.red,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // local storage

  Future<void> storeLocal() async {

    final file =
    await BackupService.createBackup();

    if (file != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Backup saved at:\n${file.path}",
          ),
        ),
      );
    }
  }

  // drive backup

  Future<void> driveBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success =
    await DriveBackupService
        .uploadBackup();

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(

          success

              ? "Backup uploaded to Google Drive"

              : "Google Drive backup failed",
        ),
      ),
    );
  }

  void showMessage(
      String message,
      Color color,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        backgroundColor: color,

        content: Text(message),
      ),
    );
  }
}