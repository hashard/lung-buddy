import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/billing_providers.dart';
import '../../theme/app_theme.dart';
import 'cartoon_chrome.dart';

/// Cartoon lock card for Plus-gated features.
class PlusPaywallCard extends ConsumerWidget {
  const PlusPaywallCard({
    super.key,
    required this.title,
    required this.blurb,
    this.icon = Icons.lock_rounded,
  });

  final String title;
  final String blurb;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BuddyColors.ink, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 32, color: BuddyColors.ink),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const StickerBadge(label: 'PLUS', color: BuddyColors.mint),
            ],
          ),
          const SizedBox(height: 10),
          Text(blurb, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          BoomButton(
            label: 'BUY PLUS',
            onPressed: () async {
              final msg = await ref.read(billingActionsProvider).buyPlus();
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
          TextButton(
            onPressed: () => context.push('/closet'),
            child: const Text('peek the closet'),
          ),
        ],
      ),
    );
  }
}

/// Soft, dismissible Plus pitch after the 3rd lifetime smoke log.
Future<void> showPlusNudgeSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Material(
          color: BuddyColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: BuddyColors.ink, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: BuddyColors.ink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Three smokes in. Buddy noticed.',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Plus unlocks the home widget (I smoked button), stats, and the whole closet — keep cutting down with a little more juice.',
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                BoomButton(
                  label: 'BUY PLUS',
                  onPressed: () async {
                    final msg =
                        await ref.read(billingActionsProvider).buyPlus();
                    if (!sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop();
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
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('not now — keep logging'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
