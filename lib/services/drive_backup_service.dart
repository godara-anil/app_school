import 'dart:io';

import 'package:app_school/services/backup_service.dart';
import 'package:app_school/services/network_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

enum DriveBackupStatus {
  success,
  signInRequired,
  noInternet,
  failed,
}

class DriveBackupResult {
  final DriveBackupStatus status;
  final String? fileName;

  const DriveBackupResult(
    this.status, {
    this.fileName,
  });

  bool get isSuccess => status == DriveBackupStatus.success;
}

class DriveBackupService {
  static const folderName = 'School Finance Backups';
  static const autoBackupPrefix = 'auto_school_finance_backup_';
  static const automaticBackupRetention = 7;

  static final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  static Future<bool> signInForBackup() async {
    return await _getSignedInUser(
          interactive: true,
        ) !=
        null;
  }

  static Future<bool> isSignedIn() async {
    return await _getSignedInUser(
          interactive: false,
        ) !=
        null;
  }

  static Future<DriveBackupResult> uploadBackup({
    bool automatic = false,
    bool allowInteractiveSignIn = true,
  }) async {
    if (!await NetworkService.hasInternetConnection()) {
      return const DriveBackupResult(
        DriveBackupStatus.noInternet,
      );
    }

    final user = await _getSignedInUser(
      interactive: allowInteractiveSignIn,
    );
    if (user == null) {
      return const DriveBackupResult(
        DriveBackupStatus.signInRequired,
      );
    }

    GoogleAuthClient? client;
    File? localBackup;

    try {
      client = GoogleAuthClient(
        await user.authHeaders,
      );
      final driveApi = drive.DriveApi(client);
      final folderId = await _getOrCreateFolderId(
        driveApi,
      );

      localBackup = await BackupService.createBackup(
        kind: automatic ? BackupKind.automatic : BackupKind.manual,
        temporary: true,
      );
      if (localBackup == null) {
        return const DriveBackupResult(
          DriveBackupStatus.failed,
        );
      }

      final fileName = localBackup.uri.pathSegments.last;
      final media = drive.Media(
        localBackup.openRead(),
        localBackup.lengthSync(),
      );
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/json'
        ..parents = [folderId]
        ..modifiedTime = DateTime.now().toUtc();

      await driveApi.files.create(
        driveFile,
        uploadMedia: media,
        $fields: 'id,name,createdTime',
      );

      if (automatic) {
        await _deleteOldAutomaticBackups(
          driveApi,
          folderId,
        );
      }

      return DriveBackupResult(
        DriveBackupStatus.success,
        fileName: fileName,
      );
    } on Object {
      return const DriveBackupResult(
        DriveBackupStatus.failed,
      );
    } finally {
      client?.close();
      if (localBackup != null && await localBackup.exists()) {
        await localBackup.delete();
      }
    }
  }

  static Future<List<drive.File>> listBackups({
    bool automaticOnly = false,
  }) async {
    GoogleAuthClient? client;

    try {
      final user = await _getSignedInUser(
        interactive: false,
      );
      if (user == null) {
        return [];
      }

      client = GoogleAuthClient(
        await user.authHeaders,
      );
      final driveApi = drive.DriveApi(client);
      final folderId = await _findFolderId(
        driveApi,
      );
      if (folderId == null) {
        return [];
      }

      final nameFilter = automaticOnly
          ? " and name contains '$autoBackupPrefix'"
          : " and name contains '.json'";
      final response = await driveApi.files.list(
        q: "'$folderId' in parents and trashed = false$nameFilter",
        spaces: 'drive',
        orderBy: 'createdTime desc',
        $fields: 'files(id,name,createdTime,modifiedTime,size,mimeType)',
      );

      return response.files ?? [];
    } on Object {
      return [];
    } finally {
      client?.close();
    }
  }

  static Future<bool> deleteBackup(
    String fileId,
  ) async {
    GoogleAuthClient? client;

    try {
      final user = await _getSignedInUser(
        interactive: false,
      );
      if (user == null) {
        return false;
      }

      client = GoogleAuthClient(
        await user.authHeaders,
      );
      await drive.DriveApi(client).files.delete(
            fileId,
          );
      return true;
    } on Object {
      return false;
    } finally {
      client?.close();
    }
  }

  static Future<File?> downloadBackup({
    required String fileId,
    required String fileName,
    required Directory destination,
  }) async {
    if (!fileName.toLowerCase().endsWith('.json')) {
      return null;
    }

    GoogleAuthClient? client;

    try {
      final user = await _getSignedInUser(
        interactive: false,
      );
      if (user == null) {
        return null;
      }

      client = GoogleAuthClient(
        await user.authHeaders,
      );
      final response = await drive.DriveApi(client).files.get(
            fileId,
            downloadOptions: drive.DownloadOptions.fullMedia,
          );

      if (response is! drive.Media) {
        return null;
      }

      final file = File(
        '${destination.path}/$fileName',
      );
      final sink = file.openWrite();
      await response.stream.pipe(sink);
      return file;
    } on Object {
      return null;
    } finally {
      client?.close();
    }
  }

  static Future<GoogleSignInAccount?> _getSignedInUser({
    required bool interactive,
  }) async {
    try {
      GoogleSignInAccount? user = googleSignIn.currentUser;
      user ??= await googleSignIn.signInSilently();

      if (user == null && interactive) {
        user = await googleSignIn.signIn();
      }

      return user;
    } on Object {
      return null;
    }
  }

  static Future<String> _getOrCreateFolderId(
    drive.DriveApi driveApi,
  ) async {
    final existingFolderId = await _findFolderId(
      driveApi,
    );
    if (existingFolderId != null) {
      return existingFolderId;
    }

    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    final createdFolder = await driveApi.files.create(
      folder,
      $fields: 'id',
    );

    if (createdFolder.id == null) {
      throw const FileSystemException(
        'Google Drive backup folder could not be created.',
      );
    }

    return createdFolder.id!;
  }

  static Future<String?> _findFolderId(
    drive.DriveApi driveApi,
  ) async {
    final response = await driveApi.files.list(
      q: "name = '$folderName' and "
          "mimeType = 'application/vnd.google-apps.folder' and "
          'trashed = false',
      spaces: 'drive',
      pageSize: 1,
      $fields: 'files(id,name)',
    );

    final folders = response.files;
    if (folders == null || folders.isEmpty) {
      return null;
    }

    return folders.first.id;
  }

  static Future<void> _deleteOldAutomaticBackups(
    drive.DriveApi driveApi,
    String folderId,
  ) async {
    final response = await driveApi.files.list(
      q: "'$folderId' in parents and trashed = false and "
          "name contains '$autoBackupPrefix'",
      spaces: 'drive',
      orderBy: 'createdTime desc',
      pageSize: 100,
      $fields: 'files(id,name,createdTime)',
    );

    final backups = response.files ?? [];
    if (backups.length <= automaticBackupRetention) {
      return;
    }

    for (final backup in backups.skip(automaticBackupRetention)) {
      if (backup.id != null &&
          backup.name?.startsWith(
                autoBackupPrefix,
              ) ==
              true) {
        await driveApi.files.delete(
          backup.id!,
        );
      }
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this.headers);

  @override
  Future<http.StreamedResponse> send(
    http.BaseRequest request,
  ) {
    request.headers.addAll(headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
