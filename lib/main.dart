import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/billing_providers.dart';
import 'providers/reminder_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // Fire-and-forget bootstrap; UI does not block on store / notifications.
  container.read(billingBootstrapProvider);
  container.read(reminderBootstrapProvider);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LungBuddyApp(),
    ),
  );
}
