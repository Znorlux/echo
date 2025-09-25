import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/search_screen.dart';
import 'screens/host_detail_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/dns_tools_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/favorites_list_screen.dart';
import 'screens/favorite_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF262626),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.ptMonoTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.greenAccent,
                displayColor: Colors.greenAccent,
              ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          titleTextStyle: GoogleFonts.ptMono(
            fontSize: 20,
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/search',
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
