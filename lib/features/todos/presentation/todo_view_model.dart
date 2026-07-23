import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/storage/storage_failure.dart';
import '../data/todo_repository.dart';
import '../domain/todo_item.dart';

typedef TodoClock = DateTime Function();
typedef TodoIdGenerator = String Function();

class TodoViewModel extends ChangeNotifier {
  TodoViewModel({
    required TodoRepository todoRepository,
    TodoClock? clock,
    TodoIdGenerator? idGenerator,
  }) : _repository = todoRepository,
       _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator ?? _generateUuidV4;

  final TodoRepository _repository;
  final TodoClock _clock;
  final TodoIdGenerator _idGenerator;

  List<TodoItem> _items = <TodoItem>[];
  StorageFailure? _error;
  bool _isLoading = false;
  Future<void> _mutationQueue = Future<void>.value();

  List<TodoItem> get items => List<TodoItem>.unmodifiable(_items);
  StorageFailure? get error => _error;
  bool get isLoading => _isLoading;
  String get storageDirectoryPath => File(_repository.storagePath).parent.path;

  int get activeCount {
    return _items.where((item) => !item.isArchived && !item.isCompleted).length;
  }

  int get archivedCount => _items.where((item) => item.isArchived).length;

  List<TodoItem> itemsForView({required bool archived, required String query}) {
    final normalizedQuery = query.trim().toLowerCase();
    final visibleItems = _items.where((item) {
      final matchesScope = archived ? item.isArchived : !item.isArchived;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          item.title.toLowerCase().contains(normalizedQuery);
      return matchesScope && matchesQuery;
    }).toList();

    DateTime relevantDate(TodoItem item) {
      if (archived) {
        return item.archivedAt ?? item.createdAt;
      }
      return item.createdAt;
    }

    visibleItems.sort((left, right) {
      return relevantDate(right).compareTo(relevantDate(left));
    });
    return List<TodoItem>.unmodifiable(visibleItems);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.load();
    } on StorageFailure catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(String title) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      return Future<void>.value();
    }

    return _enqueueMutation((currentItems) {
      return <TodoItem>[
        ...currentItems,
        TodoItem(
          id: _idGenerator(),
          title: normalizedTitle,
          createdAt: _clock().toUtc(),
        ),
      ];
    });
  }

  Future<void> toggleCompletion(String id) {
    return _updateItem(id, (item) {
      return item.withCompletedAt(item.isCompleted ? null : _clock().toUtc());
    });
  }

  Future<bool> rename(String id, String title) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      return false;
    }

    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex == -1) {
      return false;
    }
    final existingItem = _items[existingIndex];
    if (existingItem.title == normalizedTitle) {
      return true;
    }

    await _updateItem(id, (item) => item.withTitle(normalizedTitle));
    return _items.any((item) => item.id == id && item.title == normalizedTitle);
  }

  Future<void> archive(String id) {
    return _updateItem(id, (item) => item.withArchivedAt(_clock().toUtc()));
  }

  Future<void> restore(String id) {
    return _updateItem(id, (item) => item.withArchivedAt(null));
  }

  void dismissError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }

  Future<void> _updateItem(String id, TodoItem Function(TodoItem item) update) {
    return _enqueueMutation((currentItems) {
      final index = currentItems.indexWhere((item) => item.id == id);
      if (index == -1) {
        return currentItems;
      }

      final updatedItems = List<TodoItem>.of(currentItems);
      updatedItems[index] = update(updatedItems[index]);
      return updatedItems;
    });
  }

  Future<void> _enqueueMutation(
    List<TodoItem> Function(List<TodoItem> currentItems) update,
  ) {
    final operation = _mutationQueue.then((_) => _commit(update));
    _mutationQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _commit(
    List<TodoItem> Function(List<TodoItem> currentItems) update,
  ) async {
    final currentItems = List<TodoItem>.of(_items);
    final updatedItems = update(currentItems);
    if (listEquals(updatedItems, _items)) {
      return;
    }

    try {
      await _repository.save(updatedItems);
      _items = updatedItems;
      _error = null;
    } on StorageFailure catch (error) {
      _error = error;
    }
    notifyListeners();
  }

  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
