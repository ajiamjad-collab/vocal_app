import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/auth_page_container.dart';
import '../../../../core/theme/gradient_widgets.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _dialogOpen = false;
  bool _waitingForDeleteResult = false;

  bool _hasProvider(String providerId) {
    final user = sl<FirebaseAuth>().currentUser;
    final providers = user?.providerData.map((p) => p.providerId).toSet() ?? {};
    return providers.contains(providerId);
  }

  String? _passwordValidator(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Password is required.';
    if (s.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  Future<void> _showThankYouAndGoLogin() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(gradient: AppColors.kGradient),
                  child: Row(
                    children: const [
                      Icon(Icons.favorite_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Thank you',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text(
                    'Your account has been deleted successfully.\n\nYou can join back anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: GradientButton(
                      text: 'OK',
                      onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    // ✅ CHANGE THIS if your login route is different
    context.go(RouteNames.login);
  }

  Future<void> _showReauthAndDeleteDialog() async {
    if (_dialogOpen) return;
    _dialogOpen = true;

    final hasPassword = _hasProvider('password');
    final hasGoogle = _hasProvider('google.com');

    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    bool obscure = true;
    bool busy = false;

    void safePop(BuildContext dialogCtx) {
      final nav = Navigator.of(dialogCtx, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    }

    void triggerDeleteWithPassword(BuildContext dialogCtx) {
      final ok = formKey.currentState?.validate() ?? false;
      if (!ok) return;

      if (mounted) setState(() => _waitingForDeleteResult = true);

      busy = true;
      safePop(dialogCtx);

      context.read<AuthBloc>().add(
            DeleteAccountWithPasswordRequested(controller.text),
          );
    }

    void triggerDeleteWithGoogle(BuildContext dialogCtx) {
      if (mounted) setState(() => _waitingForDeleteResult = true);

      busy = true;
      safePop(dialogCtx);

      context.read<AuthBloc>().add(
            const DeleteAccountWithGoogleRequested(),
          );
    }

    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogCtx) {
          final mq = MediaQuery.of(dialogCtx);
          final theme = Theme.of(dialogCtx);

          // ✅ Smaller popup height
          final maxH = mq.size.height * 0.52; // adjust 0.48~0.60 if needed

          return StatefulBuilder(
            builder: (dialogCtx, setStateSB) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxH),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: mq.viewInsets.bottom > 0 ? 8 : 0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(gradient: AppColors.kGradient),
                            child: Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: Colors.white),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Delete account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ✅ Content now uses Flexible, not Expanded (prevents huge empty space)
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Warning card (compact)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.red.withOpacity(0.25)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Icon(Icons.delete_forever_rounded, color: Colors.red),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'This action is permanent.\n'
                                            'Your account and related data will be deleted.\n\n'
                                            'For security, please re-authenticate.',
                                            style: TextStyle(height: 1.2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  if (hasPassword) ...[
                                    Form(
                                      key: formKey,
                                      child: TextFormField(
                                        controller: controller,
                                        enabled: !busy,
                                        obscureText: obscure,
                                        validator: _passwordValidator,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            onPressed: busy
                                                ? null
                                                : () => setStateSB(() => obscure = !obscure),
                                            icon: Icon(
                                              obscure ? Icons.visibility : Icons.visibility_off,
                                            ),
                                          ),
                                        ),
                                        onFieldSubmitted: (_) {
                                          if (busy) return;
                                          setStateSB(() => busy = true);
                                          triggerDeleteWithPassword(dialogCtx);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],

                                  if (hasGoogle) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: busy
                                            ? null
                                            : () {
                                                setStateSB(() => busy = true);
                                                triggerDeleteWithGoogle(dialogCtx);
                                              },
                                        icon: const Icon(Icons.account_circle_outlined),
                                        label: const Text('Continue with Google'),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  if (!hasPassword && !hasGoogle)
                                    Text(
                                      'No supported provider found for re-authentication.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // ✅ Buttons same style + same size (Cancel + Delete)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: GradientButton(
                                      text: 'Cancel',
                                      onPressed: busy ? null : () => safePop(dialogCtx),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: busy
                                          ? null
                                          : () {
                                              if (hasPassword) {
                                                setStateSB(() => busy = true);
                                                triggerDeleteWithPassword(dialogCtx);
                                              } else if (hasGoogle) {
                                                setStateSB(() => busy = true);
                                                triggerDeleteWithGoogle(dialogCtx);
                                              } else {
                                                safePop(dialogCtx);
                                              }
                                            },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      // ✅ Prevent controller disposed while dialog still animating
      _dialogOpen = false;
      await Future<void>.delayed(const Duration(milliseconds: 350));
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          _waitingForDeleteResult = false;
          AppSnackbar.show(context, state.message);
          return;
        }

        if (_waitingForDeleteResult && state is! AuthLoading) {
          final user = sl<FirebaseAuth>().currentUser;
          if (user == null) {
            _waitingForDeleteResult = false;
            await _showThankYouAndGoLogin();
          }
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
                  Center(child: Image.asset('assets/logos/vlogo.png', height: 90)),
                  const SizedBox(height: 12),
                  const Text(
                    'Delete Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'This action is permanent.\nYou will be asked to re-authenticate.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 50,
                    child: GradientButton(
                      text: loading ? 'Please wait...' : 'Delete account',
                      onPressed: loading
                          ? null
                          : () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              await _showReauthAndDeleteDialog();
                            },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: loading ? null : () => context.go(RouteNames.home),
                    child: const Text('Back to Home'),
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
