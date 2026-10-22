import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';

/// Holds all app data: the question bank (fetched live, with an offline
/// fallback bundled in the app) and the user's chosen language.
class AppState extends ChangeNotifier {
  /// Single source of truth: the questions.json that the daily job updates.
  static const String dataUrl =
      'https://raw.githubusercontent.com/SeekhoJeeto/seekhojeeto.github.io/main/questions.json';

  String lang = 'en';
  bool loading = true;
  String? error;

  Map<String, List<Question>> science = {};
  Map<String, List<Question>> maths = {};
  Map<String, Tradition> traditions = {};
  String lastUpdated = '';

  int get totalQuestions {
    var n = 0;
    for (final v in science.values) {
      n += v.length;
    }
    for (final v in maths.values) {
      n += v.length;
    }
    for (final v in traditions.values) {
      n += v.questions.length;
    }
    return n;
  }

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
      return '{"science":{},"maths":{},"traditions":{}}';
    }
  }

  void _build(Map<String, dynamic> d) {
    science = _parseSubjects(d['science']);
    maths = _parseSubjects(d['maths']);

    traditions = {};
    final t = d['traditions'];
    if (t is Map) {
      t.forEach((cat, v) {
        if (v is! Map) return;
        final names = <String, String>{};
        final nm = v['name'];
        if (nm is Map) {
          nm.forEach((k, val) => names['$k'] = '$val');
        }
        final qs = <Question>[];
        final list = v['qs'];
        if (list is List) {
          for (final e in list) {
            if (e is Map<String, dynamic>) qs.add(Question.fromJson(e));
          }
        }
        traditions['$cat'] = Tradition(
          names: names,
          icon: '${v['icon'] ?? ''}',
          questions: qs,
        );
      });
    }

    final meta = d['meta'];
    if (meta is Map) lastUpdated = '${meta['last_updated'] ?? ''}';
  }

  Map<String, List<Question>> _parseSubjects(dynamic s) {
    final out = <String, List<Question>>{};
    if (s is Map) {
      s.forEach((k, v) {
        if (v is List) {
          out['$k'] = v
              .whereType<Map<String, dynamic>>()
              .map(Question.fromJson)
              .toList();
        }
      });
    }
    return out;
  }
}
