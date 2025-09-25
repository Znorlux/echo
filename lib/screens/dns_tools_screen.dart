import 'package:flutter/material.dart';

class DnsToolsScreen extends StatelessWidget {
  const DnsToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DNS Tools'),
      ),
      body: const Center(
        child: Text('DNS Tools Screen'),
      ),
    );
  }
}
