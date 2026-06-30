import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../services/connectivity_service.dart';
import '../../features/camera_scan/presentation/cubit/camera_scan_cubit.dart';
import '../../features/conversation/presentation/cubit/conversation_cubit.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/translation/data/datasources/ai_translation_stub_datasource.dart';
import '../../features/translation/data/datasources/mlkit_translation_datasource.dart';
import '../../features/translation/data/repositories/translation_repository_impl.dart';
import '../../features/translation/domain/repositories/translation_repository.dart';
import '../../features/translation/domain/usecases/get_supported_languages_usecase.dart';
import '../../features/translation/domain/usecases/translate_text_usecase.dart';
import '../../features/translation/presentation/cubit/translation_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Infrastructure
  sl.registerLazySingleton(createDioClient);
  sl.registerLazySingleton(Connectivity.new);
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(sl()),
  );

  // History — datasource + repo
  sl.registerLazySingleton<HistoryLocalDatasource>(
    () => SqfliteHistoryDatasource.instance,
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl()),
  );

  // Translation — datasources + repo + usecases
  sl.registerLazySingleton(AiTranslationStubDatasource.new);
  sl.registerLazySingleton(MlKitTranslationDatasource.new);
  sl.registerLazySingleton<TranslationRepository>(
    () => TranslationRepositoryImpl(
      mlKit: sl(),
      aiStub: sl(),
      connectivity: sl(),
    ),
  );
  sl.registerLazySingleton(() => TranslateTextUseCase(sl()));
  sl.registerLazySingleton(() => GetSupportedLanguagesUseCase(sl()));

  // Cubits — registered as factories so each route gets a fresh instance
  sl.registerFactory(() => OnboardingCubit());
  sl.registerFactory(() => TranslationCubit(sl()));
  sl.registerFactory(() => ConversationCubit());
  sl.registerFactory(() => CameraScanCubit());
  sl.registerFactory(() => HistoryCubit(sl()));
  sl.registerFactory(() => SettingsCubit());
}
