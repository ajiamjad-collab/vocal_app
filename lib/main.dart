import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'firebase_options.dart';
import 'core/di/service_locator.dart';
import 'app.dart';

import 'core/offline/offline_queue.dart';
import 'core/auth/token_refresh_service.dart';

import 'features/presentation/bloc/auth_bloc.dart';
import 'features/presentation/bloc/auth_event.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // ✅ Keep native splash visible until first Flutter frame is ready (mobile)
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Firebase App Check (protects your backend resources)
  // - Android: Debug in debug/profile, Play Integrity in release
  // - Web: optional (if you use it, use ReCaptcha providers)
  // - iOS: optional (App Attest / DeviceCheck if you want)
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    // If you want later:
    // appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
    // webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY'),
  );

  await setupServiceLocator();

  // ✅ Web baseline persistence
  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (_) {}
  }

  // ✅ Start offline queue
  await sl<OfflineQueue>().start();

  // ✅ Token refresh handling -> on error, logout
  sl<TokenRefreshService>().start(
    onUnauthenticated: () async {
      await FirebaseAuth.instance.signOut();
    },
  );

  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  @override
  void initState() {
    super.initState();

    // ✅ Remove native splash AFTER we ensure first frame has assets ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Precache logo to avoid 1-frame white flash (mobile)
      await precacheImage(
        const AssetImage('assets/logos/logo_black.png'),
        context,
      );

      // tiny delay helps some devices
      await Future.delayed(const Duration(milliseconds: 30));

      if (!kIsWeb) FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthStarted()),
        ),
      ],
      child: const App(),
    );
  }
}
