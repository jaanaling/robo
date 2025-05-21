// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class User {
  int hints; // подсказки
  List<int> achievements; // список id достижений, которые уже получены
  int puzzlesSolved; // сколько всего загадок решено
  int hintsUsed; // сколько раз использовались подсказки

  User({
    required this.hints,
    required this.achievements,
    required this.puzzlesSolved,
    required this.hintsUsed,
  });

  User copyWith({
    int? hints,
    List<int>? achievements,
    int? puzzlesSolved,
    int? hintsUsed,
  }) {
    return User(
      hints: hints ?? this.hints,
      achievements: achievements ?? this.achievements,
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      hintsUsed: hintsUsed ?? this.hintsUsed,
    );
  }

  static User get initial => User(
        hints: 1,
        achievements: [],
        puzzlesSolved: 0,
        hintsUsed: 0,
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hints': hints,
      'achievements': achievements,
      'puzzlesSolved': puzzlesSolved,
      'hintsUsed': hintsUsed,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      hints: map['hints'] as int,
      achievements: List<int>.from(map['achievements'] as List<dynamic>),
      puzzlesSolved: map['puzzlesSolved'] as int,
      hintsUsed: map['hintsUsed'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel( hints: $hints, achievements: $achievements, puzzlesSolved: $puzzlesSolved, hintsUsed: $hintsUsed,)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.hints == hints &&
        listEquals(other.achievements, achievements) &&
        other.puzzlesSolved == puzzlesSolved &&
        other.hintsUsed == hintsUsed;
  }

  @override
  int get hashCode {
    return hints.hashCode ^
        achievements.hashCode ^
        puzzlesSolved.hashCode ^
        hintsUsed.hashCode;
  }
}
