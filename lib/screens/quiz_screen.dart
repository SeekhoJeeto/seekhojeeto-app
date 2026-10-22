import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../services/app_state.dart';
import '../services/progress_service.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final String subjectId;
  final List<Question> questions;
  final int limit;

  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    this.subjectId = '',
    this.limit = 10,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questions;
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    final list = List<Question>.from(widget.questions)..shuffle();
    _questions = list.take(widget.limit).toList();
  }

  void _choose(int i) {
    if (_selected != null) return;
    setState(() {
      _selected = i;
      if (i == _questions[_index].answer) _score++;
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      setState(() => _finished = true);
      if (!_recorded) {
        _recorded = true;
        context.read<ProgressService>().recordQuiz(
              subjectId: widget.subjectId,
              correct: _score,
              total: _questions.length,
            );
      }
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  void _restart() {
    setState(() {
      final list = List<Question>.from(widget.questions)..shuffle();
      _questions = list.take(widget.limit).toList();
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
      _recorded = false;
    });
  }

  int get _pointsEarned => _score * 10 + (_score == _questions.length ? 5 : 0);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.lang;

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('No questions available.')),
      );
    }

    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'Your score: $_score / ${_questions.length}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '+$_pointsEarned points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.replay),
                  label: const Text('Play again'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final options = q.optionsIn(lang);
    final answered = _selected != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Score: $_score'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(value: (_index + 1) / _questions.length),
          const SizedBox(height: 8),
          Text(
            'Question ${_index + 1} of ${_questions.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            q.textIn(lang),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < options.length; i++)
            _optionTile(context, i, options[i], q.answer, answered),
          if (answered) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline),
                    const SizedBox(width: 10),
                    Expanded(child: Text(q.explainIn(lang))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _next,
              child: Text(_index + 1 >= _questions.length ? 'Finish' : 'Next'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionTile(
    BuildContext context,
    int i,
    String label,
    int correct,
    bool answered,
  ) {
    Color? bg;
    Color? border;
    if (answered) {
      if (i == correct) {
        bg = Colors.green.withAlpha(38);
        border = Colors.green;
      } else if (i == _selected) {
        bg = Colors.red.withAlpha(31);
        border = Colors.red;
      }
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border ?? Colors.transparent, width: 1.5),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text(String.fromCharCode(65 + i))),
        title: Text(label),
        trailing: answered && i == correct
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (answered && i == _selected
                ? const Icon(Icons.cancel, color: Colors.red)
                : null),
        onTap: answered ? null : () => _choose(i),
      ),
    );
  }
}
