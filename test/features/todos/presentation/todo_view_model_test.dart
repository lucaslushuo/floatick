import 'package:floatick/core/storage/storage_failure.dart';
import 'package:floatick/features/todos/data/todo_repository.dart';
import 'package:floatick/features/todos/domain/todo_item.dart';
import 'package:floatick/features/todos/presentation/todo_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const firstDate = '2026-07-23T02:00:00.000Z';
  late _MemoryTodoRepository repository;
  late TodoViewModel controller;
  late int idSequence;

  setUp(() {
    repository = _MemoryTodoRepository();
    idSequence = 0;
    controller = TodoViewModel(
      todoRepository: repository,
      clock: () => DateTime.parse(firstDate),
      idGenerator: () => 'todo-${++idSequence}',
    );
  });

  test('add trims the title and persists before exposing state', () async {
    await controller.load();
    await controller.add('  Write focused tests  ');

    expect(controller.items.single.title, 'Write focused tests');
    expect(controller.items.single.createdAt, DateTime.parse(firstDate));
    expect(repository.savedItems, controller.items);
    expect(controller.activeCount, 1);
  });

  test('blank titles are ignored', () async {
    await controller.load();
    await controller.add('   ');

    expect(controller.items, isEmpty);
    expect(repository.saveCount, 0);
  });

  test(
    'itemsForView filters scope and query, then sorts newest first',
    () async {
      repository.savedItems = <TodoItem>[
        TodoItem(
          id: 'older-active',
          title: 'Write architecture notes',
          createdAt: DateTime.parse('2026-07-21T12:00:00.000Z'),
        ),
        TodoItem(
          id: 'newer-active',
          title: 'Polish release workflow',
          createdAt: DateTime.parse('2026-07-23T12:00:00.000Z'),
        ),
        TodoItem(
          id: 'archived',
          title: 'Archived architecture draft',
          createdAt: DateTime.parse('2026-07-20T12:00:00.000Z'),
          archivedAt: DateTime.parse('2026-07-24T12:00:00.000Z'),
        ),
      ];
      await controller.load();

      expect(
        controller
            .itemsForView(archived: false, query: '')
            .map((item) => item.id),
        <String>['newer-active', 'older-active'],
      );
      expect(
        controller
            .itemsForView(archived: false, query: 'ARCHITECTURE')
            .map((item) => item.id),
        <String>['older-active'],
      );
      expect(
        controller.itemsForView(archived: true, query: '').single.id,
        'archived',
      );
    },
  );

  test('rename trims and persists the updated title', () async {
    repository.savedItems = <TodoItem>[
      TodoItem(
        id: 'existing',
        title: 'Original title',
        createdAt: DateTime.parse(firstDate),
      ),
    ];
    await controller.load();

    final didRename = await controller.rename('existing', '  Updated title  ');

    expect(didRename, isTrue);
    expect(controller.items.single.title, 'Updated title');
    expect(repository.savedItems.single.title, 'Updated title');
    expect(repository.saveCount, 1);
  });

  test('rename rejects blank or missing items without persisting', () async {
    repository.savedItems = <TodoItem>[
      TodoItem(
        id: 'existing',
        title: 'Original title',
        createdAt: DateTime.parse(firstDate),
      ),
    ];
    await controller.load();

    expect(await controller.rename('existing', '   '), isFalse);
    expect(await controller.rename('missing', 'Updated title'), isFalse);
    expect(controller.items.single.title, 'Original title');
    expect(repository.saveCount, 0);
  });

  test('a failed rename keeps the original title', () async {
    repository.savedItems = <TodoItem>[
      TodoItem(
        id: 'existing',
        title: 'Original title',
        createdAt: DateTime.parse(firstDate),
      ),
    ];
    await controller.load();
    repository.failNextSave = true;

    final didRename = await controller.rename('existing', 'Updated title');

    expect(didRename, isFalse);
    expect(controller.items.single.title, 'Original title');
    expect(controller.error?.kind, StorageFailureKind.write);
  });

  test(
    'completion, archive, and restore share one persisted state flow',
    () async {
      repository.savedItems = <TodoItem>[
        TodoItem(
          id: 'existing',
          title: 'Ship it',
          createdAt: DateTime.parse(firstDate),
        ),
      ];
      await controller.load();

      await controller.toggleCompletion('existing');
      expect(controller.items.single.isCompleted, isTrue);
      expect(controller.activeCount, 0);

      await controller.archive('existing');
      expect(controller.items.single.isArchived, isTrue);
      expect(controller.archivedCount, 1);

      await controller.restore('existing');
      expect(controller.items.single.isArchived, isFalse);
      expect(controller.archivedCount, 0);
      expect(repository.saveCount, 3);
    },
  );

  test(
    'a failed save keeps visible state unchanged and queue usable',
    () async {
      await controller.load();
      repository.failNextSave = true;

      await controller.add('Will fail');

      expect(controller.items, isEmpty);
      expect(controller.error?.kind, StorageFailureKind.write);

      await controller.add('Will succeed');

      expect(controller.items.single.title, 'Will succeed');
      expect(controller.error, isNull);
    },
  );
}

class _MemoryTodoRepository implements TodoRepository {
  List<TodoItem> savedItems = <TodoItem>[];
  int saveCount = 0;
  bool failNextSave = false;

  @override
  String get storagePath => '/tmp/floatick-test/todos.json';

  @override
  Future<List<TodoItem>> load() async {
    return List<TodoItem>.of(savedItems);
  }

  @override
  Future<void> save(List<TodoItem> items) async {
    saveCount += 1;
    if (failNextSave) {
      failNextSave = false;
      throw const StorageFailure(kind: StorageFailureKind.write);
    }
    savedItems = List<TodoItem>.of(items);
  }
}
