import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/service_locator.dart';
import 'core/init/hive_initializer.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/toast/app_toast.dart';
import 'core/widgets/toast/app_toast_scope.dart';
import 'features/app_update/presentation/cubit/app_update_cubit.dart';
import 'features/app_update/presentation/widgets/app_update_gate.dart';
import 'features/auth/presentation/cubit/session_cubit.dart';
import 'features/auth/presentation/cubit/session_state.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.initHive();
  await _initFirebase();
  await configureDependencies();
  runApp(const TranslyApp());
}

class TranslyApp extends StatelessWidget {
  const TranslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<SessionCubit>()),
        BlocProvider(
          create: (_) => serviceLocator<AppUpdateCubit>()..checkForUpdate(),
        ),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        listener: (context, state) {
          switch (state) {
            case SessionExpired():
              _goToSignInWithToast(
                (l10n) => l10n.authErrorSessionExpired,
                Icons.lock_outline_rounded,
              );
            case SessionAccountDeleted():
              _goToSignInWithToast(
                (l10n) => l10n.profileDeleteAccountDone,
                Icons.check_rounded,
              );
            case SessionSignedOut():
              appRouter.goNamed(AppRoutes.signInName);
            case SessionActive():
              break;
          }
        },
        child: MaterialApp.router(
          title: 'Transly AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: appRouter,
          builder: (context, child) => AppToastScope(
            child: AppUpdateGate(child: child ?? const SizedBox.shrink()),
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }

  void _goToSignInWithToast(
    String Function(AppLocalizations l10n) message,
    IconData icon,
  ) {
    appRouter.goNamed(AppRoutes.signInName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navContext = appRouter.routerDelegate.navigatorKey.currentContext;
      if (navContext == null) return;
      final l10n = AppLocalizations.of(navContext);
      if (l10n == null) return;
      AppToast.show(
        navContext,
        message: message(l10n),
        type: AppToastType.neutral,
        icon: icon,
      );
    });
  }
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Firebase.initializeApp() failed: $error');
    }
  }
}
