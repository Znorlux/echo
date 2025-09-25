import 'package:flutter/material.dart';
import 'package:navigation_view/item_navigation_view.dart';
import 'package:navigation_view/navigation_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required bool atBottom,
  }) : _atBottom = atBottom;

  final bool _atBottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationView(
      onChangePage: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/search');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/favorites');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/stats');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/scan');
            break;
        }
      },
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
    );
  }
}
