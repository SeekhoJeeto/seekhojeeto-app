import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/languages.dart';
import '../models/question.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Color> _colors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.redAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seekho Jeeto'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Language',
            onSelected: (v) => context.read<AppState>().setLang(v),
            itemBuilder: (_) => kLanguages
                .map((l) => PopupMenuItem<String>(
                      value: l.code,
                      child: Text(l.name),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh questions',
            onPressed: () => context.read<AppState>().loadData(),
          ),
          if (auth.firebaseReady)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
              onPressed: () => auth.signOut(),
            ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Namaste! Choose a subject',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < state.subjects.length; i++)
                  _subjectCard(
                    context,
                    state.subjects[i],
                    _colors[i % _colors.length],
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${state.totalQuestions} questions \u2022 '
                    'Updated ${state.lastUpdated.isEmpty ? '-' : state.lastUpdated}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _subjectCard(BuildContext context, Subject subject, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(38),
          child: Icon(_iconFor(subject.id), color: color),
        ),
        title: Text(
          subject.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('${subject.groups.length} sections \u2022 ${subject.count} questions'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openGroups(context, subject),
      ),
    );
  }

  void _openGroups(BuildContext context, Subject subject) {
    final state = context.read<AppState>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(subject.title)),
          body: ListView(
            children: subject.groups
                .map((g) => ListTile(
                      leading: CircleAvatar(
                        child: Text(g.icon.isEmpty ? '\u2022' : g.icon),
                      ),
                      title: Text(g.titleIn(state.lang)),
                      subtitle: Text('${g.questions.length} questions'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            title: '${subject.title} \u2022 ${g.titleIn(state.lang)}',
                            questions: g.questions,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'science':
        return Icons.science;
      case 'maths':
        return Icons.calculate;
      case 'traditions':
        return Icons.spa;
      case 'english':
        return Icons.translate;
      case 'gk':
        return Icons.public;
      default:
        return Icons.menu_book;
    }
  }
}
