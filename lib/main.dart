import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/settings.dart';
import 'models/solver.dart';
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

  // Hard I guess
  // Solution.fromString('.....6....59.....82....8....45........3........6..3.54...325..6..................');

  // XWing
  // Solution.fromString('2....7...7........1..................2974.5185....9...9........8.........7395.281');

  // Coloring with 2 of same color in unit
  // Solution.fromString('123...587..5817239987...164.51..847339.75.6187.81..925.76...89153..8174681..7.352');

  // Coloring with opposite colors in unit
  // Solution.fromString('..85.21.335...12.8.21.3..5.56324.7.14821.753.179.53..2.3..2581.8.731..25215.843..');

  // Coloring with uncolored square seeing two colors
  // Solution.fromString('..463.5..6.54.1..337..5964.938.6.154457198362216345987.435.6.19.6.9.34.55.9.14.36');

  // YWings https://www.sudokuwiki.org/Y_Wing_Strategy
  Solution.fromString('9..24.....5.69.231.2..5..9..9.7..32...29356.7.7...29...69.2..7351..79.622.7.86..9');

  // From "Sudoku: The Clean One"
  // "Medium"
  // Solution.fromString('.465..3..1..43.7.57....8...5.....8...87..6.5.96..8.14.85412.....2.86........5.218');
  // "Hard"
  // Solution.fromString('9..75..68.2...95.16.7.3.24.....6.45...5.2...3.....56.......312..1428..9.....7..3.');
  // "Extreme"
  // Solution.fromString('..5.....8...18...7.....412...9.....2.4.3..5..5.6..7.8.6...9...1.2...5....9.6..7..');

  // From sudokuoftheday.com
  // Fiendish
  // Solution.fromString('...14..53........9..5.9..2.8....2....3.4.7.9....9....2.4..6.7..3........56..14...');
  // Diabolical
  // Solution.fromString('3.......97.24...5...5.6....4...72.8....5.4....7.61...2....4.3...5...71.828......4');

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
