import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:neuro_robot/src/core/dependency_injection.dart';
import 'package:neuro_robot/src/feature/rituals/model/achievement.dart';
import 'package:neuro_robot/src/feature/rituals/model/article.dart';
import 'package:neuro_robot/src/feature/rituals/model/level.dart';
import 'package:neuro_robot/src/feature/rituals/model/user.dart';
import 'package:neuro_robot/src/feature/rituals/repository/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final userRepository = locator<UserRepository>();

  UserBloc() : super(const UserLoading()) {
    on<UserLoadData>(_onUserLoadData);
    on<UserDailyReward>(_onUserDailyReward);

    on<UserHintUsed>(_onHintUsed);
    on<UserPuzzleSolved>(_onPuzzleSolved);
    on<UserAchievementEarned>(_onAchievementEarned);
  }
  
  Future<void> _onUserDailyReward(
      UserDailyReward event, Emitter<UserState> emit) async {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;
    final oldUser = current.user;
    final newUser = oldUser.copyWith(hints: oldUser.hints + 2);
    await userRepository.save(newUser);
    emit(current.copyWith(user: newUser));
  }

  Future<void> _onUserLoadData(
    UserLoadData event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final user = await userRepository.load() ?? User.initial;
      final achievements = await userRepository.loadAchievements();
      final articles = await userRepository.loadArticles();
      final levels = await userRepository.loadLevels();

      emit(
        UserLoaded(
          user: user,
          achievements: achievements,
          articles: articles,
          levels: levels,
        ),
      );
    } catch (e) {
      emit(UserError('Произошла ошибка при загрузке: $e'));
    }
  }

  Future<void> _onHintUsed(UserHintUsed event, Emitter<UserState> emit) async {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;

    if (current.user.hints <= 0) return;

    final newHints = current.user.hints - 1;
    final newHintsUsed = current.user.hintsUsed + 1;
    final newUser = current.user.copyWith(
      hints: newHints,
      hintsUsed: newHintsUsed,
    );
    await userRepository.save(newUser);

    emit(current.copyWith(user: newUser));
  }

  Future<void> _onPuzzleSolved(
      UserPuzzleSolved event, Emitter<UserState> emit) async {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;

    final wasCorrect = event.isCorrect;
    final oldUser = current.user;
    final oldLevel = current.levels[event.puzzleId];

    final newPuzzlesSolved = oldUser.puzzlesSolved +
        (wasCorrect && event.puzzleId == oldUser.puzzlesSolved ? 1 : 0);
    final newHint = wasCorrect && event.puzzleId == oldUser.puzzlesSolved
        ? oldUser.hints + event.score
        : oldUser.hints;

    final newUser = oldUser.copyWith(
      hints: newHint,
      puzzlesSolved: newPuzzlesSolved,
      achievements:
          oldUser.achievements.contains(0) ? oldUser.achievements : [1, 5],
    );

    final level = oldLevel.copyWith(score: event.score);

    await userRepository.save(newUser);
    await userRepository.updateLevel(level);

    final newsLevels = await userRepository.loadLevels();
    emit(current.copyWith(user: newUser, levels: newsLevels));

    if (!wasCorrect) return;
  }

  void _onAchievementEarned(
    UserAchievementEarned event,
    Emitter<UserState> emit,
  ) {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;
    final oldUser = current.user;

    if (oldUser.achievements.contains(event.achievementId)) return;

    Achievement? achievement;
    try {
      achievement =
          current.achievements.firstWhere((a) => a.id == event.achievementId);
    } catch (_) {
      return;
    }

    final newAchievements = List<int>.from(oldUser.achievements)
      ..add(achievement.id);

    final newUser = oldUser.copyWith(
      achievements: newAchievements,
    );

    userRepository.save(newUser);

    emit(current.copyWith(user: newUser));
  }
}
