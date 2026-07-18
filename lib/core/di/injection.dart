import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/translate/data/datasources/translation_local_data_source.dart';
import '../../features/translate/data/repos/translation_repository_impl.dart';
import '../../features/translate/domain/repos/translation_repository.dart';
import '../../features/translate/domain/usecases/check_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/download_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/translate_text_usecase.dart';
import '../../features/translate/presentation/cubit/translate_cubit.dart';
import '../network/connectivity_service.dart';

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

  // ── Data sources ──
  sl.registerLazySingleton<TranslationLocalDataSource>(
    () => MlKitTranslationLocalDataSource(sl()),
  );

  // ── Repositories ──
  sl.registerLazySingleton<TranslationRepository>(
    () => TranslationRepositoryImpl(local: sl(), connectivity: sl()),
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
