import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/languages.dart';
import '../models/question.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                _subjectCard(
                  context,
                  title: 'Science',
                  subtitle: 'Classes 5 to 12',
                  icon: Icons.science,
                  color: Colors.blue,
                  onTap: () => _openClasses(context, 'Science', state.science),
                ),
                _subjectCard(
                  context,
                  title: 'Maths',
                  subtitle: 'Classes 5 to 12',
                  icon: Icons.calculate,
                  color: Colors.orange,
                  onTap: () => _openClasses(context, 'Maths', state.maths),
                ),
                _subjectCard(
                  context,
                  title: 'Values & Religion',
                  subtitle: 'Values, Sikh, Hindu, Muslim, Christian, Jain, Buddhist',
                  icon: Icons.spa,
                  color: Colors.green,
                  onTap: () => _openTraditions(context, state),
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

  Widget _subjectCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(38),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _openClasses(
    BuildContext context,
    String title,
    Map<String, List<Question>> data,
  ) {
    final classes = data.keys.toList()
      ..sort((a, b) {
        final ai = int.tryParse(a) ?? 0;
        final bi = int.tryParse(b) ?? 0;
        return ai.compareTo(bi);
      });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: classes.isEmpty
              ? const Center(child: Text('No questions yet.'))
              : ListView(
                  children: classes
                      .map((c) => ListTile(
                            leading: CircleAvatar(child: Text(c)),
                            title: Text('Class $c'),
                            subtitle: Text('${data[c]!.length} questions'),
                            trailing: const Icon(Icons.play_arrow),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => QuizScreen(
                                  title: '$title \u2022 Class $c',
                                  questions: data[c]!,
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

  void _openTraditions(BuildContext context, AppState state) {
    final cats = state.traditions.keys.toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Values & Religion')),
          body: cats.isEmpty
              ? const Center(child: Text('No questions yet.'))
              : ListView(
                  children: cats.map((c) {
                    final t = state.traditions[c]!;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(t.icon.isEmpty ? '\u2022' : t.icon),
                      ),
                      title: Text(t.nameIn(state.lang)),
                      subtitle: Text('${t.questions.length} questions'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            title: t.nameIn(state.lang),
                            questions: t.questions,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
}
