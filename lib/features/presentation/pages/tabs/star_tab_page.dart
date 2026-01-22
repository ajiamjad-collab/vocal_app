import 'package:flutter/material.dart';

class StarTabPage extends StatelessWidget {
  const StarTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Star')),
      body: Center(
        child: Text('Star Page', style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
