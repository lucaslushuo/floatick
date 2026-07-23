import 'package:flutter/widgets.dart';

import 'app/floatick_app.dart';
import 'core/platform/window_bridge.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/presentation/settings_view_model.dart';
import 'features/todos/data/todo_repository.dart';
import 'features/todos/presentation/todo_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = TodoViewModel(todoRepository: LocalTodoRepository());
  final settingsController = SettingsViewModel(
    settingsRepository: LocalSettingsRepository(),
  );
  await Future.wait<void>(<Future<void>>[
    controller.load(),
    settingsController.load(),
  ]);

  runApp(
    FloatickApp(
      controller: controller,
      settingsController: settingsController,
      windowBridge: MethodChannelWindowBridge(),
    ),
  );
}
