import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/cost_math.dart';
import '../../domain/models.dart';
import '../../l10n/money_format.dart';
import '../../providers/home_providers.dart';
import '../../providers/plus_providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/cartoon_chrome.dart';
import '../widgets/plus_paywall.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plusAsync = ref.watch(plusStateProvider);

    return PlayfulBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('STATS')),
        body: plusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (plus) {
            if (!plus.isPlus) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  PlusPaywallCard(
                    title: 'STATS & WEEKLY RECAP',
                    blurb:
                        'Streak deep-dives, the 7-day chart, and your week money card live behind Plus. Free still tracks day-to-day on Home.',
                    icon: Icons.bar_chart_rounded,
                  ),
                ],
              );
            }
            return const _PlusStatsBody();
          },
        ),
      ),
    );
  }
}

class _PlusStatsBody extends ConsumerWidget {
  const _PlusStatsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeVmProvider);
    final daysAsync = ref.watch(progressDaysProvider);
    final weekAsync = ref.watch(weekMoneyProvider);

    return daysAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (days) {
        final streak = home.valueOrNull?.streak;
        final last7 =
            days.length > 7 ? days.sublist(days.length - 7) : days;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Streak now',
                    value: '${streak?.current ?? 0}',
                    color: BuddyColors.lemon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Best ever',
                    value: '${streak?.best ?? 0}',
                    color: BuddyColors.mint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            weekAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (week) => _WeekMoneyCard(week: week),
            ),
            const SizedBox(height: 20),
            Text(
              'LAST 7 DAYS',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Container(
              height: 210,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: BuddyColors.ink, width: 3),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (last7
                              .map((d) => d.smokeCount)
                              .fold<int>(0, (a, b) => a > b ? a : b) +
                          2)
                      .toDouble(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= last7.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            DateFormat('E').format(last7[i].date),
                            style: Theme.of(context).textTheme.titleSmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    for (var i = 0; i < last7.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: last7[i].smokeCount.toDouble(),
                            width: 20,
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: BuddyColors.ink,
                              width: 2,
                            ),
                            color: last7[i].status == DayStatus.lost
                                ? BuddyColors.grape
                                : BuddyColors.mint,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'RECENT DAYS',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...days.reversed.take(14).map((d) {
              final label = switch (d.status) {
                DayStatus.won => 'Under! Legend.',
                DayStatus.lost => 'Rough cartoon day',
                DayStatus.inProgress => 'Still cooking…',
                DayStatus.empty => 'No data',
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: BuddyColors.ink,
                      width: 2.5,
                    ),
                  ),
                  child: ListTile(
                    title: Text(DateFormat.MMMd().format(d.date)),
                    subtitle: Text(
                      d.budget == null
                          ? label
                          : '${d.smokeCount} / ${d.budget} · $label',
                    ),
                    trailing: Icon(
                      d.status == DayStatus.won
                          ? Icons.sentiment_very_satisfied_rounded
                          : d.status == DayStatus.lost
                              ? Icons.sentiment_very_dissatisfied_rounded
                              : Icons.timelapse_rounded,
                      color: BuddyColors.ink,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _WeekMoneyCard extends StatelessWidget {
  const _WeekMoneyCard({required this.week});

  final WeekMoneySummary week;

  @override
  Widget build(BuildContext context) {
    final range =
        '${DateFormat.MMMd().format(week.weekStart)} – ${DateFormat.MMMd().format(week.weekEnd)}';
    final diffLine = week.costDiff.abs() < 0.005
        ? 'Exact budget. Weirdly perfect.'
        : week.overBudget
            ? '${MoneyFormat.aud(week.costDiff)} over — slapstick week.'
            : '${MoneyFormat.aud(-week.costDiff)} under — LOOK AT YOU.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.lemon.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BuddyColors.ink, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(range, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Text('Smoked ${week.smoked} · Budgeted ${week.budgeted}'),
          Text(
            'Burned ${MoneyFormat.aud(week.costSmoked)} · '
            'Budget burn ${MoneyFormat.aud(week.costBudgeted)}',
          ),
          const SizedBox(height: 8),
          Text(
            diffLine,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BuddyColors.ink, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 36,
                ),
          ),
        ],
      ),
    );
  }
}
