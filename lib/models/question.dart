/// A single quiz question, available in 13 languages.
class Question {
  final Map<String, String> text;
  final Map<String, List<String>> options;
  final int answer; // index 0..3, same across all languages
  final Map<String, String> explanation;

  Question({
    required this.text,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    final text = <String, String>{};
    (j['q'] as Map).forEach((k, v) => text['$k'] = '$v');

    final opts = <String, List<String>>{};
    (j['o'] as Map).forEach((k, v) {
      opts['$k'] = (v as List).map((e) => '$e').toList();
    });

    final exp = <String, String>{};
    (j['e'] as Map).forEach((k, v) => exp['$k'] = '$v');

    return Question(
      text: text,
      options: opts,
      answer: (j['a'] as num).toInt(),
      explanation: exp,
    );
  }

  String textIn(String lang) => text[lang] ?? text['en'] ?? '';
  String explainIn(String lang) => explanation[lang] ?? explanation['en'] ?? '';
  List<String> optionsIn(String lang) => options[lang] ?? options['en'] ?? const [];
}

/// One bucket inside a subject: a class (Science/Maths) or a category
/// (Values & Religion). Both shapes are handled by this single class.
class SubjectGroup {
  final String key;
  final Map<String, String> names; // localised titles; always has 'en'
  final String icon;
  final List<Question> questions;

  SubjectGroup({
    required this.key,
    required this.names,
    required this.icon,
    required this.questions,
  });

  String titleIn(String lang) => names[lang] ?? names['en'] ?? key;
}

/// A top-level section of the question bank (Science, Maths, ...). Built
/// straight from the JSON so a new subject added to the file shows up in the
/// app automatically.
/// One part of a subject that has sub-sections (English is split into
/// grammar / vocabulary / literature). Each part carries its own class-wise
/// groups, so the app can show: subject -> part -> class.
class SubjectPart {
  final String id;
  final Map<String, String> names; // localised titles; always has 'en'
  final List<SubjectGroup> groups;

  SubjectPart({
    required this.id,
    required this.names,
    required this.groups,
  });

  String titleIn(String lang) => names[lang] ?? names['en'] ?? id;
}

class Subject {
  final String id;
  final String title;
  final List<SubjectGroup> groups;
  final List<SubjectPart> parts;

  Subject({
    required this.id,
    required this.title,
    required this.groups,
    this.parts = const [],
  });

  int get count =>
      groups.fold(0, (sum, g) => sum + g.questions.length) +
      parts.fold(
        0,
        (sum, p) => sum + p.groups.fold(0, (t, g) => t + g.questions.length),
      );
}
