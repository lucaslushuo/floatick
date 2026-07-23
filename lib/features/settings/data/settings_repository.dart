import 'dart:convert';
import 'dart:io';

import '../../../core/storage/local_file_migration.dart';
import '../domain/app_settings.dart';

abstract interface class SettingsRepository {
  String get storagePath;

  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository({
    Directory? rootDirectory,
    Directory? legacyRootDirectory,
  }) : rootDirectory = rootDirectory ?? _defaultRootDirectory(),
       legacyRootDirectory =
           legacyRootDirectory ??
           (rootDirectory == null ? _defaultLegacyRootDirectory() : null);

  static const directoryName = '.floatick';
  static const legacyDirectoryName = '.flow2do';
  static const fileName = 'settings.json';

  final Directory rootDirectory;
  final Directory? legacyRootDirectory;

  File get _storageFile => File('${rootDirectory.path}/$fileName');

  @override
  String get storagePath => _storageFile.path;

  @override
  Future<AppSettings> load() async {
    try {
      await migrateLegacyFileIfNeeded(
        destinationDirectory: rootDirectory,
        destinationFile: _storageFile,
        legacyDirectory: legacyRootDirectory,
        fileName: fileName,
      );
      if (!await _storageFile.exists()) {
        return const AppSettings();
      }

      final decoded = jsonDecode(await _storageFile.readAsString());
      if (decoded is! Map<dynamic, dynamic>) {
        throw const FormatException(
          'Settings storage root must be a JSON object.',
        );
      }
      return AppSettings.fromJson(Map<String, dynamic>.from(decoded));
    } on FormatException catch (error) {
      throw SettingsStorageException(
        'The local settings file is damaged and was left unchanged.',
        error,
      );
    } on FileSystemException catch (error) {
      throw SettingsStorageException(
        'Floatick could not read $storagePath.',
        error,
      );
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final temporaryFile = File(
      '${_storageFile.path}.tmp-$pid-${DateTime.now().microsecondsSinceEpoch}',
    );

    try {
      await rootDirectory.create(recursive: true);
      final encoded = const JsonEncoder.withIndent(
        '  ',
      ).convert(settings.toJson());
      await temporaryFile.writeAsString('$encoded\n', flush: true);
      await temporaryFile.rename(_storageFile.path);
    } on FileSystemException catch (error) {
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
      throw SettingsStorageException(
        'Floatick could not save to $storagePath.',
        error,
      );
    }
  }

  static Directory _defaultRootDirectory() {
    final homeDirectory = Platform.environment['HOME'];
    if (homeDirectory == null || homeDirectory.trim().isEmpty) {
      throw const SettingsStorageException(
        'Floatick could not resolve the current macOS home directory.',
      );
    }
    return Directory('$homeDirectory/$directoryName');
  }

  static Directory _defaultLegacyRootDirectory() {
    final homeDirectory = Platform.environment['HOME'];
    if (homeDirectory == null || homeDirectory.trim().isEmpty) {
      throw const SettingsStorageException(
        'Floatick could not resolve the current macOS home directory.',
      );
    }
    return Directory('$homeDirectory/$legacyDirectoryName');
  }
}

class SettingsStorageException implements Exception {
  const SettingsStorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
