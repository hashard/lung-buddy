import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/day_evaluator.dart';
import '../../providers/challenge_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/home_providers.dart';
import '../../providers/billing_providers.dart';
import '../../providers/plus_providers.dart';
import '../../providers/reminder_providers.dart';
import '../../services/buddy_widget_sync.dart';
import '../../theme/app_theme.dart';
import '../widgets/cartoon_chrome.dart';
import '../widgets/plus_paywall.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _todayBudget;
  int? _defaultBudget;
  final _packCostController = TextEditingController();
  int _cigsPerPack = 20;
  bool _remindersEnabled = false;
  int _reminderHour = 20;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _packCostController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final settings = await settingsRepo.requireSettings();
    final today = await settingsRepo.budgetOrDefault(DateTime.now());
    if (!mounted) return;
    setState(() {
      _todayBudget = today;
      _defaultBudget = settings.defaultBudget;
      _packCostController.text = settings.packCost.toStringAsFixed(
        settings.packCost == settings.packCost.roundToDouble() ? 0 : 2,
      );
      _cigsPerPack = settings.cigsPerPack;
      _remindersEnabled = settings.remindersEnabled;
      _reminderHour = settings.reminderHour;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _todayBudget == null || _defaultBudget == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Today\'s budget', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              IconButton(
                onPressed: _todayBudget! > 1
                    ? () => setState(() => _todayBudget = _todayBudget! - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_todayBudget',
                  style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                onPressed: () =>
                    setState(() => _todayBudget = _todayBudget! + 1),
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setBudgetForDate(DateTime.now(), _todayBudget!);
                  ref.invalidate(homeVmProvider);
                  ref.invalidate(progressDaysProvider);
                  await BuddyWidgetSync.syncFromRepos(
                    settingsRepo: ref.read(settingsRepositoryProvider),
                    smokeRepo: ref.read(smokeRepositoryProvider),
                    challengeRepo: ref.read(challengeRepositoryProvider),
                  );
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Today\'s budget updated')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Default budget',
              style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              IconButton(
                onPressed: _defaultBudget! > 1
                    ? () =>
                        setState(() => _defaultBudget = _defaultBudget! - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_defaultBudget',
                  style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                onPressed: () =>
                    setState(() => _defaultBudget = _defaultBudget! + 1),
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setDefaultBudget(_defaultBudget!);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Default budget updated')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Pack pricing', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _packCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Pack price (\$)',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Cigs per pack'),
              const Spacer(),
              IconButton(
                onPressed: _cigsPerPack > 1
                    ? () => setState(() => _cigsPerPack--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_cigsPerPack',
                  style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: _cigsPerPack < 50
                    ? () => setState(() => _cigsPerPack++)
                    : null,
                icon: const Icon(Icons.add),
              ),
              FilledButton(
                onPressed: () async {
                  final cost =
                      double.tryParse(_packCostController.text.trim()) ?? 40;
                  await ref.read(settingsRepositoryProvider).setPackPricing(
                        packCost: cost,
                        cigsPerPack: _cigsPerPack,
                      );
                  ref.invalidate(homeVmProvider);
                  ref.invalidate(weekMoneyProvider);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Pack pricing updated')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            title: const Text('Lung Buddy Plus'),
            subtitle: const Text(
              'Unlocks all cosmetics, stats, weekly recap, and home widget (~\$6.99).',
            ),
            trailing: const Icon(Icons.workspace_premium_outlined),
            onTap: () => context.push('/closet'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final plus = ref.watch(plusStateProvider).valueOrNull;
              if (plus == null) return const SizedBox.shrink();
              if (plus.isPlus) {
                return Column(
                  children: [
                    const ListTile(
                      title: Text('Plus active'),
                      subtitle: Text('Thanks for supporting the buddy.'),
                      leading: Icon(Icons.verified_rounded),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(billingActionsProvider).restore(),
                      child: const Text('Restore purchases'),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  BoomButton(
                    label: 'BUY PLUS',
                    onPressed: () async {
                      final msg =
                          await ref.read(billingActionsProvider).buyPlus();
                      if (!context.mounted) return;
                      if (msg != null) {
                        messenger.showSnackBar(SnackBar(content: Text(msg)));
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(billingActionsProvider).restore(),
                    child: const Text('Restore purchases'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Daily reminder'),
            subtitle: Text(
              _remindersEnabled
                  ? 'Nudge around ${_reminderHour.toString().padLeft(2, '0')}:00'
                  : 'Off — local notification only',
            ),
            value: _remindersEnabled,
            onChanged: (v) async {
              setState(() => _remindersEnabled = v);
              await ref.read(reminderActionsProvider).setReminders(
                    enabled: v,
                    hour: _reminderHour,
                  );
            },
          ),
          if (_remindersEnabled)
            Row(
              children: [
                const Text('Hour'),
                const Spacer(),
                IconButton(
                  onPressed: _reminderHour > 0
                      ? () async {
                          setState(() => _reminderHour--);
                          await ref.read(reminderActionsProvider).setReminders(
                                enabled: true,
                                hour: _reminderHour,
                              );
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$_reminderHour:00',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: _reminderHour < 23
                      ? () async {
                          setState(() => _reminderHour++);
                          await ref.read(reminderActionsProvider).setReminders(
                                enabled: true,
                                hour: _reminderHour,
                              );
                        }
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final plus = ref.watch(plusStateProvider).valueOrNull;
              if (plus == null) return const SizedBox.shrink();
              if (!plus.isPlus) {
                return const PlusPaywallCard(
                  title: 'HOME SCREEN WIDGET',
                  blurb:
                      'Live today count + streak on your home screen. Unlock Plus, then add the widget.',
                  icon: Icons.widgets_rounded,
                );
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BuddyColors.mint.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: BuddyColors.ink, width: 3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOME SCREEN WIDGET',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Plus unlocked. Long-press your home screen → Widgets → Lung Buddy. '
                      'Or tap below if your launcher supports pin prompts.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    BoomButton(
                      label: 'ADD WIDGET',
                      onPressed: () async {
                        try {
                          await BuddyWidgetSync.syncFromRepos(
                            settingsRepo:
                                ref.read(settingsRepositoryProvider),
                            smokeRepo: ref.read(smokeRepositoryProvider),
                            challengeRepo:
                                ref.read(challengeRepositoryProvider),
                          );
                          await BuddyWidgetSync.requestPin();
                          if (!context.mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'If nothing popped up: long-press home → Widgets → Lung Buddy',
                              ),
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Widget pin failed: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),
          ListTile(
            title: const Text('Undo last log'),
            subtitle: Text(
              'Same day only · ${DayEvaluator.dateOnly(DateTime.now())}',
            ),
            onTap: () async {
              final ok = await ref.read(smokeActionsProvider).undo();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Undid last log' : 'Nothing to undo'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Export data'),
            subtitle: const Text('Share a JSON backup from this phone'),
            onTap: () async {
              try {
                final json = await ref.read(exportServiceProvider).exportJson();
                final dir = await getTemporaryDirectory();
                final file = File('${dir.path}/lung_buddy_export.json');
                await file.writeAsString(json);
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'Lung Buddy export',
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Delete all data'),
            subtitle: const Text('Wipes everything on this device'),
            textColor: Theme.of(context).colorScheme.error,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete everything?'),
                  content: const Text(
                    'This cannot be undone. You\'ll go through onboarding again.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              await ref.read(exportServiceProvider).wipeAll();
              ref.invalidate(homeVmProvider);
              ref.invalidate(progressDaysProvider);
              ref.invalidate(weekMoneyProvider);
              ref.invalidate(challengeListProvider);
              if (!context.mounted) return;
              context.go('/onboarding');
            },
          ),
          const Divider(height: 32),
          const ListTile(
            title: Text('About & privacy'),
            subtitle: Text(
              'No account. Data stays on your phone. Lung Buddy is for cutting down — not medical advice.',
            ),
          ),
        ],
      ),
    );
  }
}
