import 'package:flutter/material.dart';
import 'package:myapp/config/app_theme.dart';
import 'screens/search_screen.dart';
import 'screens/host_detail_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/dns_tools_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/favorites_list_screen.dart';
import 'screens/favorite_form_screen.dart';
import "widgets/home_shell.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomeShell(),
      routes: {
        '/search': (context) => const SearchScreen(),
        '/detail': (context) => const HostDetailScreen(),
        '/stats': (context) => const StatsScreen(),
        '/scan': (context) => const ScanScreen(),
        '/dns': (context) => const DnsToolsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/favorites': (context) => const FavoritesListScreen(),
        '/favorites/form': (context) => const FavoriteFormScreen(),
      },
    );
  }
}
