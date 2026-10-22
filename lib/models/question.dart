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

/// A Values & Religion category (values, sikh, hindu, ...).
class Tradition {
  final Map<String, String> names;
  final String icon;
  final List<Question> questions;

  Tradition({
    required this.names,
    required this.icon,
    required this.questions,
  });

  String nameIn(String lang) => names[lang] ?? names['en'] ?? '';
}
