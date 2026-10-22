/// A student's saved progress: points, badges, streak and daily goal.
class Progress {
  int points;
  int quizzes;
  int correct;
  int total;
  int bestScore;
  int streak;
  int dailyCount;
  String lastPlayed; // yyyy-MM-dd
  String dailyDate; // yyyy-MM-dd
  List<String> badges;
  Map<String, dynamic> subjects;

  Progress({
    this.points = 0,
    this.quizzes = 0,
    this.correct = 0,
    this.total = 0,
    this.bestScore = 0,
    this.streak = 0,
    this.dailyCount = 0,
    this.lastPlayed = '',
    this.dailyDate = '',
    this.badges = const [],
    this.subjects = const {},
  });

  /// How many questions a student should answer each day.
  static const int dailyGoal = 20;

  /// Every 100 points is one level.
  int get level => points ~/ 100 + 1;
  int get intoLevel => points % 100;
  bool get goalMet => dailyCount >= dailyGoal;

  static int _int(dynamic v) => v is num ? v.toInt() : 0;

  factory Progress.fromMap(Map<String, dynamic> m) => Progress(
        points: _int(m['points']),
        quizzes: _int(m['quizzes']),
        correct: _int(m['correct']),
        total: _int(m['total']),
        bestScore: _int(m['bestScore']),
        streak: _int(m['streak']),
        dailyCount: _int(m['dailyCount']),
        lastPlayed: '${m['lastPlayed'] ?? ''}',
        dailyDate: '${m['dailyDate'] ?? ''}',
        badges: (m['badges'] as List?)?.map((e) => '$e').toList() ?? const [],
        subjects: (m['subjects'] as Map?)?.cast<String, dynamic>() ?? const {},
      );

  Map<String, dynamic> toMap() => {
        'points': points,
        'quizzes': quizzes,
        'correct': correct,
        'total': total,
        'bestScore': bestScore,
        'streak': streak,
        'dailyCount': dailyCount,
        'lastPlayed': lastPlayed,
        'dailyDate': dailyDate,
        'badges': badges,
        'subjects': subjects,
      };
}
