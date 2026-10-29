import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../data/db.dart';
import '../data/repositories/challenge_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/smoke_repository.dart';
import '../domain/cosmetic_catalog.dart';
import '../domain/cosmetic_unlocks.dart';
import '../domain/day_evaluator.dart';
import '../domain/models.dart';
import '../domain/streak_calculator.dart';
import '../ui/widgets/buddy_render.dart';

/// Pushes today count / streak / buddy art into the Android home-screen widget.
class BuddyWidgetSync {
  static const qualifiedAndroidName =
      'com.lungbuddy.lung_buddy.BuddyWidgetProvider';

  static Future<void> syncFromRepos({
    required SettingsRepository settingsRepo,
    required SmokeRepository smokeRepo,
    ChallengeRepository? challengeRepo,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final settings = await settingsRepo.requireSettings();
      final now = DateTime.now();
      final today = DayEvaluator.dateOnly(now);
      final budget = await settingsRepo.budgetOrDefault(today);
      final count = await smokeRepo.countForDate(today);
      final smokeRatio = budget <= 0 ? 0.0 : count / budget;

      // Light streak pass (last ~14 days is enough for current streak display).
      final days = <DayResult>[];
      for (var i = 14; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dayCount = await smokeRepo.countForDate(date);
        final dayBudget = await settingsRepo.budgetForDate(date);
        final hadData = dayBudget != null || dayCount > 0 || date == today;
        final effective =
            dayBudget ?? (date == today ? budget : settings.defaultBudget);
        days.add(
          DayEvaluator.evaluate(
            date: date,
            smokeCount: dayCount,
            budget: hadData ? effective : null,
            now: now,
            hadAnyBudgetOrOpen: hadData,
          ),
        );
      }
      final streak = StreakCalculator.compute(
        days: days,
        today: today,
        bestEver: settings.bestStreak,
      );

      final loadout = await settingsRepo.loadout();
      var cosmetic = loadout.ids.isEmpty
          ? CosmeticCatalog.none
          : CosmeticCatalog.byId(loadout.ids.first);
      if (challengeRepo != null) {
        final unlocked = await challengeRepo.unlockedRewardIds();
        final ok = CosmeticUnlocks.canUse(
          item: cosmetic,
          isPlus: settings.isPlus,
          bestStreak: streak.best,
          unlockedRewardIds: unlocked,
        );
        if (!ok) cosmetic = CosmeticCatalog.none;
      }

      if (!settings.isPlus) {
        await HomeWidget.saveWidgetData<String>('title', 'Lung Buddy');
        await HomeWidget.saveWidgetData<String>(
          'line',
          'Plus unlocks live counts',
        );
        await HomeWidget.saveWidgetData<String>('streak', '🔒 Plus');
        await HomeWidget.saveWidgetData<bool>('locked', true);
      } else {
        await HomeWidget.saveWidgetData<String>(
          'title',
          settings.buddyName.isEmpty ? 'Lung Buddy' : settings.buddyName,
        );
        await HomeWidget.saveWidgetData<String>(
          'line',
          '$count / $budget today',
        );
        await HomeWidget.saveWidgetData<String>(
          'streak',
          'Streak ${streak.current}',
        );
        await HomeWidget.saveWidgetData<bool>('locked', false);
      }

      try {
        await HomeWidget.renderFlutterWidget(
          BuddyRender(
            size: 180,
            smokeRatio: smokeRatio.clamp(0.0, 1.35),
            cosmetic: cosmetic,
            backgroundColor: const Color(0xFFFFE8F2),
          ),
          logicalSize: const Size(180, 180),
          key: 'buddyImage',
        );
      } catch (e, st) {
        debugPrint('BuddyWidgetSync render failed: $e\n$st');
      }

      await HomeWidget.updateWidget(
        qualifiedAndroidName: qualifiedAndroidName,
      );
    } catch (e, st) {
      debugPrint('BuddyWidgetSync failed: $e\n$st');
    }
  }

  /// Background entry used by the widget "I smoked" button.
  static Future<void> logSmokeFromWidget() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final db = AppDatabase();
    try {
      final settingsRepo = SettingsRepository(db);
      final smokeRepo = SmokeRepository(db);
      final challengeRepo = ChallengeRepository(db);
      final settings = await settingsRepo.requireSettings();
      if (!settings.isPlus) {
        // Locked widget — just refresh the paywall copy.
        await syncFromRepos(
          settingsRepo: settingsRepo,
          smokeRepo: smokeRepo,
          challengeRepo: challengeRepo,
        );
        return;
      }
      await smokeRepo.logNow();
      await syncFromRepos(
        settingsRepo: settingsRepo,
        smokeRepo: smokeRepo,
        challengeRepo: challengeRepo,
      );
    } finally {
      await db.close();
    }
  }

  static Future<void> requestPin() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final supported = await HomeWidget.isRequestPinWidgetSupported();
    if (supported != true) return;
    await HomeWidget.requestPinWidget(
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }
}
