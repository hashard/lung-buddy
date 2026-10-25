import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cosmetic_catalog.dart';
import '../../domain/models.dart';
import '../../providers/challenge_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/cartoon_chrome.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(challengeListProvider);
    return PlayfulBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('QUESTS')),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            final hasActive =
                items.any((i) => i.status == ChallengeStatus.active);
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final statusLabel = switch (item.status) {
                  ChallengeStatus.available => 'READY',
                  ChallengeStatus.active =>
                    'GOING · ${item.daysCompleted}/${item.def.targetDays}',
                  ChallengeStatus.completed => 'DONE ZOOM',
                };
                return Material(
                  color: Colors.white.withValues(alpha: 0.78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: BuddyColors.ink, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.def.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(item.def.description),
                        const SizedBox(height: 8),
                        StickerBadge(
                          label:
                              'Loot: ${CosmeticCatalog.byId(item.def.rewardId).name}',
                          color: BuddyColors.lemon,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        if (item.status == ChallengeStatus.available)
                          FilledButton(
                            onPressed: hasActive
                                ? null
                                : () async {
                                    try {
                                      await ref
                                          .read(challengeActionsProvider)
                                          .start(item.def.id);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('$e')),
                                      );
                                    }
                                  },
                            child: Text(
                              hasActive ? 'Finish one first' : 'START QUEST',
                            ),
                          ),
                        if (item.status == ChallengeStatus.active)
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(challengeActionsProvider)
                                  .abandon(item.def.id);
                            },
                            child: const Text('bail on quest'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
