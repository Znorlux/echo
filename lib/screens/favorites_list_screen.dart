import 'package:flutter/material.dart';

class FavoritesListScreen extends StatelessWidget {
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: const Center(
        child: Text('Favorites List Screen'),
      ),
    );
  }
}
