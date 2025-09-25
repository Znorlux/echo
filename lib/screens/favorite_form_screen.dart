import 'package:flutter/material.dart';

class FavoriteFormScreen extends StatelessWidget {
  const FavoriteFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Form'),
      ),
      body: const Center(
        child: Text('Favorite Form Screen'),
      ),
    );
  }
}
