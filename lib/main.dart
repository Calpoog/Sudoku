import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/settings.dart';
import 'solver/solver.dart';
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
  // Solution.fromString('..7.836...397.68..82641975364.19.387.8.367....73.48.6.39.87..267649..1382.863.97.');
  // Solution.fromString('2...41..64..6.2.1..16.9...43..12964.142.6.59..695.4..158421637992.4.81656.19..482');

  // Coloring with opposite colors in unit
  // Solution.fromString('..85.21.335...12.8.21.3..5.56324.7.14821.753.179.53..2.3..2581.8.731..25215.843..');

  // Coloring with uncolored square seeing two colors
  // Solution.fromString('..463.5..6.54.1..337..5964.938.6.154457198362216345987.435.6.19.6.9.34.55.9.14.36');

  // YWings https://www.sudokuwiki.org/Y_Wing_Strategy
  // Solution.fromString('9..24.....5.69.231.2..5..9..9.7..32...29356.7.7...29...69.2..7351..79.622.7.86..9');

  // XYZWings https://www.sudokuwiki.org/XYZ_Wing
  // Solution.fromString('.92..175.5..2....8....3.2...75..496.2...6..75.697...3...8.9..2.7....3.899.38...4.');

  // Perfect Swordfish https://www.sudokuwiki.org/Sword_Fish_Strategy
  // Solution.fromString('52941.7.3..6..3..2..32......523...76637.5.2..19.62753.3...6942.2..83.6..96.7423.5');

  // Jellyfish https://www.sudokuwiki.org/Jelly_Fish_Strategy
  // Solution.fromString('..17538...5......77..89.1.....6.157.625478931.179.54......67..4.7.....1...63.97..');

  // Unique Rectangles Rule 1 https://www.sudokuwiki.org/Unique_Rectangles
  // Solution.fromString('..632481585.691.7...1785.....4.3768.38..62147.6741835....173..8...846.21..82597..');
  // Rule 2
  // Solution.fromString('42.9..386.6.2..7948.9.6.2517....3.259..1.26.32..5....8..4.2.5676827..439......812');
  // Rule 2b
  // Solution.fromString('.4186539..9..4..6..3.7924.1.28...94.519624..3.7.9.821.15..8.629.6..19.3.98.2.61..');
  // Rule 2c
  // Solution.fromString('8.9....5.53.8.7.......9.8..2946.813.78.9.1..4.15..4.98..2.8.....581.3.7..6....48.');
  // Rule 3
  // Solution.fromString('...5.347.5..8.4.6.4...96.52857..96.43246.759...6..5.37285.61.4...9..8..5.43952.86');
  // Rule 3b
  // Solution.fromString('419.2...6.6.1.9....3.465921.9.2.1.8...1.5.29..7.9.4.1...65.2.79.5.398.6292......8');
  // Rule 3b with pseudo triple
  // Solution.fromString('7529.8.4.3..21.....1....28..63.82..9.27.9.5.88..1...32271..98.4....213.7.3.874.2.');
  // Rule 4 with pseudo triple
  // Solution.fromString('300200640005040000000050900002000090050000006090000051400863000060007800000400302');

  // X Cycles: Nice Loops Rule 1 https://www.sudokuwiki.org/X_Cycles
  // Solution.fromString('.241..67..6..7.41.7..964.2.2465913871354872968796231544....976.35.71694.697.4..31');

  // X Cycles: Nice Loops Rule 2 https://www.sudokuwiki.org/X_Cycles_Part_2
  // Solution.fromString('8.4537....23614.856.5982.34...1.587.5..7.83.6.8.2.345.2..859..3.5.3712.8..84265.7');

  // X Cycles: Nice Loops Rule 3 https://www.sudokuwiki.org/X_Cycles_Part_2
  // Solution.fromString('.762..4...941.7.6.2..46...7.6.371...74.592.16...684.7.3.97.6..568.9.573.4578.36..');

  // 3D Medusa https://www.sudokuwiki.org/3D_Medusa
  // Rule 1
  // Solution.fromString('.9382456..856....22.6.75..8321769845...2583..578.4.29685..16723..7.8265...25.718.');
  // Rule 2 (and 5)
  Solution.fromString('3...52...25.3...1...46.7523.932..8.557.....3.4.8.35.6...54.83...3.5.6.8484..23.56', true);
  // Rule 4
  // Solution.fromString('1...56..3.43.9....8...43..2.3.56.21.95.421.37.21.3....31798...5...31.97....67.3.1', true);
  // Rule 6
  // Solution.fromString('9867213453.4956..7..7.3.96..73.65..969..17..31..39.276...679.3..691437..731582694');

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
