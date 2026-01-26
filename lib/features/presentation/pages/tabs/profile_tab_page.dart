/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../../../core/routing/route_names.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Re-auth'),
            onTap: () => context.go(RouteNames.reauth),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete account'),
            onTap: () => context.go(RouteNames.deleteAccount),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
    );
  }
}
*/