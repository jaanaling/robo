part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserHintUsed extends UserEvent {
  const UserHintUsed();
}
class UserDailyReward extends UserEvent {
  const UserDailyReward();
}

class UserPuzzleSolved extends UserEvent {
  final bool isCorrect;
  final int puzzleId;
  final int score;


  const UserPuzzleSolved({
    required this.isCorrect,
    required this.puzzleId,
    required this.score,
  });

  @override
  List<Object> get props => [
        isCorrect,
        puzzleId,
        score,
      ];
}

class UserAchievementEarned extends UserEvent {
  final int achievementId;

  const UserAchievementEarned(this.achievementId);

  @override
  List<Object> get props => [achievementId];
}

class UserLoadData extends UserEvent {
  const UserLoadData();
}
