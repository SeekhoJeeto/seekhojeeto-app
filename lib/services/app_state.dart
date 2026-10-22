import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';

/// Holds all app data: the question bank (fetched live, with an offline
/// fallback bundled in the app) and the user's chosen language.
///
/// The list of subjects is built from the JSON itself, so adding a new
/// subject to questions.json makes it appear without a new app build.
class AppState extends ChangeNotifier {
  /// Single source of truth: the questions.json that the daily job updates.
  static const String dataUrl =
      'https://raw.githubusercontent.com/SeekhoJeeto/seekhojeeto.github.io/main/questions.json';

  static const Map<String, String> _titles = {
    'science': 'Science',
    'maths': 'Maths',
    'traditions': 'Values & Religion',
  };

  String lang = 'en';
  bool loading = true;
  String? error;

  List<Subject> subjects = [];
  String lastUpdated = '';

  int get totalQuestions =>
      subjects.fold(0, (sum, s) => sum + s.count);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      lang = prefs.getString('lang') ?? 'en';
    } catch (_) {}
    await loadData();
  }

  Future<void> setLang(String l) async {
    lang = l;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lang', l);
    } catch (_) {}
  }

  Future<void> loadData() async {
    loading = true;
    error = null;
    notifyListeners();

    String? body;
    try {
      final resp = await http
          .get(Uri.parse(dataUrl))
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200 && resp.body.trim().isNotEmpty) {
        body = resp.body;
      }
    } catch (_) {
      // Offline or blocked - fall back to the bundled copy.
    }
    body ??= await _bundled();

    try {
      final decoded = json.decode(body) as Map<String, dynamic>;
      _build(decoded);
    } catch (_) {
      error = 'Questions could not be loaded.';
    }
    loading = false;
    notifyListeners();
  }

  Future<String> _bundled() async {
    try {
      return await rootBundle.loadString('assets/questions.json');
    } catch (_) {
      return '{"meta":{}}';
    }
  }

  void _build(Map<String, dynamic> d) {
    final built = <Subject>[];

    for (final entry in d.entries) {
      if (entry.key == 'meta') continue;
      final value = entry.value;
      if (value is! Map) continue;

      final groups = _groupsFrom(value);
      if (groups.isEmpty) continue;

      built.add(Subject(
        id: entry.key,
        title: _titles[entry.key] ?? _prettify(entry.key),
        groups: groups,
      ));
    }

    subjects = built;

    final meta = d['meta'];
    if (meta is Map) lastUpdated = '${meta['last_updated'] ?? ''}';
  }

  /// Handles both JSON shapes:
  ///  - grouped  : { "values": { "name": {...}, "icon": "..", "qs": [ ... ] }, ... }
  ///  - classed  : { "5": [ ... ], "6": [ ... ], ... }
  List<SubjectGroup> _groupsFrom(Map<dynamic, dynamic> subjectMap) {
    final grouped = subjectMap.values
        .any((v) => v is Map && v['qs'] is List);

    final groups = <SubjectGroup>[];

    if (grouped) {
      for (final e in subjectMap.entries) {
        final v = e.value;
        if (v is! Map) continue;
        final names = <String, String>{};
        final nm = v['name'];
        if (nm is Map) {
          nm.forEach((k, val) => names['$k'] = '$val');
        }
        if (names.isEmpty) names['en'] = _prettify('${e.key}');
        groups.add(SubjectGroup(
          key: '${e.key}',
          names: names,
          icon: '${v['icon'] ?? ''}',
          questions: _questionsOf(v['qs']),
        ));
      }
    } else {
      for (final e in subjectMap.entries) {
        final v = e.value;
        if (v is! List) continue;
        groups.add(SubjectGroup(
          key: '${e.key}',
          names: {'en': 'Class ${e.key}'},
          icon: '',
          questions: _questionsOf(v),
        ));
      }
      groups.sort((a, b) {
        final ai = int.tryParse(a.key) ?? 0;
        final bi = int.tryParse(b.key) ?? 0;
        return ai.compareTo(bi);
      });
    }

    groups.removeWhere((g) => g.questions.isEmpty);
    return groups;
  }

  List<Question> _questionsOf(dynamic list) {
    final out = <Question>[];
    if (list is List) {
      for (final e in list) {
        if (e is Map<String, dynamic>) out.add(Question.fromJson(e));
      }
    }
    return out;
  }

  String _prettify(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ');
  }
}
