import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_robot/routes/route_value.dart';
import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/src/core/utils/size_utils.dart';
import 'package:neuro_robot/src/core/utils/text_with_border.dart';
import 'package:neuro_robot/src/feature/rituals/bloc/user_bloc.dart';
import 'package:neuro_robot/src/feature/rituals/model/level.dart';
import 'package:neuro_robot/src/feature/rituals/model/user.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';

// ---------------------------------------------------------------------------
// CONFIGURATION --------------------------------------------------------------

const int totalLevels = 70; // общее число уровней на карте

/// Генератор x-координаты (0‒1). «Зиг-заг» + хаотичная болтанка.
double _xPattern(int i) {
  final double base = i.isEven ? 0.25 : 0.75;
  final double chaos = (math.sin(i * 0.9) + math.cos(i * 1.3)) * 0.08;
  return (base + chaos).clamp(0.10, 0.95);
}

/// Нормализованные точки уровней без учёта вертикальных отступов.
final List<double> _yLinear =
    List<double>.generate(totalLevels, (i) => i / (totalLevels - 1));

// ---------------------------------------------------------------------------
// UI ------------------------------------------------------------------------
class LevelMapScreen extends StatelessWidget {
  const LevelMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Level> levels = state.levels;
        final User user = state.user;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Расчёт «холста» — берём длинную ленту.
            final double canvasHeight = constraints.maxHeight * 10;
            final Size canvasSize = Size(constraints.maxWidth, canvasHeight);

            // Размер кружка в одном месте, чтобы не тащить его везде.
            const double circleRadius = _LevelCircle.radius;

            // Вертикальные отступы, чтобы 1-й и последний кружки не обрезались.
            final double topPad = circleRadius + 80;
            final double bottomPad =
                circleRadius + MediaQuery.of(context).padding.bottom + 16;
            final double usableHeight = canvasHeight - topPad - bottomPad;

            // Генерируем абсолютные точки (px) с учётом паддингов.
            final List<Offset> pointsPx = List.generate(totalLevels, (i) {
              final double x = _xPattern(i) * canvasSize.width;
              final double y = topPad + _yLinear[i] * usableHeight;
              return Offset(x, y);
            });

            return Stack(
              children: [
                // ------------------- СКРОЛЛИРУЕМАЯ КАРТА --------------------
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  controller: ScrollController(
                    initialScrollOffset:
                        state.levels[math.max(0, user.puzzlesSolved - 2)].id *
                            100,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: canvasSize.width,
                    height: canvasSize.height,
                    child: Stack(
                      children: [
                        // ----- ПУТЬ (пунктир) -----
                        CustomPaint(
                          size: canvasSize,
                          painter: LevelPathPainter(points: pointsPx),
                        ),

                        // ----- УРОВНИ -----
                        for (var i = 0; i < levels.length; i++)
                          _LevelCircle(
                            info: levels[i],
                            user: user,
                            center: pointsPx[i],
                          ),
                      ],
                    ),
                  ),
                ),

                // ------------------- TOP-BAR (фикс.) ------------------------
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 8,
                  child: AnimatedButton(
                    child: AppIcon(
                      asset: IconProvider.back.buildImageUrl(),
                      width: isIpad(context) ? 90 : 63,
                      fit: BoxFit.fitWidth,
                    ),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TextWithBorder(
                      'Neurons',
                      fontSize: 40,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// LEVEL CIRCLE WIDGET --------------------------------------------------------
class _LevelCircle extends StatelessWidget {
  const _LevelCircle({
    required this.info,
    required this.user,
    required this.center,
  });

  final Level info;
  final User user;
  final Offset center;

  static const double radius = 80;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius,
      child: AnimatedButton(
        onPressed: () {
          if (info.id - 1 <= user.puzzlesSolved) {
            context.push(
              "${RouteValue.home.path}/${RouteValue.select.path}/${RouteValue.initial.path}",
              extra: info.id - 1,
            );
          } else {
            showLockedDialog(context);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Обводка
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: info.id <= user.puzzlesSolved
                    ? const LinearGradient(
                        colors: [Color(0xFFBA00FF), Color(0xFFFF00D6)])
                    : const LinearGradient(
                        colors: [Color(0xFF5B4E86), Color(0xFF4D4A7B)]),
              ),
            ),
            // Внутренняя заливка
            Container(
              width: radius * 1.68,
              height: radius * 1.68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF7E66CB),
              ),
              alignment: Alignment.center,
              child: info.id - 1 <= user.puzzlesSolved
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${info.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _StarsRow(score: info.score),
                      ],
                    )
                  : Icon(Icons.lock, color: Colors.white, size: radius - 10),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showLockedDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF5938A8),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: const Text(
          'Go through the previous level',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: "F"),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF8E6BFF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () => context.pop(),
            child: const Text('OK',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "F")),
          ),
        ],
      ),
    );

// ---------------------------------------------------------------------------
// STAR WIDGET ----------------------------------------------------------------
class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            Icons.star,
            size: 28,
            color: i < (score ?? 0) ? Colors.yellow : Colors.white24,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LEVEL PATH PAINTER ---------------------------------------------------------
class LevelPathPainter extends CustomPainter {
  LevelPathPainter({
    required this.points,
    this.dashLength = 12,
    this.gapLength = 8,
  }) : _paint = Paint()
          ..color = Colors.white38
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  final List<Offset> points;
  final double dashLength;
  final double gapLength;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (var i = 0; i < points.length - 1; i++) {
      _drawDashedLine(canvas, points[i], points[i + 1]);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end) {
    final totalLength = (end - start).distance;
    final direction = (end - start) / totalLength;

    double drawn = 0;
    while (drawn < totalLength) {
      final currentStart = start + direction * drawn;
      final segmentLength = math.min(dashLength, totalLength - drawn);
      final currentEnd = currentStart + direction * segmentLength;

      canvas.drawLine(currentStart, currentEnd, _paint);
      drawn += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant LevelPathPainter old) =>
      old.points != points ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
