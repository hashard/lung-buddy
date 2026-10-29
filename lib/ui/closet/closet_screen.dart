import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cosmetic_catalog.dart';
import '../../providers/billing_providers.dart';
import '../../providers/plus_providers.dart';
import '../../theme/app_theme.dart';
import '../home/lung_painter.dart';
import '../widgets/cartoon_chrome.dart';

class ClosetScreen extends ConsumerWidget {
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plusAsync = ref.watch(plusStateProvider);

    return PlayfulBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('CLOSET')),
        body: plusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (plus) {
            final starters = CosmeticCatalog.items
                .where((c) => c.unlock == CosmeticUnlock.starter)
                .toList();
            final streaks = CosmeticCatalog.items
                .where((c) => c.unlock == CosmeticUnlock.streak)
                .toList();
            final challenges = CosmeticCatalog.items
                .where((c) => c.unlock == CosmeticUnlock.challenge)
                .toList();
            final exclusive = CosmeticCatalog.items
                .where((c) => c.unlock == CosmeticUnlock.plusExclusive)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: BuddyColors.ink, width: 4),
                    ),
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: LungPainter(
                        smokeRatio: 0.08,
                        coughPhase: 0,
                        loadout: plus.loadout,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  plus.isPlus
                      ? 'PLUS LOCKER — ALL UNLOCKED'
                      : 'Earn drip. Or buy the lot.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  plus.isPlus
                      ? 'Every hat, scarf, and silly prop is yours.'
                      : 'Streaks & quests unlock looks. Plus unlocks everything.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!plus.isPlus) ...[
                  const SizedBox(height: 12),
                  BoomButton(
                    label: 'BUY PLUS — UNLOCK ALL',
                    onPressed: () async {
                      final msg =
                          await ref.read(billingActionsProvider).buyPlus();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            msg ?? 'Purchase started — Plus unlocks when paid.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
                _Section(
                  title: 'STARTERS',
                  items: starters,
                  plus: plus,
                ),
                _Section(
                  title: 'STREAK DROPS',
                  items: streaks,
                  plus: plus,
                ),
                _Section(
                  title: 'QUEST REWARDS',
                  items: challenges,
                  plus: plus,
                ),
                _Section(
                  title: 'PLUS EXCLUSIVES',
                  items: exclusive,
                  plus: plus,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.plus,
  });

  final String title;
  final List<CosmeticDef> items;
  final PlusState plus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...items.map((item) {
          final unlocked = plus.canUse(item);
          final equipped = plus.isEquipped(item);
          final hint = plus.lockReason(item);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white.withValues(alpha: unlocked ? 0.75 : 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(
                  color: BuddyColors.ink,
                  width: 3,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  backgroundColor: item.accent,
                  child: Icon(
                    unlocked
                        ? (equipped
                            ? Icons.check_rounded
                            : Icons.checkroom_rounded)
                        : Icons.lock_rounded,
                    color: BuddyColors.ink,
                  ),
                ),
                title: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(unlocked ? item.blurb : hint),
                trailing: equipped
                    ? const StickerBadge(
                        label: 'ON',
                        color: BuddyColors.mint,
                      )
                    : TextButton(
                        onPressed: unlocked
                            ? () =>
                                ref.read(plusActionsProvider).toggleEquip(item)
                            : null,
                        child: Text(unlocked ? 'WEAR' : 'LOCKED'),
                      ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}
