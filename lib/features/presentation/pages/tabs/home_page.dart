/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/route_names.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Delete account',
            onPressed: () => context.go(RouteNames.deleteAccount),
            icon: const Icon(Icons.delete_forever),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Authenticated ✅\nNow build Products/Cart/Orders using same template.',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouteNames.reauth),
        label: const Text('Re-auth'),
      ),
    );
  }
}
*/

