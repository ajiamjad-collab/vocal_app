import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/presentation/bloc/auth_bloc.dart';
import '../../features/presentation/bloc/auth_state.dart';

class SessionExpiryListener extends StatefulWidget {
  final Widget child;
  const SessionExpiryListener({super.key, required this.child});

  @override
  State<SessionExpiryListener> createState() => _SessionExpiryListenerState();
}

class _SessionExpiryListenerState extends State<SessionExpiryListener> {
  bool _dialogOpen = false;

  Future<void> _showSessionExpiredDialog() async {
    if (_dialogOpen) return;

    _dialogOpen = true;

    try {
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;

      await showDialog<void>(
        context: context, // ✅ State.context (safe because we checked mounted)
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          title: const Text("Session expired"),
          content: const Text("Please login again to continue."),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is Unauthenticated && prev is! Unauthenticated,
      listener: (_, _) {
        _showSessionExpiredDialog();
      },
      child: widget.child,
    );
  }
}
