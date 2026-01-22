/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/auth_page_container.dart';

import '../../../../core/theme/gradient_widgets.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ReAuthPage extends StatefulWidget {
  const ReAuthPage({super.key});

  @override
  State<ReAuthPage> createState() => _ReAuthPageState();
}

class _ReAuthPageState extends State<ReAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required.';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    if (!ok) return 'Enter a valid email.';
    return null;
  }

  String? _passwordValidator(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Password is required.';
    if (s.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  void _submit(BuildContext context, {required bool loading}) {
    if (loading) return;
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    context.read<AuthBloc>().add(
          ReauthenticateRequested(email.text.trim(), password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => c is AuthError,
      listener: (context, state) {
        if (state is AuthError) AppSnackbar.show(context, state.message);
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          body: AuthBackground(
            child: AuthPageContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset('assets/logos/vlogo.png', height: 90),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Re-authenticate',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: email,
                      enabled: !loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _emailValidator,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: password,
                      enabled: !loading,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: _passwordValidator,
                      onFieldSubmitted: (_) => _submit(context, loading: loading),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 50,
                      child: GradientButton(
                        text: loading ? 'Please wait...' : 'Re-authenticate',
                        onPressed: loading ? null : () => _submit(context, loading: loading),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Use this before deleting your account if Firebase asks for recent login.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/auth_page_container.dart';
import '../../../../core/theme/gradient_widgets.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ReAuthPage extends StatefulWidget {
  const ReAuthPage({super.key});

  @override
  State<ReAuthPage> createState() => _ReAuthPageState();
}

class _ReAuthPageState extends State<ReAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required.';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    if (!ok) return 'Enter a valid email.';
    return null;
  }

  String? _passwordValidator(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Password is required.';
    if (s.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  void _submit({required bool loading}) {
    if (loading) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    context.read<AuthBloc>().add(
          ReauthenticateRequested(email.text.trim(), password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackbar.show(context, state.message);
        }

        // ✅ when reauth succeeds, return true to previous page
        if (state is AuthReauthenticated) {
          context.pop(true);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          body: AuthBackground(
            child: AuthPageContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset('assets/logos/vlogo.png', height: 90),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Re-authenticate',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: email,
                      enabled: !loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _emailValidator,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: password,
                      enabled: !loading,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: _passwordValidator,
                      onFieldSubmitted: (_) => _submit(loading: loading),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 50,
                      child: GradientButton(
                        text: loading ? 'Please wait...' : 'Re-authenticate',
                        onPressed: loading ? null : () => _submit(loading: loading),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'This is required before deleting your account.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
