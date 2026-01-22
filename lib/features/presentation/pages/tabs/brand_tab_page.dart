import 'package:flutter/material.dart';

class BrandTabPage extends StatelessWidget {
  const BrandTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brand')),
      body: Center(
        child: Text('Brand Page', style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
