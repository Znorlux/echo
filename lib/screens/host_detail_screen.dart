import 'package:flutter/material.dart';

class HostDetailScreen extends StatelessWidget {
  const HostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Detail'),
      ),
      body: const Center(
        child: Text('Host Detail Screen'),
      ),
    );
  }
}
