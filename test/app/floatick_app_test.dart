import 'package:floatick/app/floatick_app.dart';
import 'package:floatick/core/platform/window_bridge.dart';
import 'package:floatick/core/ui/floatick_brand_mark.dart';
import 'package:floatick/features/settings/data/settings_repository.dart';
import 'package:floatick/features/settings/domain/app_settings.dart';
import 'package:floatick/features/settings/presentation/settings_view_model.dart';
import 'package:floatick/features/todos/data/todo_repository.dart';
import 'package:floatick/features/todos/domain/todo_item.dart';
import 'package:floatick/features/todos/presentation/todo_view_model.dart';
import 'package:floatick/features/todos/presentation/widgets/floating_todo_icon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('floating icon expands into an editable todo list', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(500, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _WidgetTestRepository();
    final controller = TodoViewModel(
      todoRepository: repository,
      clock: () => DateTime.utc(2026, 7, 23, 8),
      idGenerator: () => 'new-todo',
    );
    final windowBridge = _WidgetTestWindowBridge();
    final settingsRepository = _WidgetTestSettingsRepository();
    final settingsController = SettingsViewModel(
      settingsRepository: settingsRepository,
    );
    await controller.load();
    await settingsController.load();

    await tester.pumpWidget(
      FloatickApp(
        controller: controller,
        settingsController: settingsController,
        windowBridge: windowBridge,
        locale: const Locale('zh'),
      ),
    );
    expect(find.byKey(const ValueKey('floating-todo-icon')), findsOneWidget);
    expect(find.byType(FloatickBrandMark), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('floating-todo-icon'))),
      const Size.square(FloatingTodoIcon.canvasDimension),
    );

    windowBridge.expandRequestHandler?.call(WindowExpansionAnchor.topRight);
    await tester.pumpAndSettle();

    expect(windowBridge.expandedValues, <bool>[true]);
    expect(find.text('Floatick'), findsNothing);
    expect(find.text('今天已经清空'), findsOneWidget);
    expect(find.byKey(const ValueKey('panel-brand-mark')), findsOneWidget);
    expect(find.byKey(const Key('search-field')), findsOneWidget);
    expect(find.byKey(const Key('todo-input')), findsOneWidget);
    final panelSurface = tester.widget<DecoratedBox>(
      find.byKey(const Key('todo-panel-surface')),
    );
    final panelDecoration = panelSurface.decoration as BoxDecoration;
    expect(panelDecoration.boxShadow, isNull);
    expect(
      tester
          .widget<AnimatedSlide>(find.byKey(const Key('settings-drawer-slide')))
          .offset,
      const Offset(1, 0),
    );

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-drawer')), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('工作目录'), findsOneWidget);
    expect(find.text('/tmp/floatick-widget-test'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_rounded), findsNothing);
    expect(find.text('选择 Floatick 使用的界面主题'), findsNothing);
    expect(find.text('设置仅保存在这台 Mac 上'), findsNothing);
    expect(find.text('自动'), findsNothing);
    expect(find.text('浅色'), findsNothing);
    expect(find.text('深色'), findsNothing);
    expect(find.byKey(const Key('theme-system')), findsOneWidget);
    expect(find.byKey(const Key('theme-light')), findsOneWidget);
    expect(find.byKey(const Key('theme-dark')), findsOneWidget);
    expect(
      tester
          .widget<AnimatedSlide>(find.byKey(const Key('settings-drawer-slide')))
          .offset,
      Offset.zero,
    );
    expect(
      tester
          .widget<IgnorePointer>(
            find.byKey(const Key('settings-drawer-pointer')),
          )
          .ignoring,
      isFalse,
    );
    final systemThemeButton = tester.widget<IconButton>(
      find.byKey(const Key('theme-system')),
    );
    expect(systemThemeButton.isSelected, isTrue);
    expect(
      systemThemeButton.style?.backgroundColor?.resolve(<WidgetState>{}),
      Colors.transparent,
    );

    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();

    expect(settingsController.themePreference, AppThemePreference.dark);
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('settings-drawer'))),
      ).brightness,
      Brightness.dark,
    );
    expect(
      settingsRepository.savedSettings.themePreference,
      AppThemePreference.dark,
    );

    await tester.tap(find.byKey(const Key('theme-light')));
    await tester.pumpAndSettle();

    expect(settingsController.themePreference, AppThemePreference.light);
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('settings-drawer'))),
      ).brightness,
      Brightness.light,
    );
    expect(
      settingsRepository.savedSettings.themePreference,
      AppThemePreference.light,
    );

    await tester.tap(find.byKey(const Key('settings-close')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedSlide>(find.byKey(const Key('settings-drawer-slide')))
          .offset,
      const Offset(1, 0),
    );
    expect(
      tester
          .widget<IgnorePointer>(
            find.byKey(const Key('settings-drawer-pointer')),
          )
          .ignoring,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(windowBridge.expandedValues, <bool>[true]);
    expect(
      tester
          .widget<AnimatedSlide>(find.byKey(const Key('settings-drawer-slide')))
          .offset,
      const Offset(1, 0),
    );

    await tester.enterText(
      find.byKey(const Key('todo-input')),
      'Design the floating icon',
    );
    await tester.tap(find.byKey(const Key('add-todo')));
    await tester.pumpAndSettle();

    expect(find.text('Design the floating icon'), findsOneWidget);
    expect(find.text('1 项待完成'), findsOneWidget);
    expect(repository.savedItems.single.title, 'Design the floating icon');

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Design the floating icon')));
    await tester.pump(const Duration(milliseconds: 50));
    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 50));
    await mouse.moveTo(tester.getCenter(find.text('Design the floating icon')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final editButton = find.byKey(const Key('edit-todo-new-todo'));
    expect(editButton, findsOneWidget);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    final editField = find.byKey(const Key('todo-edit-new-todo'));
    expect(editField, findsOneWidget);
    await tester.enterText(editField, 'Cancelled edit');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Design the floating icon'), findsOneWidget);
    expect(windowBridge.expandedValues, <bool>[true]);

    await tester.tap(editButton);
    await tester.pumpAndSettle();
    await tester.enterText(editField, 'Polish the Floatick icon');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Polish the Floatick icon'), findsOneWidget);
    expect(repository.savedItems.single.title, 'Polish the Floatick icon');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(windowBridge.expandedValues, <bool>[true, false]);
    expect(find.byKey(const ValueKey('floating-todo-icon')), findsOneWidget);
  });

  testWidgets('English locale translates the primary todo experience', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(500, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = TodoViewModel(todoRepository: _WidgetTestRepository());
    final settingsController = SettingsViewModel(
      settingsRepository: _WidgetTestSettingsRepository(),
    );
    final windowBridge = _WidgetTestWindowBridge();
    await controller.load();
    await settingsController.load();

    await tester.pumpWidget(
      FloatickApp(
        controller: controller,
        settingsController: settingsController,
        windowBridge: windowBridge,
        locale: const Locale('en'),
      ),
    );

    windowBridge.expandRequestHandler?.call(WindowExpansionAnchor.topRight);
    await tester.pumpAndSettle();

    expect(find.text('All clear for today'), findsOneWidget);
    expect(find.text('Search todos'), findsOneWidget);
    expect(find.text('Add something to do…'), findsOneWidget);
    expect(find.text('今天已经清空'), findsNothing);

    await controller.add('Write English release notes');
    await tester.pumpAndSettle();
    expect(find.text('1 task remaining'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Working directory'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _WidgetTestSettingsRepository implements SettingsRepository {
  AppSettings savedSettings = const AppSettings();

  @override
  String get storagePath => '/tmp/floatick-widget-test/settings.json';

  @override
  Future<AppSettings> load() async => savedSettings;

  @override
  Future<void> save(AppSettings settings) async {
    savedSettings = settings;
  }
}

class _WidgetTestRepository implements TodoRepository {
  List<TodoItem> savedItems = <TodoItem>[];

  @override
  String get storagePath => '/tmp/floatick-widget-test/todos.json';

  @override
  Future<List<TodoItem>> load() async {
    return List<TodoItem>.of(savedItems);
  }

  @override
  Future<void> save(List<TodoItem> items) async {
    savedItems = List<TodoItem>.of(items);
  }
}

class _WidgetTestWindowBridge implements WindowBridge {
  final List<bool> expandedValues = <bool>[];
  ExpandRequestHandler? expandRequestHandler;

  @override
  void setExpandRequestHandler(ExpandRequestHandler? handler) {
    expandRequestHandler = handler;
  }

  @override
  Future<WindowExpansionAnchor> preferredExpansionAnchor() async {
    return WindowExpansionAnchor.topRight;
  }

  @override
  Future<void> setExpanded(bool expanded) async {
    expandedValues.add(expanded);
  }
}
