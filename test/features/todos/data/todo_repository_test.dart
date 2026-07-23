import 'dart:convert';
import 'dart:io';

import 'package:floatick/features/todos/data/todo_repository.dart';
import 'package:floatick/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late LocalTodoRepository repository;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'floatick-repository-test-',
    );
    repository = LocalTodoRepository(
      rootDirectory: Directory('${temporaryDirectory.path}/.floatick'),
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'missing storage creates the directory and returns an empty list',
    () async {
      final items = await repository.load();

      expect(items, isEmpty);
      expect(await repository.rootDirectory.exists(), isTrue);
    },
  );

  test('save and load preserve the Swift-compatible JSON schema', () async {
    final item = TodoItem(
      id: 'todo-1',
      title: 'Finish the Flutter shell',
      createdAt: DateTime.utc(2026, 7, 23, 6, 30),
      completedAt: DateTime.utc(2026, 7, 23, 7),
    );

    await repository.save(<TodoItem>[item]);
    final loadedItems = await repository.load();
    final json = jsonDecode(await File(repository.storagePath).readAsString());

    expect(loadedItems, <TodoItem>[item]);
    expect(json, <Object?>[
      <String, Object?>{
        'id': 'todo-1',
        'title': 'Finish the Flutter shell',
        'createdAt': '2026-07-23T06:30:00.000Z',
        'completedAt': '2026-07-23T07:00:00.000Z',
      },
    ]);
  });

  test('damaged storage is reported and left unchanged', () async {
    await repository.rootDirectory.create(recursive: true);
    final file = File(repository.storagePath);
    const damagedContent = '{"not": "a todo list"}';
    await file.writeAsString(damagedContent);

    await expectLater(
      repository.load(),
      throwsA(
        isA<TodoStorageException>().having(
          (error) => error.message,
          'message',
          contains('damaged'),
        ),
      ),
    );
    expect(await file.readAsString(), damagedContent);
  });

  test('legacy storage moves to Floatick without losing todos', () async {
    final legacyDirectory = Directory('${temporaryDirectory.path}/.flow2do');
    final destinationDirectory = Directory(
      '${temporaryDirectory.path}/.floatick',
    );
    final legacyFile = File('${legacyDirectory.path}/todos.json');
    await legacyDirectory.create(recursive: true);
    await legacyFile.writeAsString(
      jsonEncode(<Object?>[
        <String, Object?>{
          'id': 'legacy-todo',
          'title': 'Keep existing data',
          'createdAt': '2026-07-23T06:30:00.000Z',
        },
      ]),
    );
    repository = LocalTodoRepository(
      rootDirectory: destinationDirectory,
      legacyRootDirectory: legacyDirectory,
    );

    final items = await repository.load();

    expect(items.single.id, 'legacy-todo');
    expect(repository.storagePath, '${destinationDirectory.path}/todos.json');
    expect(await File(repository.storagePath).exists(), isTrue);
    expect(await legacyFile.exists(), isFalse);
  });

  test(
    'existing Floatick storage is never overwritten by legacy data',
    () async {
      final legacyDirectory = Directory('${temporaryDirectory.path}/.flow2do');
      final destinationDirectory = Directory(
        '${temporaryDirectory.path}/.floatick',
      );
      final legacyFile = File('${legacyDirectory.path}/todos.json');
      final destinationFile = File('${destinationDirectory.path}/todos.json');
      await legacyDirectory.create(recursive: true);
      await destinationDirectory.create(recursive: true);
      await legacyFile.writeAsString(
        jsonEncode(<Object?>[
          <String, Object?>{
            'id': 'legacy-todo',
            'title': 'Legacy',
            'createdAt': '2026-07-23T06:30:00.000Z',
          },
        ]),
      );
      await destinationFile.writeAsString(
        jsonEncode(<Object?>[
          <String, Object?>{
            'id': 'current-todo',
            'title': 'Current',
            'createdAt': '2026-07-24T06:30:00.000Z',
          },
        ]),
      );
      repository = LocalTodoRepository(
        rootDirectory: destinationDirectory,
        legacyRootDirectory: legacyDirectory,
      );

      final items = await repository.load();

      expect(items.single.id, 'current-todo');
      expect(await legacyFile.exists(), isTrue);
    },
  );
}
