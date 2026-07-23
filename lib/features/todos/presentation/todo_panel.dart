import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/platform/window_bridge.dart';
import '../../../core/ui/floatick_brand_mark.dart';
import '../../settings/presentation/settings_drawer.dart';
import '../../settings/presentation/settings_view_model.dart';
import '../domain/todo_item.dart';
import 'todo_view_model.dart';

const double _panelWindowInset = 8;
const double _panelOuterRadius = 26;
const double _panelContentRadius = 25;
const double _settingsDrawerWidth = 268;
const Duration _settingsDrawerDuration = Duration(milliseconds: 220);
const Duration _settingsScrimDuration = Duration(milliseconds: 160);

enum TodoListScope { active, archived }

class TodoPanel extends StatefulWidget {
  const TodoPanel({
    required this.controller,
    required this.settingsController,
    required this.windowBridge,
    required this.onCollapse,
    super.key,
  });

  final TodoViewModel controller;
  final SettingsViewModel settingsController;
  final WindowBridge windowBridge;
  final VoidCallback onCollapse;

  @override
  State<TodoPanel> createState() => _TodoPanelState();
}

class _TodoPanelState extends State<TodoPanel> {
  final _composerController = TextEditingController();
  final _searchController = TextEditingController();
  final _composerFocusNode = FocusNode();
  final _searchFocusNode = FocusNode();
  final _settingsCloseFocusNode = FocusNode();

  TodoListScope _scope = TodoListScope.active;
  String _query = '';
  bool _isAdding = false;
  bool _isSettingsOpen = false;

  @override
  void dispose() {
    _composerController.dispose();
    _searchController.dispose();
    _composerFocusNode.dispose();
    _searchFocusNode.dispose();
    _settingsCloseFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    if (_isAdding || _composerController.text.trim().isEmpty) {
      return;
    }

    final previousLength = widget.controller.items.length;
    setState(() => _isAdding = true);
    await widget.controller.add(_composerController.text);
    if (!mounted) {
      return;
    }

    if (widget.controller.items.length > previousLength) {
      _composerController.clear();
      _composerFocusNode.requestFocus();
    }
    setState(() => _isAdding = false);
  }

  void _openSettings() {
    if (_isSettingsOpen) {
      return;
    }

    setState(() => _isSettingsOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isSettingsOpen) {
        _settingsCloseFocusNode.requestFocus();
      }
    });
  }

  void _closeSettings() {
    if (!_isSettingsOpen) {
      return;
    }

    _settingsCloseFocusNode.unfocus();
    setState(() => _isSettingsOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): _CollapseIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, meta: true): _SearchIntent(),
        SingleActivator(LogicalKeyboardKey.keyN, meta: true): _NewTodoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _CollapseIntent: CallbackAction<_CollapseIntent>(
            onInvoke: (_) {
              if (_isSettingsOpen) {
                _closeSettings();
              } else {
                widget.onCollapse();
              }
              return null;
            },
          ),
          _SearchIntent: CallbackAction<_SearchIntent>(
            onInvoke: (_) {
              _searchFocusNode.requestFocus();
              return null;
            },
          ),
          _NewTodoIntent: CallbackAction<_NewTodoIntent>(
            onInvoke: (_) {
              if (_scope != TodoListScope.active) {
                setState(() => _scope = TodoListScope.active);
              }
              _composerFocusNode.requestFocus();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: FocusTraversalGroup(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: 440,
                height: 700,
                padding: const EdgeInsets.all(_panelWindowInset),
                child: DecoratedBox(
                  key: const Key('todo-panel-surface'),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xF2172024)
                        : const Color(0xF7FAFCFB),
                    borderRadius: BorderRadius.circular(_panelOuterRadius),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_panelContentRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ExcludeFocus(
                          excluding: _isSettingsOpen,
                          child: AnimatedBuilder(
                            animation: widget.controller,
                            builder: (context, _) {
                              return Column(
                                children: <Widget>[
                                  _PanelHeader(
                                    activeCount: widget.controller.activeCount,
                                    onOpenSettings: _openSettings,
                                    onCollapse: widget.onCollapse,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      12,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        _ScopePicker(
                                          scope: _scope,
                                          activeCount:
                                              widget.controller.activeCount,
                                          archivedCount:
                                              widget.controller.archivedCount,
                                          reduceMotion: reduceMotion,
                                          onChanged: (scope) {
                                            setState(() => _scope = scope);
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          key: const Key('search-field'),
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          onChanged: (value) {
                                            setState(
                                              () => _query = value.trim(),
                                            );
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                _scope == TodoListScope.active
                                                ? '搜索待办'
                                                : '搜索归档',
                                            prefixIcon: const Icon(
                                              Icons.search_rounded,
                                              size: 19,
                                            ),
                                            suffixIcon: _query.isEmpty
                                                ? null
                                                : IconButton(
                                                    tooltip: '清除搜索',
                                                    onPressed: () {
                                                      _searchController.clear();
                                                      setState(
                                                        () => _query = '',
                                                      );
                                                      _searchFocusNode
                                                          .requestFocus();
                                                    },
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                      size: 18,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        if (_scope == TodoListScope.active) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: TextField(
                                                  key: const Key('todo-input'),
                                                  controller:
                                                      _composerController,
                                                  focusNode: _composerFocusNode,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  onSubmitted: (_) =>
                                                      unawaited(_addTodo()),
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText: '添加一件要完成的事…',
                                                        prefixIcon: Icon(
                                                          Icons.add_rounded,
                                                          size: 20,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 9),
                                              _AddButton(
                                                isAdding: _isAdding,
                                                onPressed: () =>
                                                    unawaited(_addTodo()),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (widget.controller.errorMessage != null)
                                    _ErrorBanner(
                                      message: widget.controller.errorMessage!,
                                      onDismiss: widget.controller.dismissError,
                                    ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.black.withValues(alpha: 0.055),
                                  ),
                                  Expanded(
                                    child: _TodoList(
                                      controller: widget.controller,
                                      scope: _scope,
                                      query: _query,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: !_isSettingsOpen,
                            child: ExcludeSemantics(
                              excluding: !_isSettingsOpen,
                              child: AnimatedOpacity(
                                key: const Key('settings-drawer-scrim'),
                                duration: reduceMotion
                                    ? Duration.zero
                                    : _settingsScrimDuration,
                                curve: Curves.easeOut,
                                opacity: _isSettingsOpen ? 1 : 0,
                                child: GestureDetector(
                                  key: const Key('settings-drawer-dismiss'),
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _closeSettings,
                                  child: ColoredBox(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.22 : 0.12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          width: _settingsDrawerWidth,
                          child: IgnorePointer(
                            key: const Key('settings-drawer-pointer'),
                            ignoring: !_isSettingsOpen,
                            child: ExcludeSemantics(
                              excluding: !_isSettingsOpen,
                              child: AnimatedSlide(
                                key: const Key('settings-drawer-slide'),
                                duration: reduceMotion
                                    ? Duration.zero
                                    : _settingsDrawerDuration,
                                curve: Curves.easeOutCubic,
                                offset: _isSettingsOpen
                                    ? Offset.zero
                                    : const Offset(1, 0),
                                child: FocusTraversalGroup(
                                  child: SettingsDrawer(
                                    viewModel: widget.settingsController,
                                    workingDirectoryPath:
                                        widget.controller.storageDirectoryPath,
                                    onClose: _closeSettings,
                                    closeFocusNode: _settingsCloseFocusNode,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.activeCount,
    required this.onOpenSettings,
    required this.onCollapse,
  });

  final int activeCount;
  final VoidCallback onOpenSettings;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
      child: Row(
        children: <Widget>[
          const _MiniMark(),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              activeCount == 0 ? '今天已经清空' : '$activeCount 项待完成',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.53),
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            key: const Key('settings-button'),
            tooltip: '设置',
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined, size: 19),
          ),
          IconButton(
            tooltip: '收起（Esc）',
            onPressed: onCollapse,
            icon: const Icon(Icons.unfold_less_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MiniMark extends StatelessWidget {
  const _MiniMark();

  @override
  Widget build(BuildContext context) {
    return const FloatickBrandMark(key: ValueKey('panel-brand-mark'), size: 38);
  }
}

class _ScopePicker extends StatelessWidget {
  const _ScopePicker({
    required this.scope,
    required this.activeCount,
    required this.archivedCount,
    required this.reduceMotion,
    required this.onChanged,
  });

  final TodoListScope scope;
  final int activeCount;
  final int archivedCount;
  final bool reduceMotion;
  final ValueChanged<TodoListScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.black.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: <Widget>[
          _ScopeButton(
            label: '待办',
            count: activeCount,
            selected: scope == TodoListScope.active,
            reduceMotion: reduceMotion,
            onPressed: () => onChanged(TodoListScope.active),
          ),
          _ScopeButton(
            label: '归档',
            count: archivedCount,
            selected: scope == TodoListScope.archived,
            reduceMotion: reduceMotion,
            onPressed: () => onChanged(TodoListScope.archived),
          ),
        ],
      ),
    );
  }
}

class _ScopeButton extends StatelessWidget {
  const _ScopeButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.reduceMotion,
    required this.onPressed,
  });

  final String label;
  final int count;
  final bool selected;
  final bool reduceMotion;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? (isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: selected && !isDark
                    ? <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '$label  $count',
                style: TextStyle(
                  color: selected
                      ? onSurface
                      : onSurface.withValues(alpha: 0.55),
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.isAdding, required this.onPressed});

  final bool isAdding;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '添加待办',
      child: IconButton.filled(
        key: const Key('add-todo'),
        tooltip: '添加待办（Return）',
        onPressed: isAdding ? null : onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size.square(42),
          maximumSize: const Size.square(42),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.45),
        ),
        icon: isAdding
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.arrow_upward_rounded, size: 19),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            tooltip: '关闭',
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, size: 17),
          ),
        ],
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({
    required this.controller,
    required this.scope,
    required this.query,
  });

  final TodoViewModel controller;
  final TodoListScope scope;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final entries = _buildEntries();
    if (entries.isEmpty) {
      return _EmptyList(scope: scope, hasQuery: query.isNotEmpty);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return switch (entry) {
          _DateEntry() => _DateDivider(label: entry.label),
          _ItemEntry() => _TodoRow(
            key: ValueKey<String>(entry.item.id),
            item: entry.item,
            archivedScope: scope == TodoListScope.archived,
            onToggle: () =>
                unawaited(controller.toggleCompletion(entry.item.id)),
            onRename: (title) => controller.rename(entry.item.id, title),
            onArchive: () => unawaited(controller.archive(entry.item.id)),
            onRestore: () => unawaited(controller.restore(entry.item.id)),
          ),
        };
      },
    );
  }

  List<_ListEntry> _buildEntries() {
    final archived = scope == TodoListScope.archived;
    final items = controller.itemsForView(archived: archived, query: query);

    DateTime relevantDate(TodoItem item) {
      if (archived) {
        return (item.archivedAt ?? item.createdAt).toLocal();
      }
      return item.createdAt.toLocal();
    }

    final entries = <_ListEntry>[];
    DateTime? previousDay;
    for (final item in items) {
      final date = relevantDate(item);
      final day = DateTime(date.year, date.month, date.day);
      if (day != previousDay) {
        entries.add(_DateEntry(_formatDay(day)));
        previousDay = day;
      }
      entries.add(_ItemEntry(item));
    }
    return entries;
  }
}

sealed class _ListEntry {
  const _ListEntry();
}

class _DateEntry extends _ListEntry {
  const _DateEntry(this.label);

  final String label;
}

class _ItemEntry extends _ListEntry {
  const _ItemEntry(this.item);

  final TodoItem item;
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.48);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 13, 8, 7),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(height: 1, color: color.withValues(alpha: 0.2)),
          ),
        ],
      ),
    );
  }
}

class _TodoRow extends StatefulWidget {
  const _TodoRow({
    required this.item,
    required this.archivedScope,
    required this.onToggle,
    required this.onRename,
    required this.onArchive,
    required this.onRestore,
    super.key,
  });

  final TodoItem item;
  final bool archivedScope;
  final VoidCallback onToggle;
  final Future<bool> Function(String title) onRename;
  final VoidCallback onArchive;
  final VoidCallback onRestore;

  @override
  State<_TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends State<_TodoRow> {
  late final TextEditingController _editController;
  late final FocusNode _editFocusNode;
  late final FocusNode _rowFocusNode;

  bool _isHovered = false;
  bool _hasFocus = false;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.item.title);
    _editFocusNode = FocusNode();
    _rowFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _TodoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.item.title != widget.item.title) {
      _editController.text = widget.item.title;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    _rowFocusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    _editController.text = widget.item.title;
    setState(() => _isEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isEditing) {
        return;
      }
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _editController.text.length,
      );
    });
  }

  void _cancelEditing() {
    if (_isSaving) {
      return;
    }
    _editController.text = widget.item.title;
    setState(() => _isEditing = false);
    _rowFocusNode.requestFocus();
  }

  Future<void> _saveEditing() async {
    final normalizedTitle = _editController.text.trim();
    if (_isSaving || normalizedTitle.isEmpty) {
      return;
    }
    if (normalizedTitle == widget.item.title) {
      setState(() => _isEditing = false);
      _rowFocusNode.requestFocus();
      return;
    }

    setState(() => _isSaving = true);
    final didSave = await widget.onRename(normalizedTitle);
    if (!mounted) {
      return;
    }
    setState(() {
      _isSaving = false;
      if (didSave) {
        _isEditing = false;
      }
    });
    if (didSave) {
      _rowFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final showEditAction = _isHovered || _hasFocus || _isEditing;
    final canSave =
        !_isSaving &&
        _editController.text.trim().isNotEmpty &&
        _editController.text.trim() != item.title;

    return Focus(
      focusNode: _rowFocusNode,
      onFocusChange: (hasFocus) {
        if (_hasFocus != hasFocus) {
          setState(() => _hasFocus = hasFocus);
        }
      },
      child: Semantics(
        container: true,
        label: item.title,
        value: item.isCompleted ? '已完成' : '未完成',
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.fromLTRB(7, 8, 5, 8),
            decoration: BoxDecoration(
              color: _isHovered || _isEditing
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.055)
                        : Colors.black.withValues(alpha: 0.035))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: <Widget>[
                if (!widget.archivedScope)
                  Tooltip(
                    message: item.isCompleted ? '标记为未完成' : '标记为已完成',
                    child: Semantics(
                      button: true,
                      checked: item.isCompleted,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isEditing ? null : widget.onToggle,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedContainer(
                              duration: reduceMotion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 160),
                              width: 21,
                              height: 21,
                              decoration: BoxDecoration(
                                color: item.isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: item.isCompleted
                                      ? Theme.of(context).colorScheme.primary
                                      : onSurface.withValues(alpha: 0.28),
                                  width: 1.4,
                                ),
                              ),
                              child: item.isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 21,
                      color: onSurface.withValues(alpha: 0.28),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (_isEditing)
                        Shortcuts(
                          shortcuts: const <ShortcutActivator, Intent>{
                            SingleActivator(LogicalKeyboardKey.escape):
                                _CancelTodoEditIntent(),
                          },
                          child: Actions(
                            actions: <Type, Action<Intent>>{
                              _CancelTodoEditIntent:
                                  CallbackAction<_CancelTodoEditIntent>(
                                    onInvoke: (_) {
                                      _cancelEditing();
                                      return null;
                                    },
                                  ),
                            },
                            child: TextField(
                              key: ValueKey<String>(
                                'todo-edit-${widget.item.id}',
                              ),
                              controller: _editController,
                              focusNode: _editFocusNode,
                              enabled: !_isSaving,
                              maxLines: 1,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => unawaited(_saveEditing()),
                              style: TextStyle(
                                color: onSurface.withValues(alpha: 0.94),
                                fontSize: 13.5,
                                height: 1.3,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 7,
                                ),
                                hintText: '待办内容不能为空',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Text(
                          item.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: onSurface.withValues(
                              alpha: item.isCompleted ? 0.45 : 0.91,
                            ),
                            fontSize: 13.5,
                            height: 1.3,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: onSurface.withValues(alpha: 0.42),
                          ),
                        ),
                      const SizedBox(height: 3),
                      Text(
                        _formatTime(
                          widget.archivedScope
                              ? (item.archivedAt ?? item.createdAt)
                              : item.createdAt,
                        ),
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.35),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox.square(
                        dimension: 34,
                        child: _isEditing
                            ? IconButton(
                                key: ValueKey<String>(
                                  'save-todo-${widget.item.id}',
                                ),
                                tooltip: '保存',
                                onPressed: canSave
                                    ? () => unawaited(_saveEditing())
                                    : null,
                                padding: EdgeInsets.zero,
                                icon: _isSaving
                                    ? const SizedBox.square(
                                        dimension: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.8,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded, size: 18),
                              )
                            : AnimatedOpacity(
                                duration: reduceMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 140),
                                opacity: showEditAction ? 1 : 0,
                                child: IgnorePointer(
                                  ignoring: !showEditAction,
                                  child: IconButton(
                                    key: ValueKey<String>(
                                      'edit-todo-${widget.item.id}',
                                    ),
                                    tooltip: '编辑',
                                    onPressed: _startEditing,
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox.square(
                        dimension: 34,
                        child: IconButton(
                          tooltip: _isEditing
                              ? '取消编辑'
                              : (widget.archivedScope ? '恢复到待办' : '归档'),
                          onPressed: _isSaving
                              ? null
                              : (_isEditing
                                    ? _cancelEditing
                                    : (widget.archivedScope
                                          ? widget.onRestore
                                          : widget.onArchive)),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isEditing
                                ? Icons.close_rounded
                                : (widget.archivedScope
                                      ? Icons.unarchive_outlined
                                      : Icons.archive_outlined),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.scope, required this.hasQuery});

  final TodoListScope scope;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isArchive = scope == TodoListScope.archived;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Icon(
                hasQuery
                    ? Icons.search_off_rounded
                    : (isArchive
                          ? Icons.inventory_2_outlined
                          : Icons.check_rounded),
                color: Theme.of(context).colorScheme.primary,
                size: 27,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              hasQuery ? '没有匹配的结果' : (isArchive ? '归档还是空的' : '没有待办，享受此刻'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.72),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              hasQuery
                  ? '换一个关键词试试'
                  : (isArchive ? '归档的事项会保存在这里' : '在上方随时添加新事项'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.40),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDay(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final difference = today.difference(day).inDays;
  if (difference == 0) {
    return '今天';
  }
  if (difference == 1) {
    return '昨天';
  }

  const weekdays = <String>['一', '二', '三', '四', '五', '六', '日'];
  return '${day.year}年${day.month}月${day.day}日 · 周${weekdays[day.weekday - 1]}';
}

String _formatTime(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _CollapseIntent extends Intent {
  const _CollapseIntent();
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

class _NewTodoIntent extends Intent {
  const _NewTodoIntent();
}

class _CancelTodoEditIntent extends Intent {
  const _CancelTodoEditIntent();
}
