import 'package:flutter/material.dart';

class AddTabPage extends StatelessWidget {
  const AddTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add')),
      body: Center(
        child: Text('Add Page (from FAB)', style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
