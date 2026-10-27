import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import 'buddy_widget_sync.dart';

/// Registers the home-widget interactivity callback (I smoked button).
Future<void> setupWidgetInteractivity() async {
  await HomeWidget.registerInteractivityCallback(onWidgetInteraction);
}

@pragma('vm:entry-point')
Future<void> onWidgetInteraction(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri == null) return;
  if (uri.host == 'smoke' || uri.pathSegments.contains('smoke')) {
    await BuddyWidgetSync.logSmokeFromWidget();
  }
}
