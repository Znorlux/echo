import 'package:flutter/material.dart';
import 'package:navigation_view/navigation_view.dart';
import 'package:navigation_view/item_navigation_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// importa tus pantallas
import '../screens/search_screen.dart';
import '../screens/favorites_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/scan_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    SearchScreen(),
    FavoritesListScreen(),
    ProfileScreen(),
    StatsScreen(),
    ScanScreen(),
  ];

  //final _titles = const ['Search', 'Favorites', 'Profile', 'Stats', 'Scan'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      //appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: _pages),

      bottomNavigationBar: NavigationView(
        onChangePage: (i) => setState(() => _index = i),
        curve: Curves.fastEaseInToSlowEaseOut,
        durationAnimation: const Duration(milliseconds: 400),
        backgroundColor: theme.scaffoldBackgroundColor,
        color: Colors.greenAccent,
        items: [
          ItemNavigationView(
            childAfter: Icon(
              PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
              color: Colors.greenAccent,
              size: 32,
            ),
            childBefore: Icon(
              PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
              color: Colors.greenAccent,
              size: 28,
            ),
          ),
          ItemNavigationView(
            childAfter: Icon(
              PhosphorIcons.star(PhosphorIconsStyle.fill),
              color: Colors.greenAccent,
              size: 32,
            ),
            childBefore: Icon(
              PhosphorIcons.star(PhosphorIconsStyle.regular),
              color: Colors.greenAccent,
              size: 28,
            ),
          ),
          ItemNavigationView(
            childAfter: Icon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
              color: Colors.greenAccent,
              size: 32,
            ),
            childBefore: Icon(
              PhosphorIcons.user(PhosphorIconsStyle.regular),
              color: Colors.greenAccent,
              size: 28,
            ),
          ),
          ItemNavigationView(
            childAfter: Icon(
              PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
              color: Colors.greenAccent,
              size: 32,
            ),
            childBefore: Icon(
              PhosphorIcons.chartBar(PhosphorIconsStyle.regular),
              color: Colors.greenAccent,
              size: 28,
            ),
          ),
          ItemNavigationView(
            childAfter: Icon(
              PhosphorIcons.target(PhosphorIconsStyle.fill),
              color: Colors.greenAccent,
              size: 32,
            ),
            childBefore: Icon(
              PhosphorIcons.target(PhosphorIconsStyle.regular),
              color: Colors.greenAccent,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
