import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/reminder_service.dart';
import 'database_provider.dart';

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

final reminderBootstrapProvider = FutureProvider<void>((ref) async {
  final service = ref.read(reminderServiceProvider);
  await service.init();
  final settings = await ref.read(settingsRepositoryProvider).requireSettings();
  await service.sync(
    enabled: settings.remindersEnabled,
    hour: settings.reminderHour,
    buddyName: settings.buddyName,
  );
});

class ReminderActions {
  ReminderActions(this._ref);

  final Ref _ref;

  Future<void> setReminders({
    required bool enabled,
    required int hour,
  }) async {
    await _ref.read(settingsRepositoryProvider).setReminders(
          enabled: enabled,
          hour: hour,
        );
    final settings =
        await _ref.read(settingsRepositoryProvider).requireSettings();
    await _ref.read(reminderServiceProvider).sync(
          enabled: enabled,
          hour: hour,
          buddyName: settings.buddyName,
        );
  }
}

final reminderActionsProvider =
    Provider<ReminderActions>((ref) => ReminderActions(ref));
