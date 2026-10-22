import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import '../rewards/badges.dart';
import 'auth_service.dart';

/// Keeps the student's progress. When signed in it is stored privately in
/// Firestore under users/{uid}; a guest's progress lasts only for the session.
class ProgressService extends ChangeNotifier {
  ProgressService(this._auth) {
    _sub = _auth.authStateChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  final AuthService _auth;
  StreamSubscription<User?>? _sub;

  Progress progress = Progress();
  bool loading = false;

  /// True only when we can actually save to the student's own cloud document.
  bool get saved => _auth.firebaseReady && _auth.currentUser != null;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null || !_auth.firebaseReady) {
      progress = Progress();
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      progress = doc.exists ? Progress.fromMap(doc.data() ?? {}) : Progress();
    } catch (_) {
      progress = Progress();
    }
    loading = false;
    notifyListeners();
  }

  /// Called when a quiz is finished. Updates points, streak, daily goal and
  /// badges, then saves to the student's own document if signed in.
  Future<void> recordQuiz({
    required String subjectId,
    required int correct,
    required int total,
  }) async {
    if (total <= 0) return;

    final today = _dayString(DateTime.now());
    final yesterday =
        _dayString(DateTime.now().subtract(const Duration(days: 1)));

    final p = progress;

    var streak = p.streak;
    if (p.lastPlayed != today) {
      streak = (p.lastPlayed == yesterday) ? streak + 1 : 1;
    }

    var dailyCount = p.dailyDate == today ? p.dailyCount : 0;
    dailyCount += total;

    p.points += correct * 10 + (correct == total ? 5 : 0);
    p.quizzes += 1;
    p.correct += correct;
    p.total += total;
    if (correct > p.bestScore) p.bestScore = correct;
    p.streak = streak;
    p.dailyCount = dailyCount;
    p.dailyDate = today;
    p.lastPlayed = today;

    final subjects = Map<String, dynamic>.from(p.subjects);
    final s = Map<String, dynamic>.from((subjects[subjectId] as Map?) ?? {});
    s['correct'] = ((s['correct'] ?? 0) as num).toInt() + correct;
    s['total'] = ((s['total'] ?? 0) as num).toInt() + total;
    s['quizzes'] = ((s['quizzes'] ?? 0) as num).toInt() + 1;
    subjects[subjectId] = s;
    p.subjects = subjects;

    final earned = p.badges.toSet();
    for (final b in kBadges) {
      if (b.earned(p)) earned.add(b.id);
    }
    p.badges = earned.toList();

    progress = p;
    notifyListeners();

    final user = _auth.currentUser;
    if (_auth.firebaseReady && user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(p.toMap(), SetOptions(merge: true));
      } catch (_) {
        // Saving failed (offline). Progress stays for this session.
      }
    }
  }

  String _dayString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
