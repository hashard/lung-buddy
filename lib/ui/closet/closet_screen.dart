import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cosmetic_catalog.dart';
import '../../domain/cosmetic_loadout.dart';
import '../../domain/cosmetic_slot.dart';
import '../../providers/billing_providers.dart';
import '../../providers/plus_providers.dart';
import '../../theme/app_theme.dart';
import '../home/lung_painter.dart';
import '../widgets/cartoon_chrome.dart';

class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: CosmeticSlot.values.length,
      vsync: this,
    );
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  CosmeticLoadout _displayLoadout(PlusState plus) {
    var loadout = plus.loadout;
    for (final slot in CosmeticSlot.values) {
      final id = loadout.idFor(slot);
      if (id == null) continue;
      final item = CosmeticCatalog.byId(id);
      if (!plus.canUse(item)) {
        loadout = loadout.clear(slot);
      }
    }
    return loadout;
  }

  String _equippedLabel(PlusState plus, CosmeticSlot slot) {
    final id = _displayLoadout(plus).idFor(slot);
    if (id == null) return 'Empty';
    final item = CosmeticCatalog.byId(id);
    if (item.id == 'none') return 'Empty';
    return item.name;
  }

  @override
  Widget build(BuildContext context) {
    final plusAsync = ref.watch(plusStateProvider);

    return PlayfulBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('CLOSET')),
        body: plusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (plus) {
            final displayLoadout = _displayLoadout(plus);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
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
                              loadout: displayLoadout,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (var i = 0; i < CosmeticSlot.values.length; i++)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: i == 0 ? 0 : 4,
                                  right: i == CosmeticSlot.values.length - 1
                                      ? 0
                                      : 4,
                                ),
                                child: _SlotChip(
                                  slot: CosmeticSlot.values[i],
                                  label: _equippedLabel(
                                    plus,
                                    CosmeticSlot.values[i],
                                  ),
                                  selected: _tabs.index == i,
                                  onTap: () => _tabs.animateTo(i),
                                ),
                              ),
                            ),
                        ],
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
                            final msg = await ref
                                .read(billingActionsProvider)
                                .buyPlus();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  msg ??
                                      'Purchase started — Plus unlocks when paid.',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabs,
                  labelColor: BuddyColors.ink,
                  unselectedLabelColor: BuddyColors.ink.withValues(alpha: 0.55),
                  indicatorColor: BuddyColors.grape,
                  tabs: [
                    for (final slot in CosmeticSlot.values)
                      Tab(text: slot.label.toUpperCase()),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      for (final slot in CosmeticSlot.values)
                        _SlotItemList(slot: slot, plus: plus),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final CosmeticSlot slot;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? BuddyColors.mint.withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: BuddyColors.ink,
          width: selected ? 3 : 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slot.label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotItemList extends ConsumerWidget {
  const _SlotItemList({
    required this.slot,
    required this.plus,
  });

  final CosmeticSlot slot;
  final PlusState plus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = CosmeticCatalog.itemsForSlot(slot);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
                  ? InkWell(
                      onTap: () =>
                          ref.read(plusActionsProvider).toggleEquip(item),
                      borderRadius: BorderRadius.circular(18),
                      child: const StickerBadge(
                        label: 'ON',
                        color: BuddyColors.mint,
                      ),
                    )
                  : TextButton(
                      onPressed: unlocked
                          ? () => ref
                              .read(plusActionsProvider)
                              .toggleEquip(item)
                          : null,
                      child: Text(unlocked ? 'WEAR' : 'LOCKED'),
                    ),
            ),
          ),
        );
      },
    );
  }
}
