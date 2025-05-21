// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:just_audio/just_audio.dart';
import 'package:neuro_robot/routes/route_value.dart';
import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/src/core/utils/size_utils.dart';
import 'package:neuro_robot/src/feature/rituals/bloc/user_bloc.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';
import 'package:neuro_robot/ui_kit/app_button.dart';
import 'package:neuro_robot/ui_kit/sound_button.dart';
import 'package:neuro_robot/ui_kit/tips_block.dart';

/// ------------------------------------------------------------
///  Виджет отображения звёздочек (0‑3)
/// ------------------------------------------------------------
class Star extends StatelessWidget {
  final int score; // 0‑3
  const Star({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.star,
            size: 70,
            color: i < score ? Colors.amber : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}

/// ------------------------------------------------------------
///  Экран игры: логика изначально сохранена, визуал обновлён
/// ------------------------------------------------------------
class GameScreen extends StatefulWidget {
  final int puzzleId;
  const GameScreen({super.key, required this.puzzleId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  // ----------------------------------------------------------
  //  STATE
  // ----------------------------------------------------------
  List<String?> userInput = [];
  List<bool> showColors = [];
  int currentIndex = 0;

  //  Анимация тряски (если подтвердили неверный ответ)
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  //  qwerty‑клавиатура + спец‑кнопки
  final List<List<String>> keyboardRows = const [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫', '⏎'],
  ];

  //  начало игры – для подсчёта очков по времени
  late final DateTime _startTime;

  //  таймер обратного отсчёта (5 мин = 300 c.)
  Timer? _countdownTimer;
  int _remainingSeconds = 300;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    //  После завершения тряски возвращаем виджет на место
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _startTime = DateTime.now();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  //  Таймер 5 минут
  // ----------------------------------------------------------
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() => showResult(0, false);

  // ----------------------------------------------------------
  //  UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final level = state.levels[widget.puzzleId];
        final answer = level.word.toUpperCase();
        final answerChars = answer.replaceAll(' ', '').split('');
        final answerLength = answerChars.length;
        final words = level.word.split(' ');

        //  заполняем списки при первом build
        userInput =
            userInput.isEmpty ? List.filled(answerLength, null) : userInput;
        showColors =
            showColors.isEmpty ? List.filled(answerLength, false) : showColors;

        final isTablet = isIpad(context);
        final screenW = MediaQuery.of(context).size.width;

        //  находим длину самой длинной строки (для расчёта размера ячеек)
        final int maxLineLen =
            words.map((w) => w.length).reduce((a, b) => a > b ? a : b) + 2;
        final double cellSize = _calcCellSize(screenW, isTablet, maxLineLen);

        return SafeArea(
          bottom: false,
          child: Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event is RawKeyDownEvent)
                _handlePhysicalKey(event, answerChars);
              return KeyEventResult.handled;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // -------------------- Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Back
                      AnimatedButton(
                          child: AppIcon(
                            asset: IconProvider.back.buildImageUrl(),
                            width: isIpad(context) ? 90 : 63,
                            fit: BoxFit.fitWidth,
                          ),
                          onPressed: () {
                            context.pop();
                          }),
                      const Spacer(),
                      // Timer
                      Row(
                        children: [
                          AppIcon(
                              asset: IconProvider.timer.buildImageUrl(),
                              width: 30),
                          const Gap(4),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Sound + hints
                      Row(
                        children: [
                          SoundButton(),
                          const Gap(8),
                          TipsBlock(
                            tipsCount: state.user.hints,
                            onPressed: () => revealHint(answerChars),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(8),

                // -------------------- Hint panel (белый прямоугольник)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level.hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 40 : 20,
                        color: Colors.deepPurple.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(24),

                // -------------------- Answer grid (фиолетовый контейнер)
                Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 96 : 32),
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF813BFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _buildAnswerLines(words, answerChars, cellSize),
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // -------------------- Keyboard
                _buildKeyboard(answerChars, isTablet),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  //  Answer UI (ячейки)
  // ----------------------------------------------------------
  double _calcCellSize(double width, bool tablet, int maxLineLen) {
    final horizontalPadding = tablet ? 110 : 40; // край + внутренний
    final spacing = 8 * (maxLineLen - 1);
    return (width - horizontalPadding - spacing) / maxLineLen;
  }

  Widget _buildAnswerLines(
      List<String> words, List<String> answerChars, double cell) {
    final lines = <Widget>[];
    int idx = 0; // индекс внутри userInput

    for (final word in words) {
      final cells = List.generate(word.length, (i) {
        final index = idx + i;

        //  определяем цвет ячейки
        Color tileColor = const Color(0xFFE9D1FF);
        if (showColors[index]) {
          final correct = userInput[index]?.toUpperCase() == answerChars[index];
          tileColor =
              correct ? const Color(0xFF44D12B) : const Color(0xFFD32626);
        }

        return Container(
          width: cell,
          height: cell,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              userInput[index] ?? '',
              key: ValueKey(userInput[index] ?? 'empty$index'),
              style: TextStyle(
                fontSize: cell * 0.6,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple.shade900,
              ),
            ),
          ),
        );
      });

      lines.add(Wrap(alignment: WrapAlignment.center, children: cells));
      idx += word.length;
      lines.add(const Gap(8));
    }
    return Column(children: lines);
  }

  // ----------------------------------------------------------
  //  Keyboard UI
  // ----------------------------------------------------------
  Widget _buildKeyboard(List<String> answerChars, bool tablet) {
    final keySize = tablet ? 55.0 : 35.0;
    final filled = !userInput.contains(null);

    return Material(
      elevation: 20,
      color: const Color(0xFF23054C),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: keyboardRows.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isEnter = key == '⏎';
                final double width = isEnter ? keySize * 1.5 : keySize;
                final isDisabledEnter = isEnter && !filled;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isDisabledEnter
                        ? null
                        : () => handleLetterInput(key, answerChars),
                    child: Container(
                      width: width,
                      height: keySize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDisabledEnter
                            ? Colors.grey.shade700
                            : const Color(0xFF813BFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          key,
                          style: TextStyle(
                            fontSize: tablet ? 28 : 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  //  Key handlers
  // ----------------------------------------------------------
  void handleLetterInput(String letter, List<String> answerChars) {
    setState(() {
      if (letter == '⌫') {
        _handleBackspace(answerChars);
      } else if (letter == '⏎') {
        _handleConfirm(answerChars);
      } else {
        _handleCharacter(letter, answerChars);
      }
    });
  }

  void _handleBackspace(List<String> answerChars) {
    if (isPlaying.value) {
      final player1 = AudioPlayer();
      player1.setAsset('assets/music/remove.wav');

      player1.play();
    }
    if (currentIndex > 0) {
      int erase = currentIndex - 1;
      //  пропускаем только ЗЕЛЁНЫЕ клетки, красные стираем
      while (erase >= 0 &&
          showColors[erase] &&
          userInput[erase]?.toUpperCase() == answerChars[erase]) {
        erase--;
      }
      if (erase >= 0) {
        userInput[erase] = null;
        showColors[erase] = false; // возвращаем нейтральный фон
        currentIndex = erase;
      }
    }
  }

  Future<void> _handleConfirm(List<String> answerChars) async {
    if (userInput.contains(null)) return; //  не все заполнено
    if (isPlaying.value) {
      final player1 = AudioPlayer();
      player1.setAsset('assets/music/enter.wav');

      player1.play();
    }
    showColors = List.generate(userInput.length, (_) => true);

    final correct = List.generate(
        userInput.length, (i) => userInput[i]!.toUpperCase() == answerChars[i]);
    final isWin = correct.every((e) => e);

    setState(() {});

    if (!isWin) {
      _shakeController.forward(from: 0);
      if (await Haptics.canVibrate()) await Haptics.vibrate(HapticsType.error);
      return;
    }

    //  успех — вычисляем очки и сохраняем их в BLoC
    _countdownTimer?.cancel();
    if (await Haptics.canVibrate()) await Haptics.vibrate(HapticsType.success);

    final elapsed = DateTime.now().difference(_startTime);
    final score = _calculateScore(elapsed);

    context.read<UserBloc>().add(UserPuzzleSolved(
        isCorrect: true, puzzleId: widget.puzzleId, score: score));

    showResult(score, true);
  }

  void _handleCharacter(String letter, List<String> answerChars) {
    if (currentIndex >= userInput.length) return;
    //  пропускаем клетки, которые уже правильные (зелёные)
    if (isPlaying.value) {
      final player1 = AudioPlayer();
      player1.setAsset('assets/music/key.wav');

      player1.play();
    }
    while (currentIndex < userInput.length &&
        showColors[currentIndex] &&
        userInput[currentIndex]?.toUpperCase() == answerChars[currentIndex]) {
      currentIndex++;
    }

    if (currentIndex < userInput.length) {
      userInput[currentIndex] = letter;
      currentIndex++;
    } 
  }

  void _handlePhysicalKey(RawKeyEvent event, List<String> answerChars) {
    final String keyLabel = event.logicalKey.keyLabel.toUpperCase();
    if (keyLabel == 'BACKSPACE') {
      handleLetterInput('⌫', answerChars);
    } else if (keyLabel == 'ENTER') {
      handleLetterInput('⏎', answerChars);
    } else if (keyLabel.length == 1 && keyLabel.contains(RegExp('[A-Z]'))) {
      handleLetterInput(keyLabel, answerChars);
    }
  }

  // ----------------------------------------------------------
  //  Подсказка – открывает первую неправильную букву
  // ----------------------------------------------------------
  void revealHint(List<String> answerChars) {
    final bloc = context.read<UserBloc>();
    if ((bloc.state as UserLoaded).user.hints == 0) return;

    for (int i = 0; i < answerChars.length; i++) {
      if (userInput[i]?.toUpperCase() != answerChars[i]) {
        bloc.add(const UserHintUsed());
        userInput[i] = answerChars[i];
        showColors[i] = true;
        setState(() {});
        break;
      }
    }
  }

  // ----------------------------------------------------------
  //  Utils
  // ----------------------------------------------------------
  String _formatTime(int sec) =>
      '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}'
          .toString();

  int _calculateScore(Duration elapsed) {
    final s = elapsed.inSeconds;
    if (s <= 60) return 3;
    if (s <= 120) return 2;
    if (s < 300) return 1;
    return 0;
  }

  void showResult(int score, bool isWin) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AppIcon(
                    asset: isWin
                        ? IconProvider.winBack.buildImageUrl()
                        : IconProvider.loseBack.buildImageUrl(),
                    fit: BoxFit.fill),
                Column(
                  children: [
                    Column(
                      children: [
                        if (isWin) Star(score: score), // TODO add
                        const Gap(10),
                        Text(
                            isWin
                                ? 'Another step\ntowards life'
                                : "You've missed\nyour target",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'F',
                              fontWeight: FontWeight.bold,
                            )),

                        if (isWin)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('+$score',
                                  style: const TextStyle(
                                      fontSize: 52,
                                      fontFamily: 'F',
                                      fontWeight: FontWeight.bold)),
                              const Gap(10),
                              AppIcon(
                                  asset: IconProvider.tip.buildImageUrl(),
                                  width: 50),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppButton(
                isMenu: false,
                onPressed: () {
                  context
                    ..pop()
                    ..pushReplacement(
                      "${RouteValue.home.path}/${RouteValue.select.path}/${RouteValue.initial.path}",
                      extra: isWin ? widget.puzzleId + 1 : widget.puzzleId,
                    );
                },
                title: isWin ? 'Go Next!' : 'Restart',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
