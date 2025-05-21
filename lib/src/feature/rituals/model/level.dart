// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Level {
  int id;
  int? score;
  String lore;
  String word;
  String hint;

  Level({
    required this.id,
    this.score,
    required this.lore,
    required this.word,
    required this.hint,
  });

  Level copyWith({
    int? id,
    int? score,
    String? lore,
    String? word,
    String? hint,
  }) {
    return Level(
      id: id ?? this.id,
      score: score ?? this.score,
      lore: lore ?? this.lore,
      word: word ?? this.word,
      hint: hint ?? this.hint,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'score': score,
      'lore': lore,
      'word': word,
      'hint': hint,
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      id: map['id'] as int,
      score: map['score'] as int?,
      lore: map['lore'] as String,
      word: map['word'] as String,
      hint: map['hint'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Level.fromJson(String source) =>
      Level.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Level(id: $id, score: $score)';

  @override
  bool operator ==(covariant Level other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.lore == lore &&
        other.word == word &&
        other.hint == hint &&
        other.score == score;
  }

  @override
  int get hashCode => id.hashCode ^ score.hashCode;
}
