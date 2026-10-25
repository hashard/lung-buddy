import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:lung_buddy/data/db.dart';
import 'package:lung_buddy/providers/database_provider.dart';
import 'package:lung_buddy/ui/home/home_screen.dart';

void main() {
  testWidgets('Home shows count and I smoked button', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await db.into(db.settings).insert(
          SettingsCompanion.insert(
            id: const Value(1),
            usualBaseline: 10,
            defaultBudget: 8,
            onboardingDone: const Value(true),
            buddyName: const Value('TestBuddy'),
          ),
        );
    await db.into(db.dailyBudgets).insert(
          DailyBudgetsCompanion.insert(date: today, limit: 8),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Idle animation repeats — don't use pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('0 / 8'), findsOneWidget);
    expect(find.text('I SMOKED'), findsOneWidget);
    expect(find.text('TESTBUDDY'), findsOneWidget);

    await db.close();
  });
}
