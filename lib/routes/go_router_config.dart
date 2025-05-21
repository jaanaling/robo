// 🎉 Fancy page-transition powered GoRouter + global background image
// -----------------------------------------------------------------------------
//  • Каждую страницу оборачиваем в Stack с фоновым изображением.
//  • Переходы остаются прежними (fade / slide / scale), фон НЕ анимируется
//    повторно, поэтому не мерцает.
// -----------------------------------------------------------------------------
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:neuro_robot/src/feature/rituals/presentation/home_screen.dart';
import 'package:neuro_robot/src/feature/rituals/presentation/achievement_screen.dart';
import 'package:neuro_robot/src/feature/rituals/presentation/article_screen.dart';
import 'package:neuro_robot/src/feature/rituals/presentation/articles_screen.dart';
import 'package:neuro_robot/src/feature/rituals/presentation/game_screen.dart';
import 'package:neuro_robot/src/feature/rituals/presentation/initial_screen.dart';
import 'package:neuro_robot/src/feature/rituals/presentation/select_screen.dart';

import 'package:neuro_robot/src/feature/rituals/model/article.dart';
import 'package:neuro_robot/src/feature/splash/presentation/screens/splash_screen.dart';

import 'package:neuro_robot/src/core/utils/icon_provider.dart'; // 👈 фон

import 'root_navigation_screen.dart';
import 'route_value.dart';

// -----------------------------------------------------------------------------
//  Helper: общий фон
// -----------------------------------------------------------------------------
Widget _withBg(Widget child) => Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(IconProvider.background.buildImageUrl()),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        child,
      ],
    );

// -----------------------------------------------------------------------------
//  Helpers: разные типы переходов (оборачиваем в _withBg)
// -----------------------------------------------------------------------------
CustomTransitionPage<T> _fade<T>(Widget child) => CustomTransitionPage<T>(
      transitionDuration: const Duration(milliseconds: 400),
      child: _withBg(child),
      transitionsBuilder: (context, anim, secAnim, child) =>
          FadeTransition(opacity: anim, child: child),
    );

CustomTransitionPage<T> _slideRight<T>(Widget child) => CustomTransitionPage<T>(
      transitionDuration: const Duration(milliseconds: 450),
      child: _withBg(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(animation),
        child: child,
      ),
    );

CustomTransitionPage<T> _scale<T>(Widget child) => CustomTransitionPage<T>(
      transitionDuration: const Duration(milliseconds: 450),
      child: _withBg(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        )),
        child: child,
      ),
    );

CustomTransitionPage<T> _slideUp<T>(Widget child) => CustomTransitionPage<T>(
      transitionDuration: const Duration(milliseconds: 450),
      child: _withBg(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutQuint))
            .animate(animation),
        child: child,
      ),
    );

// -----------------------------------------------------------------------------
//  Router
// -----------------------------------------------------------------------------
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _articlesNavigatorKey = GlobalKey<NavigatorState>();
final _achievementsNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildGoRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteValue.splash.path,
  routes: <RouteBase>[
    // ---------- Bottom-navigation root ----------
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, navigationShell) => _fade(
        RootNavigationScreen(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: RouteValue.home.path,
              pageBuilder: (context, state) => _fade(const HomeScreen()),
              routes: [
                // Articles list
                GoRoute(
                  path: RouteValue.articles.path,
                  pageBuilder: (context, state) => _slideRight(const ArticlesScreen()),
                  routes: [
                    GoRoute(
                      path: RouteValue.article.path,
                      pageBuilder: (context, state) {
                        final article = state.extra! as Article;
                        return _slideRight(ArticleScreen(article: article));
                      },
                    ),
                  ],
                ),
                // Achievements
                GoRoute(
                  path: RouteValue.achievements.path,
                  pageBuilder: (context, state) => _scale(const AchievementScreen()),
                ),
                // Level map / game branch
                GoRoute(
                  path: RouteValue.select.path,
                  pageBuilder: (context, state) => _fade(const LevelMapScreen()),
                  routes: [
                    GoRoute(
                      path: RouteValue.initial.path,
                      pageBuilder: (context, state) => _slideUp(
                        InitialScreen(id: state.extra! as int),
                      ),
                      routes: [
                        GoRoute(
                          path: RouteValue.game.path,
                          pageBuilder: (context, state) => _scale(
                            GameScreen(puzzleId: state.extra! as int),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ---------- Splash ----------
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state, child) => _fade(
        CupertinoPageScaffold(backgroundColor: Colors.transparent, child: child),
      ),
      routes: [
        GoRoute(
          path: RouteValue.splash.path,
          builder: (context, state) => const SplashScreen(),
        ),
      ],
    ),
  ],
);
