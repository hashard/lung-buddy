import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/money_format.dart';
import '../../providers/home_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/cartoon_chrome.dart';
import 'mascot_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _coughPulse = false;

  Future<void> _logSmoke() async {
    setState(() => _coughPulse = true);
    await ref.read(smokeActionsProvider).log();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (mounted) setState(() => _coughPulse = false);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(homeVmProvider);

    return PlayfulBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('LUNG BUDDY'),
          actions: [
            IconButton(
              icon: const Icon(Icons.checkroom_rounded),
              tooltip: 'Closet',
              onPressed: () => context.push('/closet'),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Uh oh: $e')),
          data: (vm) {
            final progress =
                vm.budget == 0 ? 0.0 : (vm.count / vm.budget).clamp(0.0, 1.2);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        StickerBadge(
                          label: 'Streak ${vm.streak.current}',
                          icon: Icons.local_fire_department_rounded,
                          color: BuddyColors.lemon,
                        ),
                        const Spacer(),
                        if (vm.isPlus)
                          const StickerBadge(
                            label: 'PLUS',
                            color: BuddyColors.mint,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            MascotView(
                              name: vm.buddyName,
                              line: vm.mascotLine,
                              count: vm.count,
                              budget: vm.budget,
                              triggerCough: _coughPulse,
                              cosmetic: vm.cosmetic,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${vm.count} / ${vm.budget}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 48),
                            ),
                            const SizedBox(height: 10),
                            StickerBadge(
                              label:
                                  'Spent today ${MoneyFormat.aud(vm.todaySpend)}',
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${MoneyFormat.aud(vm.costPerCig)} a pop',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 14),
                            CartoonProgressBar(
                              value: progress > 1 ? 1 : progress,
                              over: !vm.todayOnTrack,
                            ),
                            if (vm.activeChallenge != null) ...[
                              const SizedBox(height: 14),
                              StickerBadge(
                                label:
                                    'Quest ${vm.activeChallenge!.daysCompleted}/${vm.activeChallenge!.targetDays}',
                                color: BuddyColors.mint,
                                icon: Icons.flag_rounded,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    BoomButton(label: 'I SMOKED', onPressed: _logSmoke),
                    TextButton(
                      onPressed: () async {
                        final ok =
                            await ref.read(smokeActionsProvider).undo();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok ? 'Undid that one. Nice.' : 'Nothing to undo!',
                            ),
                          ),
                        );
                      },
                      child: const Text('oops — undo'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
