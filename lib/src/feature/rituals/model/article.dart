import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class Article {
  final String id;
  final String title;
  final String content;

  Article({
    required this.id,
    required this.title,
    required this.content,
  });

  

  Article copyWith({
    String? id,
    String? title,
    String? content,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Article.fromJson(String source) => Article.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Article(id: $id, title: $title, content: $content)';

  @override
  bool operator ==(covariant Article other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.content == content;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ content.hashCode;
}
