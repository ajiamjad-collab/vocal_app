import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';

// ✅ Theme
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

// ✅ Listeners (must be under MaterialApp)
import 'shared/widgets/auth_error_listener.dart';
import 'shared/widgets/session_expiry_listener.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => sl<ThemeCubit>(),
      child: Builder(
        builder: (context) {
          final router = buildRouter(context);

          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                title: 'Marketplace',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: mode,

                // ✅ THIS is the key: listeners are now inside MaterialApp
                builder: (context, child) {
                  final safeChild = child ?? const SizedBox.shrink();
                  return SessionExpiryListener(
                    child: AuthErrorListener(
                      child: safeChild,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
