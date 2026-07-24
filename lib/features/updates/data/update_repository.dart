import 'package:flutter/services.dart';

import '../domain/update_settings_snapshot.dart';

abstract interface class UpdateRepository {
  Future<UpdateSettingsSnapshot> loadSettings();

  Future<void> setAutomaticallyChecksForUpdates(bool enabled);

  Future<void> checkForUpdates();
}

class MethodChannelUpdateRepository implements UpdateRepository {
  static const MethodChannel _channel = MethodChannel('floatick/update');

  @override
  Future<UpdateSettingsSnapshot> loadSettings() async {
    final value = await _channel.invokeMethod<Object?>('loadSettings');
    return UpdateSettingsSnapshot.fromPlatformValue(value);
  }

  @override
  Future<void> setAutomaticallyChecksForUpdates(bool enabled) {
    return _channel.invokeMethod<void>(
      'setAutomaticallyChecksForUpdates',
      enabled,
    );
  }

  @override
  Future<void> checkForUpdates() {
    return _channel.invokeMethod<void>('checkForUpdates');
  }
}
