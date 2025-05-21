import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/src/core/utils/size_utils.dart';
import 'package:neuro_robot/src/feature/rituals/bloc/user_bloc.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});
  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // запускаем анимацию чуть позже, чтобы переход завершился
    Future.delayed(const Duration(milliseconds: 80), _controller.forward);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state is! UserLoaded) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = state.achievements;
      final count = items.length;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              const Gap(15),
              Align(
                alignment: Alignment.topLeft,
                child: AnimatedButton(
                  child: AppIcon(
                    asset: IconProvider.back.buildImageUrl(),
                    width: isIpad(context) ? 90 : 63,
                    fit: BoxFit.fitWidth,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              const Gap(24),
              FadeSlideIn(
                controller: _controller,
                interval: const Interval(0.0, 0.4, curve: Curves.easeOut),
                child: const Text(
                  'NEUROCOLLECTION',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ),
              const Gap(29),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(count, (index) {
                  final achievement = items[index];
                  final unlocked =
                      state.user.achievements.contains(achievement.id);
                  final animInterval = Interval(
                    0.1 + (index / count) * 0.8,
                    0.9,
                    curve: Curves.easeOutBack,
                  );

                  return FadeSlideIn(
                    controller: _controller,
                    interval: animInterval,
                    child: AnimatedButton(
                      onPressed: () => _showDialog(
                          context, achievement.description, achievement.title),
                      child: Stack(
                        alignment: Alignment.center,  
                        children: [
                          ClipOval(
                            child: AppIcon(
                              asset: unlocked
                                  ? "assets/images/${(achievement.id % 5) + 1}.webp"
                                  : IconProvider.close.buildImageUrl(),
                              width: 106,
                              height: 106,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDialog(BuildContext context, String text, String title) {
    showCupertinoModalPopup<void>(
      barrierColor: const Color.fromARGB(193, 30, 0, 76),
      context: context,
      builder: (_) => SizedBox(
        height: 224,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 51, 3, 114),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              width: double.infinity,
            ),
            SizedBox(
              height: 224,
              width: 343,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 33.0, horizontal: 23),
                child: Column(
                  children: [
                    Text(text,
                        style: const TextStyle(fontSize: 26, fontFamily: 'F')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  Helper – комбинированная анимация Fade + Slide + Scale
// -----------------------------------------------------------------------------
class FadeSlideIn extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;
  const FadeSlideIn(
      {super.key,
      required this.controller,
      required this.interval,
      required this.child});

  @override
  Widget build(BuildContext context) {
    final opacity = CurvedAnimation(parent: controller, curve: interval);
    final slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: interval));
    final scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: interval));

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(scale: scale, child: child),
      ),
    );
  }
}
