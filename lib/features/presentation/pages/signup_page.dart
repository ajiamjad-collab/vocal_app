import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_page_container.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../core/theme/gradient_widgets.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool agreed = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      AppSnackbar.show(context, 'Invalid link.');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) AppSnackbar.show(context, 'Could not open link.');
  }

  String? _nameValidator(String? v, String field) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return '$field is required.';
    if (s.length < 2) return '$field is too short.';
    return null;
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
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (!agreed) {
      AppSnackbar.show(context, 'Please accept Terms & Privacy Policy.');
      return;
    }

    context.read<AuthBloc>().add(
          SignUpEmailRequested(
            firstName: firstName.text.trim(),
            lastName: lastName.text.trim(),
            email: email.text.trim(),
            password: password.text,
            agreed: agreed,
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
                          'assets/logos/logo_black.png',
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sign Up',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstName,
                              enabled: !loading,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.givenName],
                              validator: (v) => _nameValidator(v, 'First name'),
                              decoration: const InputDecoration(
                                labelText: 'First name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: lastName,
                              enabled: !loading,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.familyName],
                              validator: (v) => _nameValidator(v, 'Last name'),
                              decoration: const InputDecoration(
                                labelText: 'Last name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

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
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _passwordValidator,
                        onFieldSubmitted: (_) => _submit(loading: loading),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword ? 'Show password' : 'Hide password',
                            onPressed: loading ? null : () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: agreed,
                            onChanged: loading ? null : (v) => setState(() => agreed = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: const TextStyle(decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _open('https://example.com/terms'),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _open('https://example.com/privacy'),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 50,
                        child: GradientButton(
                          text: loading ? 'Please wait...' : 'Create account',
                          onPressed: loading ? null : () => _submit(loading: loading),
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
                                    Image.asset('assets/icons/google-icon.png', height: 20, width: 20),
                                    const SizedBox(width: 10),
                                    const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w700)),
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
                          const Text('Already have an account? '),
                          TextButton(
                            onPressed: loading ? null : () => context.go(RouteNames.login),
                            child: const Text('Login'),
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
