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
    required String message,
    required AuthBloc bloc, // ✅ pass bloc instead of using BuildContext after await
  }) async {
    if (_dialogOpen) return;

    _dialogOpen = true;

    try {
      // If you keep this microtask gap, make sure we re-check mounted after it.
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;

      final retry = await showDialog<bool>(
        context: context, // ✅ use State.context (safe when guarded by mounted)
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

      if (!mounted) return;

      if (retry == true) {
        bloc.add(const AuthRetryLastRequested());
      }
    } finally {
      _dialogOpen = false;
    }
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, c) => c is AuthError,
      listener: (ctx, state) {
        if (state is! AuthError) return;

        final message = state.exception.message;
        final retryable = state.exception.retryable;

        // ✅ capture bloc now (no BuildContext usage after awaits)
        final bloc = ctx.read<AuthBloc>();

        if (retryable) {
          _showRetryDialog(message: message, bloc: bloc);
        } else {
          _showSnack(message);
        }
      },
      child: widget.child,
    );
  }
}
