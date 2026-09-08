import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/api_auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repos/auth_repository_impl.dart';
import '../../features/auth/domain/repos/auth_repository.dart';
import '../../features/auth/domain/usecases/has_active_session_usecase.dart';
import '../../features/auth/domain/usecases/load_remembered_account_usecase.dart';
import '../../features/auth/domain/usecases/save_remembered_account_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/validate_sign_in_form_usecase.dart';
import '../../features/auth/domain/usecases/watch_session_expired_usecase.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/auth/presentation/cubit/sign_in_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/translate/data/datasources/api_translation_remote_data_source.dart';
import '../../features/translate/data/datasources/translation_local_data_source.dart';
import '../../features/translate/data/datasources/translation_remote_data_source.dart';
import '../../features/translate/data/repos/translation_repository_impl.dart';
import '../../features/translate/domain/repos/translation_repository.dart';
import '../../features/translate/domain/usecases/check_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/download_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/speak_text_usecase.dart';
import '../../features/translate/domain/usecases/translate_text_usecase.dart';
import '../../features/translate/domain/usecases/watch_online_availability_usecase.dart';
import '../../features/translate/presentation/cubit/translate_cubit.dart';
import '../network/api_endpoints.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_rest_client.dart';
import '../network/rest_client.dart';
import '../services/connectivity_service.dart';
import '../services/flutter_tts_service.dart';
import '../services/tts_service.dart';
import '../session/session_manager.dart';

/// Service locator. Register infrastructure, repositories, use cases, and
/// cubits here. Feature modules add their registrations as they are built.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Infrastructure (networking, storage, services) ──
  sl.registerLazySingleton(Connectivity.new);
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(sl()),
  );
  sl.registerLazySingleton(OnDeviceTranslatorModelManager.new);
  sl.registerLazySingleton(FlutterTts.new);
  sl.registerLazySingleton<TtsService>(() => FlutterTtsService(sl()));
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  sl.registerLazySingleton(() => const FlutterSecureStorage());
  final sessionManager = SecureSessionManager(sl());
  await sessionManager.restore();
  sl.registerSingleton<SessionManager>(sessionManager);

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(AuthInterceptor(sl()));
    // Debug-only request/response logging, stripped from release builds by
    // the kDebugMode guard. The login call is excluded entirely — its body
    // carries the user's plaintext password and the response carries the
    // raw session token, neither of which may be logged (CLAUDE.md §A-6).
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          responseBody: true,
          filter: (options, _) =>
              Uri.tryParse(options.path)?.path != ApiEndpoints.login,
        ),
      );
    }
    return dio;
  });
  sl.registerLazySingleton<RestClient>(() => DioRestClient(sl()));

  // ── Data sources ──
  sl.registerLazySingleton<TranslationLocalDataSource>(
    () => MlKitTranslationLocalDataSource(sl()),
  );
  sl.registerLazySingleton<TranslationRemoteDataSource>(
    () => ApiTranslationRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => ApiAuthRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => PrefsAuthLocalDataSource(sl()),
  );

  // ── Repositories ──
  sl.registerLazySingleton<TranslationRepository>(
    () => TranslationRepositoryImpl(
      local: sl(),
      connectivity: sl(),
      remote: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(local: sl(), remote: sl(), session: sl()),
  );

  // ── Use cases ──
  sl.registerLazySingleton(() => TranslateTextUseCase(sl()));
  sl.registerLazySingleton(() => CheckTranslationModelsUseCase(sl()));
  sl.registerLazySingleton(() => DownloadTranslationModelsUseCase(sl()));
  sl.registerLazySingleton(() => SpeakTextUseCase(sl()));
  sl.registerLazySingleton(() => WatchOnlineAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(ValidateSignInFormUseCase.new);
  sl.registerLazySingleton(() => LoadRememberedAccountUseCase(sl()));
  sl.registerLazySingleton(() => SaveRememberedAccountUseCase(sl()));
  sl.registerLazySingleton(() => WatchSessionExpiredUseCase(sl()));
  sl.registerLazySingleton(() => HasActiveSessionUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // ── Cubits (registerFactory — fresh instance per route) ──
  sl.registerFactory(() => SplashCubit(hasActiveSession: sl()));
  sl.registerFactory(
    () => SessionCubit(watchSessionExpired: sl(), signOut: sl()),
  );
  sl.registerFactory(
    () => TranslateCubit(
      translateText: sl(),
      checkModels: sl(),
      downloadModels: sl(),
      speakText: sl(),
      watchOnlineAvailability: sl(),
    ),
  );
  sl.registerFactory(
    () => SignInCubit(
      signIn: sl(),
      validate: sl(),
      loadRemembered: sl(),
      saveRemembered: sl(),
    ),
  );
}
