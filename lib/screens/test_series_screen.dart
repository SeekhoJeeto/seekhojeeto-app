import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'quiz_screen.dart';

/// A 20-question mixed test across every subject for the chosen class.
class TestSeriesScreen extends StatefulWidget {
  const TestSeriesScreen({super.key});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  int _cls = 8;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final available = state.questionsForClass(_cls).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Series')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '20 questions from all subjects',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Science, Maths, SST, English, Hindi aur Values - sab se milaakar '
                    '20 sawaal. Apni class chuniye aur test shuru kijiye.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Choose your class'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var c = 5; c <= 12; c++)
                ChoiceChip(
                  label: Text('Class $c'),
                  selected: _cls == c,
                  onSelected: (_) => setState(() => _cls = c),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('$available questions available for Class $_cls'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: available == 0
                ? null
                : () {
                    final questions = state.questionsForClass(_cls);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          title: 'Test Series \u2022 Class $_cls',
                          subjectId: 'test',
                          subjectTitle: 'Test Series',
                          questions: questions,
                          limit: 20,
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start test (20 questions)'),
          ),
        ],
      ),
    );
  }
}
