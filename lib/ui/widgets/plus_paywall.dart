import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/plus_providers.dart';
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
            label: 'UNLOCK PLUS (TEST)',
            onPressed: () async {
              await ref.read(plusActionsProvider).unlockPlusPlaceholder();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plus on! Stats, recap & closet unlocked.'),
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
