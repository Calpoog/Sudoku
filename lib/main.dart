import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/settings.dart';
import 'pages/home.dart';
import 'pages/saved_games.dart';
import 'pages/settings_page.dart';
import 'pages/sudoku/sudoku_page.dart';
import 'common/colors.dart';
import 'models/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  // SystemChrome.restoreSystemUIOverlays();
  settings.load();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => transition(const PageWrapper(child: HomePage())),
        routes: [
          GoRoute(
            path: 'games',
            name: 'games',
            pageBuilder: (context, state) => transition(
              const PageWrapper(child: SavedGames()),
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (context, state) => transition(
              const PageWrapper(child: SettingsPage()),
            ),
          ),
          GoRoute(
            path: 'sudoku/:id',
            name: 'sudoku',
            pageBuilder: (context, state) {
              return transition(
                  PageWrapper(child: SudokuPage(id: state.params['id']!, game: state.extra as SudokuGame?)));
            },
          ),
        ],
      ),
    ],
    navigatorBuilder: (context, routerState, child) => Scaffold(
      body: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors(
      background: const Color.fromRGBO(40, 41, 45, 1),
      line: const Color.fromRGBO(48, 51, 58, 1),
      surface: const Color.fromRGBO(48, 51, 58, 1),
      text: const Color.fromRGBO(255, 255, 255, 1),
      accent: const Color.fromRGBO(177, 130, 58, 1),
      outline: const Color.fromRGBO(231, 231, 231, 0.2),
      button: const Color.fromRGBO(39, 41, 47, 1),
      icon: const Color.fromRGBO(255, 255, 255, 0.5),
      indicatorDark: const Color.fromRGBO(14, 14, 15, 1),
      indicatorLight: const Color.fromRGBO(55, 57, 61, 1),
      error: const Color(0xFFC62222),
    );

    return MultiProvider(
      providers: [
        Provider.value(value: colors),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: colors.background,
          fontFamily: 'Rubik',
          checkboxTheme: CheckboxThemeData(),
        ),
      ),
    );
  }
}

class PageWrapper extends StatelessWidget {
  const PageWrapper({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: min(constraints.maxWidth, 9 / 16 * constraints.maxHeight)),
            child: child,
          );
        }),
      ),
    );
  }
}

Page transition(Widget child) {
  // return MaterialPage(child: child);
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (_, enter, leave, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(enter),
      child: SlideTransition(
        position: Tween(begin: Offset.zero, end: const Offset(-1, 0)).animate(leave),
        child: child,
      ),
    ),
  );
}
