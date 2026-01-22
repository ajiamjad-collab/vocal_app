import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/local_storage.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_page_container.dart';
import '../../../../shared/widgets/auth_background.dart';

import '../../../../core/theme/gradient_widgets.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final email = TextEditingController();
  final password = TextEditingController();

  bool rememberMe = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    final storage = sl<LocalStorage>();
    rememberMe = storage.rememberMe;
    if (rememberMe) {
      email.text = storage.rememberedEmail;
    }
  }

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
          SignInEmailRequested(
            email.text.trim(),
            password.text,
            rememberMe: rememberMe,
          ),
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
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logos/vlogo.png',
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Login',
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
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: _passwordValidator,
                        onFieldSubmitted: (_) => _submit(context, loading: loading),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword ? 'Show password' : 'Hide password',
                            onPressed: loading ? null : () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: loading ? null : (v) => setState(() => rememberMe = v ?? false),
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: loading ? null : () => context.go(RouteNames.forgot),
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        height: 50,
                        child: GradientButton(
                          text: loading ? 'Please wait...' : 'Login',
                          onPressed: loading ? null : () => _submit(context, loading: loading),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 50,
                        child: GradientOutline(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: loading ? null : () => context.read<AuthBloc>().add(const SignInGoogleRequested()),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/google-icon.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: loading ? null : () => context.go(RouteNames.signup),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
