import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vocal_app/features/presentation/bloc/auth_bloc.dart';
import 'package:vocal_app/features/presentation/bloc/auth_state.dart';

import 'package:vocal_app/features/presentation/pages/home_menu_page.dart';
import 'package:vocal_app/features/presentation/pages/delete_account_page.dart';
import 'package:vocal_app/features/presentation/pages/forgot_password_page.dart';
import 'package:vocal_app/features/presentation/pages/login_page.dart';
import 'package:vocal_app/features/presentation/pages/reauth_page.dart';
import 'package:vocal_app/features/presentation/pages/signup_page.dart';
import 'package:vocal_app/features/presentation/pages/verify_email_page.dart';
import 'package:vocal_app/features/presentation/pages/splash_page.dart';

import 'route_names.dart';

GoRouter buildRouter(BuildContext context) {
  final authBloc = context.read<AuthBloc>();

  return GoRouter(
    // ✅ Web starts at login; Mobile starts at splash
    initialLocation: kIsWeb ? RouteNames.login : RouteNames.splash,

    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (context, state) {
      final authState = authBloc.state;
      final loc = state.matchedLocation;

      final isRoot = loc == RouteNames.root;
      final isSplash = loc == RouteNames.splash;

      final isLogin = loc == RouteNames.login;
      final isSignup = loc == RouteNames.signup;
      final isForgot = loc == RouteNames.forgot;
      final isAuthRoute = isLogin || isSignup || isForgot;

      final isVerify = loc == RouteNames.verifyEmail;

      // ✅ Root path behavior:
      // - Web: always land on login
      // - Mobile: send to /splash
      if (isRoot) return kIsWeb ? RouteNames.login : RouteNames.splash;

      // ✅ Web: never show splash route
      if (kIsWeb && isSplash) return RouteNames.login;

      // ✅ ONLY treat AuthInitial as boot/loading.
      // AuthLoading happens during actions (reauth/delete/etc) and MUST NOT redirect.
      if (authState is AuthInitial) {
        if (kIsWeb) return isAuthRoute ? null : RouteNames.login;
        return isSplash ? null : RouteNames.splash;
      }

      // ✅ During AuthLoading: do not redirect anywhere.
      if (authState is AuthLoading) return null;

      if (authState is Unauthenticated) {
        return isAuthRoute ? null : RouteNames.login;
      }

      if (authState is EmailNotVerified) {
        return isVerify ? null : RouteNames.verifyEmail;
      }

      if (authState is Authenticated) {
        if (isSplash || isAuthRoute || isVerify) return RouteNames.home;
        return null;
      }

      return null;
    },

    routes: [
      // ✅ '/' exists mainly for web deep link root
      GoRoute(
        path: RouteNames.root,
        redirect: (_, _) => kIsWeb ? RouteNames.login : RouteNames.splash,
      ),

      // ✅ Mobile splash shows image (web redirect prevents it)
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => const SplashPage(),
      ),

      GoRoute(path: RouteNames.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: RouteNames.signup, builder: (_, _) => const SignupPage()),
      GoRoute(path: RouteNames.forgot, builder: (_, _) => const ForgotPasswordPage()),
      GoRoute(path: RouteNames.verifyEmail, builder: (_, _) => const VerifyEmailPage()),
      GoRoute(path: RouteNames.reauth, builder: (_, _) => const ReAuthPage()),
      GoRoute(path: RouteNames.deleteAccount, builder: (_, _) => const DeleteAccountPage()),
      GoRoute(path: RouteNames.home, builder: (_, _) => const HomeMenuPage()),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
