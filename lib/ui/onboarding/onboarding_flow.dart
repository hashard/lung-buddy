import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/database_provider.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  int _usual = 10;
  late int _budget;
  final _nameController = TextEditingController(text: 'Buddy');
  final _packCostController = TextEditingController(text: '40');
  int _cigsPerPack = 20;

  @override
  void initState() {
    super.initState();
    _budget = (_usual - 1).clamp(1, 99);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _packCostController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    final packCost = double.tryParse(_packCostController.text.trim()) ?? 40.0;
    await ref.read(settingsRepositoryProvider).completeOnboarding(
          usualBaseline: _usual,
          defaultBudget: _budget,
          buddyName: _nameController.text.trim().isEmpty
              ? 'Buddy'
              : _nameController.text.trim(),
          packCost: packCost,
          cigsPerPack: _cigsPerPack,
        );
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _Page(
              title: 'Meet your Lung Buddy',
              body:
                  'A light-hearted way to smoke a little less — no guilt, just honest tracking and a cheeky sidekick.',
              actionLabel: "Let's go",
              onAction: _next,
            ),
            _StepperPage(
              title: 'How many do you usually smoke in a day?',
              value: _usual,
              onChanged: (v) => setState(() {
                _usual = v;
                _budget = (_usual - 1).clamp(1, 99);
              }),
              onAction: _next,
            ),
            _StepperPage(
              title: 'First daily budget',
              subtitle:
                  'Suggested: one under your usual. You can change this anytime.',
              value: _budget,
              onChanged: (v) => setState(() => _budget = v),
              onAction: _next,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    'What does a pack cost?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We’ll tally spend as you log — AUD for now.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _packCostController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Pack price (\$)',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cigarettes per pack',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _cigsPerPack > 1
                            ? () => setState(() => _cigsPerPack--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$_cigsPerPack',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: 40),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: _cigsPerPack < 50
                            ? () => setState(() => _cigsPerPack++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(onPressed: _next, child: const Text('Next')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    'Name your buddy',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Buddy name',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const Spacer(),
                  FilledButton(onPressed: _next, child: const Text('Next')),
                ],
              ),
            ),
            _Page(
              title: 'One tip',
              body:
                  "Honesty keeps your buddy useful. Log what you smoke — rough days happen, and tomorrow's budget is fresh.",
              actionLabel: 'Start tracking',
              onAction: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _StepperPage extends StatelessWidget {
  const _StepperPage({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.onAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final int value;
  final ValueChanged<int> onChanged;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$value',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 48),
                ),
              ),
              IconButton.filledTonal(
                onPressed: value < 99 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Spacer(),
          FilledButton(onPressed: onAction, child: const Text('Next')),
        ],
      ),
    );
  }
}
