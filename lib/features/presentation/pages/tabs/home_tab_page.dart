import 'package:flutter/material.dart';
import 'package:vocal_app/features/presentation/pages/tabs/gradient_app_bar.dart';


class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ white scaffold area (or keep Theme light bg)
      backgroundColor: Colors.white,
      appBar: const GradientAppBar(title: 'Vocal 91'),
      body: Center(
        child: Text(
          'Home Page',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
