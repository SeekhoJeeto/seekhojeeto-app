import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/progress.dart';
import '../rewards/badges.dart';
import '../services/progress_service.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ps = context.watch<ProgressService>();
    final p = ps.progress;

    return Scaffold(
      appBar: AppBar(title: const Text('My Rewards')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _levelCard(context, p),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat(context, Icons.local_fire_department, '${p.streak}', 'day streak'),
              _stat(context, Icons.today, '${p.dailyCount}/${Progress.dailyGoal}', 'today'),
              _stat(context, Icons.quiz, '${p.quizzes}', 'quizzes'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Badges', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: [
              for (final b in kBadges)
                _badgeTile(context, b, p.badges.contains(b.id)),
            ],
          ),
          if (!ps.saved) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'You are playing as a guest, so this progress is not saved. '
                  'Create an account to keep your points and badges safe and '
                  'to continue on any phone.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _levelCard(BuildContext context, Progress p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.military_tech, size: 40, color: Colors.amber),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level ${p.level}',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('${p.points} points'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: p.intoLevel / 100),
            const SizedBox(height: 6),
            Text('${100 - p.intoLevel} points to level ${p.level + 1}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeTile(BuildContext context, BadgeDef b, bool earned) {
    final color = earned ? Colors.amber.shade700 : Colors.grey;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(earned ? b.icon : Icons.lock, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              b.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              b.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
