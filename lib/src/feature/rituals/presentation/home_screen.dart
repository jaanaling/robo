import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import 'package:neuro_robot/routes/route_value.dart';
import 'package:neuro_robot/src/core/utils/app_icon.dart';
import 'package:neuro_robot/src/core/utils/icon_provider.dart';
import 'package:neuro_robot/src/core/utils/size_utils.dart';
import 'package:neuro_robot/src/core/utils/text_with_border.dart';
import 'package:neuro_robot/src/feature/rituals/bloc/user_bloc.dart';
import 'package:neuro_robot/ui_kit/animated_button.dart';
import 'package:neuro_robot/ui_kit/app_button.dart';
import 'package:neuro_robot/ui_kit/sound_button.dart';
import 'package:neuro_robot/ui_kit/tips_block.dart';

/// ---------------------------------------------------------------------------
///  HomeScreen — stagger-in + dailyReward закреплён у нижнего края
/// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _fade;
  late final List<Animation<Offset>> _slide;


  static const _staggerDuration = 110;
  static const _animTotal = 900;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: _animTotal));
    _fade = List.generate(6, (i) {
      final start = (i * _staggerDuration) / _animTotal;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutQuart));
    });
    _slide = List.generate(6, (i) {
      final start = (i * _staggerDuration) / _animTotal;
      final end = (start + 0.5).clamp(start, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.17), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    });
    _controller.forward();

    playMusic();
  }

  @override
  void dispose() {
    _controller.dispose();
  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state is! UserLoaded) return const Center(child: CircularProgressIndicator());

      // -------- основной контент без dailyReward --------
      final content = [
        _buildHeader(state),
        const Gap(35),
        FadeSlide(index: 2, fade: _fade, slide: _slide, child: AppIcon(asset: IconProvider.logo.buildImageUrl(), width: getWidth(context, percent: 0.5))),
        const Gap(35),
        FadeSlide(index: 3, fade: _fade, slide: _slide, child: _menuButton('Enter in mind', RouteValue.select.path)),
        FadeSlide(index: 4, fade: _fade, slide: _slide, child: _menuButton('Data Base', RouteValue.articles.path)),
      ];

      final needReward = state.user.hints == 1 && state.user.hintsUsed == 0;

      return SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ---------- скроллимый контент ----------
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: needReward ? 220 : 40),
              child: Column(children: content),
            ),

            // ---------- reward прикреплён к низу ----------
            if (needReward)
              Align(
                alignment: Alignment.bottomCenter,
                child: FadeSlide(index: 5, fade: _fade, slide: _slide, child: _dailyReward(state)),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(UserLoaded state) => FadeSlide(
        index: 0,
        fade: _fade,
        slide: _slide,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              AnimatedButton(
                child: AppIcon(asset: IconProvider.achivBut.buildImageUrl(), width: isIpad(context) ? 90 : 63, fit: BoxFit.fitWidth),
                onPressed: () => context.push("${RouteValue.home.path}/${RouteValue.achievements.path}"),
              ),
              const Gap(15),
              SoundButton(),
            ]),
            TipsBlock(tipsCount: state.user.hints),
          ],
        ),
      );

  Widget _menuButton(String title, String route) => AppButton(
        isMenu: true,
        onPressed: () => context.push("${RouteValue.home.path}/$route"),
        title: title,
      );

  Widget _dailyReward(UserLoaded state) => Container(
        width: double.infinity,
        height: 340,
        padding: const EdgeInsets.only(top: 25, bottom: 40, left: 20, right: 20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(174, 2, 0, 73),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            TextWithBorder('Daily reward', borderColor: const Color(0xFFFFF52C), color: const Color(0xFF8200EE), fontSize: 40),
            const Gap(8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('+2', style: TextStyle(fontSize: 40, color: Color(0xFFFFF52C))),
              const Gap(30),
              AppIcon(asset: IconProvider.tip.buildImageUrl(), height: 70),
            ]),
            const Gap(25),
            AppButton(isMenu: false, onPressed: () => context.read<UserBloc>().add(const UserDailyReward()), title: 'Claim'),
          ],
        ),
      );
}

class FadeSlide extends StatelessWidget {
  final int index;
  final List<Animation<double>> fade;
  final List<Animation<Offset>> slide;
  final Widget child;
  const FadeSlide({super.key, required this.index, required this.fade, required this.slide, required this.child});

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: fade[index],
        child: SlideTransition(position: slide[index], child: child),
      );
}