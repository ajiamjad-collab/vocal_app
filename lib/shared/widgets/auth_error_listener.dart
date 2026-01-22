import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/presentation/bloc/auth_bloc.dart';
import '../../features/presentation/bloc/auth_event.dart';
import '../../features/presentation/bloc/auth_state.dart';

class AuthErrorListener extends StatefulWidget {
  final Widget child;
  const AuthErrorListener({super.key, required this.child});

  @override
  State<AuthErrorListener> createState() => _AuthErrorListenerState();
}

class _AuthErrorListenerState extends State<AuthErrorListener> {
  bool _dialogOpen = false;

  Future<void> _showRetryDialog({
    required BuildContext context,
    required String message,
  }) async {
    if (_dialogOpen) return;

    final nav = Navigator.maybeOf(context);
    if (nav == null) return;

    _dialogOpen = true;

    try {
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;

      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          title: const Text('Something went wrong'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Try again'),
            ),
          ],
        ),
      );

      if (retry == true && mounted) {
        context.read<AuthBloc>().add(const AuthRetryLastRequested());
      }
    } finally {
      _dialogOpen = false;
    }
  }

  void _showSnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, c) => c is AuthError,
      listener: (context, state) {
        if (state is! AuthError) return;

        final message = state.exception.message;
        final retryable = state.exception.retryable;

        if (retryable) {
          _showRetryDialog(context: context, message: message);
        } else {
          _showSnack(context, message);
        }
      },
      child: widget.child,
    );
  }
}
