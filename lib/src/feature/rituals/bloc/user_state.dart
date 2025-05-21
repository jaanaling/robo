part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final User user;
  final List<Achievement> achievements;
  final List<Article> articles;
  final List<Level> levels;

  const UserLoaded({
    required this.user,
    required this.achievements,
    required this.articles,
    required this.levels,
  });

  UserLoaded copyWith({
    User? user,
    List<Achievement>? achievements,
    List<Article>? articles,
    List<Level>? levels,
  }) {
    return UserLoaded(
      user: user ?? this.user,
      achievements: achievements ?? this.achievements,
      articles: articles ?? this.articles,
      levels: levels ?? this.levels,
    );
  }

  @override
  List<Object?> get props => [user, achievements, articles, levels];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
