import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/translate/data/datasources/gemini_translation_remote_data_source.dart';
import '../../features/translate/data/datasources/translation_local_data_source.dart';
import '../../features/translate/data/datasources/translation_remote_data_source.dart';
import '../../features/translate/data/repos/translation_repository_impl.dart';
import '../../features/translate/domain/repos/translation_repository.dart';
import '../../features/translate/domain/usecases/check_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/download_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/translate_text_usecase.dart';
import '../../features/translate/presentation/cubit/translate_cubit.dart';
import '../config/app_config.dart';
import '../network/dio_rest_client.dart';
import '../network/rest_client.dart';
import '../services/connectivity_service.dart';
import '../services/tts_service.dart';

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

  // ── Data sources ──
  sl.registerLazySingleton<TranslationLocalDataSource>(
    () => MlKitTranslationLocalDataSource(sl()),
  );
  // Gemini (online) is only registered when a key was supplied at build time
  // via --dart-define=GEMINI_API_KEY=... — otherwise the repository falls
  // back to offline-only, exactly as before this feature existed.
  if (AppConfig.isGeminiConfigured) {
    sl.registerLazySingleton(() {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 10),
      ));
      // Debug-only request/response logging. requestHeader stays false so the
      // x-goog-api-key header is never printed (CLAUDE.md §A-6); logs are
      // stripped from release builds by the kDebugMode guard.
      if (kDebugMode) {
        dio.interceptors.add(PrettyDioLogger(
          requestBody: true,
          responseBody: true,
        ));
      }
      return dio;
    });
    sl.registerLazySingleton<RestClient>(() => DioRestClient(sl()));
    sl.registerLazySingleton<TranslationRemoteDataSource>(
      () => GeminiTranslationRemoteDataSource(
        restClient: sl(),
        apiKey: AppConfig.geminiApiKey,
      ),
    );
  }

  // ── Repositories ──
  sl.registerLazySingleton<TranslationRepository>(
    () => TranslationRepositoryImpl(
      local: sl(),
      connectivity: sl(),
      remote: sl.isRegistered<TranslationRemoteDataSource>()
          ? sl<TranslationRemoteDataSource>()
          : null,
    ),
  );

  // ── Use cases ──
  sl.registerLazySingleton(() => TranslateTextUseCase(sl()));
  sl.registerLazySingleton(() => CheckTranslationModelsUseCase(sl()));
  sl.registerLazySingleton(() => DownloadTranslationModelsUseCase(sl()));

  // ── Cubits (registerFactory — fresh instance per route) ──
  sl.registerFactory(() => SplashCubit());
  sl.registerFactory(
    () => TranslateCubit(
      translateText: sl(),
      checkModels: sl(),
      downloadModels: sl(),
    ),
  );
}
