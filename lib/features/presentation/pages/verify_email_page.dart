/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/auth_page_container.dart';
import '../../../../core/theme/gradient_widgets.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => c is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackbar.show(context, state.message);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          body: AuthBackground(
            child: AuthPageContainer(
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
                    'Verify Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'We sent a verification email to your inbox.\n\nAfter verifying, tap "I verified" to continue.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    height: 50,
                    child: GradientButton(
                      text: loading ? 'Please wait...' : 'Resend verification email',
                      onPressed: loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(const SendEmailVerificationRequested());
                              AppSnackbar.show(context, 'Verification email sent (if possible).');
                            },
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
                          onTap: loading
                              ? null
                              : () => context.read<AuthBloc>().add(const ReloadUserRequested()),
                          child: Center(
                            child: Text(
                              loading ? 'Checking...' : 'I verified',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: loading ? null : () => context.read<AuthBloc>().add(const SignOutRequested()),
                    child: const Text('Sign out'),
                  ),
                ],
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

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/auth_page_container.dart';
import '../../../../core/theme/gradient_widgets.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // ✅ Keep your logic: only show errors here
      listenWhen: (p, c) => c is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackbar.show(context, state.message);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          body: AuthBackground(
            child: AuthPageContainer(
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
                    'Verify Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'We sent a verification email to your inbox.\n\nAfter verifying, tap "I verified" to continue.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    height: 50,
                    child: GradientButton(
                      text: loading
                          ? 'Please wait...'
                          : 'Resend verification email',
                      onPressed: loading
                          ? null
                          : () {
                              context
                                  .read<AuthBloc>()
                                  .add(const SendEmailVerificationRequested());
                              AppSnackbar.show(
                                context,
                                'Verification email sent (if possible).',
                              );
                            },
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
                          onTap: loading
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const ReloadUserRequested()),
                          child: Center(
                            child: Text(
                              loading ? 'Checking...' : 'I verified',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: loading
                        ? null
                        : () => context
                            .read<AuthBloc>()
                            .add(const SignOutRequested()),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
