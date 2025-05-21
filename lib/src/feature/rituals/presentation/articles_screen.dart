import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:neuro_robot/routes/route_value.dart';
import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/src/core/utils/size_utils.dart';
import 'package:neuro_robot/src/core/utils/text_with_border.dart';
import 'package:neuro_robot/src/feature/rituals/bloc/user_bloc.dart';
import 'package:neuro_robot/src/feature/rituals/presentation/select_screen.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';
import 'package:neuro_robot/ui_kit/app_button.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});
  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _total = 800;
  static const _delay = 90; // ms per item

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: _total))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<UserBloc, UserState>(builder: (context, state) {
        if (state is! UserLoaded) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF00FB)));
        }

        final articles = state.articles;
        final count = articles.length;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(15),
                // ---------- header ----------
                FadeSlideIn(
                  controller: _ctrl,
                  interval: const Interval(0.0, 0.3, curve: Curves.easeOut),
                  child: Row(
                    children: [
                      AnimatedButton(
                        child: AppIcon(
                            asset: IconProvider.back.buildImageUrl(),
                            width: isIpad(context) ? 90 : 63,
                            fit: BoxFit.fitWidth),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      const TextWithBorder('DATA BASE',
                      fontSize:50 ,
                          ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                const Gap(35),
                // ---------- list ----------
                Expanded(
                  child: ListView.builder(
                    itemCount: count,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      final unlocked = index <= state.user.puzzlesSolved;
                      final interval = Interval(
                          0.1 + (index * _delay) / _total, 1.0,
                          curve: Curves.easeOutCubic);

                      return FadeSlideIn(
                        controller: _ctrl,
                        interval: interval,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AppButton(
                                isMenu: true,
                                onPressed: () {
                                  if (unlocked) {
                                    context.push(
                                        "${RouteValue.home.path}/${RouteValue.articles.path}/${RouteValue.article.path}",
                                        extra: article);
                                  } else {
                                    showLockedDialog(context);
                                  }
                                },
                                title: unlocked ? article.title : '',
                              ),
                              if (!unlocked)
                                const Icon(Icons.lock,
                                    size: 70, color: Colors.white),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

// -----------------------------------------------------------------------------
//  Helper: Fade + Slide transition driven by global controller
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
        .animate(opacity);
    return FadeTransition(
        opacity: opacity,
        child: SlideTransition(position: slide, child: child));
  }
}
