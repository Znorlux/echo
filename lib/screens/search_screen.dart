import 'package:flutter/material.dart';
import '../widgets/navbar.dart'; // Importa el widget

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Text('Search Screen'),
      ),
      bottomNavigationBar: const NavBar(atBottom: true,), // Pasa el índice
    );
  }
}
