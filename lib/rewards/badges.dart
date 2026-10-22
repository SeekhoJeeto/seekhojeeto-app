import 'package:flutter/material.dart';

import '../models/progress.dart';

/// A reward a student can earn.
class BadgeDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(Progress p) earned;

  const BadgeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
  });
}

const List<BadgeDef> kBadges = [
  BadgeDef(
    id: 'first_steps',
    title: 'First Steps',
    description: 'Finish your first quiz',
    icon: Icons.flag,
    earned: _firstSteps,
  ),
  BadgeDef(
    id: 'perfect_10',
    title: 'Perfect 10',
    description: 'Score 10 out of 10 in a quiz',
    icon: Icons.star,
    earned: _perfect,
  ),
  BadgeDef(
    id: 'century',
    title: 'Century',
    description: 'Collect 100 points',
    icon: Icons.workspace_premium,
    earned: _century,
  ),
  BadgeDef(
    id: 'streak_3',
    title: 'On a Roll',
    description: 'Play 3 days in a row',
    icon: Icons.local_fire_department,
    earned: _streak3,
  ),
  BadgeDef(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Play 7 days in a row',
    icon: Icons.whatshot,
    earned: _streak7,
  ),
  BadgeDef(
    id: 'explorer',
    title: 'Explorer',
    description: 'Try all three subjects',
    icon: Icons.explore,
    earned: _explorer,
  ),
  BadgeDef(
    id: 'goal_getter',
    title: 'Goal Getter',
    description: 'Reach your daily goal',
    icon: Icons.emoji_events,
    earned: _goalGetter,
  ),
];

bool _firstSteps(Progress p) => p.quizzes >= 1;
bool _perfect(Progress p) => p.bestScore >= 10;
bool _century(Progress p) => p.points >= 100;
bool _streak3(Progress p) => p.streak >= 3;
bool _streak7(Progress p) => p.streak >= 7;
bool _explorer(Progress p) => p.subjects.length >= 3;
bool _goalGetter(Progress p) => p.goalMet;
