import 'dart:convert';
import 'dart:io';

import '../../../core/storage/local_file_migration.dart';
import '../domain/todo_item.dart';

abstract interface class TodoRepository {
  String get storagePath;

  Future<List<TodoItem>> load();

  Future<void> save(List<TodoItem> items);
}

class LocalTodoRepository implements TodoRepository {
  LocalTodoRepository({
    Directory? rootDirectory,
    Directory? legacyRootDirectory,
  }) : rootDirectory = rootDirectory ?? _defaultRootDirectory(),
       legacyRootDirectory =
           legacyRootDirectory ??
           (rootDirectory == null ? _defaultLegacyRootDirectory() : null);

  static const directoryName = '.floatick';
  static const legacyDirectoryName = '.flow2do';
  static const fileName = 'todos.json';

  final Directory rootDirectory;
  final Directory? legacyRootDirectory;

  File get _storageFile => File('${rootDirectory.path}/$fileName');

  @override
  String get storagePath => _storageFile.path;

  @override
  Future<List<TodoItem>> load() async {
    try {
      await migrateLegacyFileIfNeeded(
        destinationDirectory: rootDirectory,
        destinationFile: _storageFile,
        legacyDirectory: legacyRootDirectory,
        fileName: fileName,
      );
      if (!await _storageFile.exists()) {
        return <TodoItem>[];
      }

      final decoded = jsonDecode(await _storageFile.readAsString());
      if (decoded is! List<dynamic>) {
        throw const FormatException('Todo storage root must be a JSON array.');
      }

      return decoded
          .map((entry) {
            if (entry is! Map<dynamic, dynamic>) {
              throw const FormatException('Each todo must be a JSON object.');
            }
            return TodoItem.fromJson(Map<String, dynamic>.from(entry));
          })
          .toList(growable: false);
    } on FormatException catch (error) {
      throw TodoStorageException(
        'The local todo file is damaged and was left unchanged.',
        error,
      );
    } on FileSystemException catch (error) {
      throw TodoStorageException(
        'Floatick could not read $storagePath.',
        error,
      );
    }
  }

  @override
  Future<void> save(List<TodoItem> items) async {
    final temporaryFile = File(
      '${_storageFile.path}.tmp-$pid-${DateTime.now().microsecondsSinceEpoch}',
    );

    try {
      await rootDirectory.create(recursive: true);
      final encoded = const JsonEncoder.withIndent(
        '  ',
      ).convert(items.map((item) => item.toJson()).toList(growable: false));
      await temporaryFile.writeAsString('$encoded\n', flush: true);
      await temporaryFile.rename(_storageFile.path);
    } on FileSystemException catch (error) {
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
      throw TodoStorageException(
        'Floatick could not save to $storagePath.',
        error,
      );
    }
  }

  static Directory _defaultRootDirectory() {
    final homeDirectory = Platform.environment['HOME'];
    if (homeDirectory == null || homeDirectory.trim().isEmpty) {
      throw const TodoStorageException(
        'Floatick could not resolve the current macOS home directory.',
      );
    }
    return Directory('$homeDirectory/$directoryName');
  }

  static Directory _defaultLegacyRootDirectory() {
    final homeDirectory = Platform.environment['HOME'];
    if (homeDirectory == null || homeDirectory.trim().isEmpty) {
      throw const TodoStorageException(
        'Floatick could not resolve the current macOS home directory.',
      );
    }
    return Directory('$homeDirectory/$legacyDirectoryName');
  }
}

class TodoStorageException implements Exception {
  const TodoStorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
