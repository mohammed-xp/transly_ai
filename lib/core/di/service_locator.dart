import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hive_ce/hive.dart';
import 'package:upgrader/upgrader.dart';

import '../../features/app_language/data/datasources/app_language_local_data_source.dart';
import '../../features/app_language/data/datasources/app_language_local_data_source_impl.dart';
import '../../features/app_language/data/repos/app_language_repo_impl.dart';
import '../../features/app_language/domain/repos/app_language_repo.dart';
import '../../features/app_language/domain/usecases/get_app_language_usecase.dart';
import '../../features/app_language/domain/usecases/set_app_language_usecase.dart';
import '../../features/app_language/presentation/cubit/app_language_cubit.dart';
import '../../features/app_update/data/datasources/app_update_data_source.dart';
import '../../features/app_update/data/datasources/preview_app_update_data_source.dart';
import '../../features/app_update/data/datasources/upgrader_app_update_data_source.dart';
import '../../features/app_update/data/repos/app_update_repo_impl.dart';
import '../../features/app_update/domain/repos/app_update_repo.dart';
import '../../features/app_update/domain/usecases/check_for_app_update_usecase.dart';
import '../../features/app_update/domain/usecases/mark_app_update_prompted_usecase.dart';
import '../../features/app_update/domain/usecases/open_app_store_usecase.dart';
import '../../features/app_update/presentation/cubit/app_update_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repos/auth_repo_impl.dart';
import '../../features/auth/domain/repos/auth_repo.dart';
import '../../features/auth/domain/usecases/evaluate_password_strength_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '../../features/auth/domain/usecases/validate_sign_in_form_usecase.dart';
import '../../features/auth/domain/usecases/validate_sign_up_form_usecase.dart';
import '../../features/auth/domain/usecases/watch_session_status_usecase.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/auth/presentation/cubit/sign_in_cubit.dart';
import '../../features/auth/presentation/cubit/sign_up_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/profile/data/datasources/account_remote_data_source.dart';
import '../../features/profile/data/datasources/account_remote_data_source_impl.dart';
import '../../features/profile/data/datasources/plan_usage_remote_data_source.dart';
import '../../features/profile/data/datasources/plan_usage_remote_data_source_impl.dart';
import '../../features/profile/data/repos/account_repo_impl.dart';
import '../../features/profile/data/repos/plan_usage_repo_impl.dart';
import '../../features/profile/domain/repos/account_repo.dart';
import '../../features/profile/domain/repos/plan_usage_repo.dart';
import '../../features/profile/domain/usecases/delete_account_use_case.dart';
import '../../features/profile/domain/usecases/get_plan_usage_usecase.dart';
import '../../features/profile/presentation/cubit/delete_account_cubit.dart';
import '../../features/profile/presentation/cubit/plan_usage_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/translate/data/datasources/api_translation_remote_data_source.dart';
import '../../features/translate/data/datasources/translation_local_data_source.dart';
import '../../features/translate/data/datasources/translation_remote_data_source.dart';
import '../../features/translate/data/repos/translation_repo_impl.dart';
import '../../features/translate/domain/repos/translation_repo.dart';
import '../../features/translate/domain/usecases/check_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/download_translation_models_usecase.dart';
import '../../features/translate/domain/usecases/speak_text_usecase.dart';
import '../../features/translate/domain/usecases/translate_text_usecase.dart';
import '../../features/translate/domain/usecases/watch_online_availability_usecase.dart';
import '../../features/translate/presentation/cubit/translate_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../data/datasources/user_local_data_source.dart';
import '../data/datasources/user_local_data_source_impl.dart';
import '../data/models/user_model.dart';
import '../data/repos/logout_repo_impl.dart';
import '../data/repos/user_repo_impl.dart';
import '../domain/repos/logout_repo.dart';
import '../domain/repos/user_repo.dart';
import '../domain/usecases/get_cached_user_use_case.dart';
import '../init/hive_initializer.dart';
import '../network/api_consumer.dart';
import '../network/dio_base_api.dart';
import '../security/token_storage.dart';
import '../services/connectivity_service.dart';
import '../services/flutter_tts_service.dart';
import '../services/tts_service.dart';
import '../session/session_manager.dart';

final GetIt serviceLocator = GetIt.instance;

/// `optional` or `required` shows the update UI with sample data in debug
/// builds: `flutter run --dart-define=APP_UPDATE_PREVIEW=optional`.
const String _appUpdatePreview = String.fromEnvironment('APP_UPDATE_PREVIEW');

/// Requires [HiveInitializer.initHive] to have completed.
Future<void> configureDependencies() async {
  // ── Infrastructure (networking, storage, services) ──
  serviceLocator.registerLazySingleton(Connectivity.new);
  serviceLocator.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(OnDeviceTranslatorModelManager.new);
  serviceLocator.registerLazySingleton(FlutterTts.new);
  serviceLocator.registerLazySingleton<TtsService>(
    () => FlutterTtsService(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );
  serviceLocator.registerLazySingleton(() => TokenStorage(serviceLocator()));
  serviceLocator.registerSingleton<Box<UserModel>>(
    Hive.box<UserModel>(HiveInitializer.userBox),
  );
  serviceLocator.registerSingleton<Box<String>>(
    Hive.box<String>(HiveInitializer.settingsBox),
  );
  // The update check runs once per launch; nothing listens for the
  // re-checks upgrader would otherwise make on every resume.
  serviceLocator.registerLazySingleton(() => Upgrader(checkOnResume: false));

  // ── Session ──
  serviceLocator.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton<LogoutRepo>(
    () => LogoutRepoImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => SessionManager(serviceLocator()));

  // ── Networking ──
  serviceLocator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 10),
      ),
    ),
  );
  serviceLocator.registerLazySingleton<ApiConsumer>(
    () => DioBaseApi(serviceLocator(), serviceLocator(), serviceLocator()),
  );

  // ── Data sources ──
  serviceLocator.registerLazySingleton<TranslationLocalDataSource>(
    () => MlKitTranslationLocalDataSource(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<TranslationRemoteDataSource>(
    () => ApiTranslationRemoteDataSource(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<PlanUsageRemoteDataSource>(
    () => PlanUsageRemoteDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AppUpdateDataSource>(
    () => kDebugMode && _appUpdatePreview.isNotEmpty
        ? PreviewAppUpdateDataSource(
            isRequired: _appUpdatePreview == 'required',
          )
        : UpgraderAppUpdateDataSource(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AppLanguageLocalDataSource>(
    () => AppLanguageLocalDataSourceImpl(serviceLocator()),
  );

  // ── Repositories ──
  serviceLocator.registerLazySingleton<TranslationRepo>(
    () => TranslationRepoImpl(
      local: serviceLocator(),
      connectivity: serviceLocator(),
      remote: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton<UserRepo>(
    () => UserRepoImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(remote: serviceLocator(), userLocal: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<PlanUsageRepo>(
    () => PlanUsageRepoImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AccountRepo>(
    () => AccountRepoImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AppUpdateRepo>(
    () => AppUpdateRepoImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AppLanguageRepo>(
    () => AppLanguageRepoImpl(
      serviceLocator(),
      supportedCodes: {
        for (final locale in AppLocalizations.supportedLocales)
          locale.languageCode,
      },
    ),
  );

  // ── Use cases ──
  serviceLocator.registerLazySingleton(
    () => TranslateTextUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => CheckTranslationModelsUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => DownloadTranslationModelsUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SpeakTextUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => WatchOnlineAvailabilityUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SignInWithEmailUseCase(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton(ValidateSignInFormUseCase.new);
  serviceLocator.registerLazySingleton(
    () => SignUpWithEmailUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(ValidateSignUpFormUseCase.new);
  serviceLocator.registerLazySingleton(EvaluatePasswordStrengthUseCase.new);
  serviceLocator.registerLazySingleton(
    () => WatchSessionStatusUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => SignOutUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => GetCachedUserUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetPlanUsageUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => DeleteAccountUseCase(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => CheckForAppUpdateUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => MarkAppUpdatePromptedUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => OpenAppStoreUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetAppLanguageUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SetAppLanguageUseCase(serviceLocator()),
  );

  // ── Cubits (registerFactory — fresh instance per screen) ──
  serviceLocator.registerFactory(
    () => SplashCubit(getCachedUserUseCase: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => SessionCubit(
      watchSessionStatus: serviceLocator(),
      signOut: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => SignInCubit(signIn: serviceLocator(), validate: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => SignUpCubit(
      signUp: serviceLocator(),
      validate: serviceLocator(),
      evaluatePasswordStrength: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => HomeCubit(getCachedUser: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => ProfileCubit(getCachedUser: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => PlanUsageCubit(getPlanUsage: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => DeleteAccountCubit(deleteAccount: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => AppUpdateCubit(
      checkForUpdate: serviceLocator(),
      markPrompted: serviceLocator(),
      openStore: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => AppLanguageCubit(
      getLanguage: serviceLocator(),
      setLanguage: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => TranslateCubit(
      translateText: serviceLocator(),
      checkModels: serviceLocator(),
      downloadModels: serviceLocator(),
      speakText: serviceLocator(),
      watchOnlineAvailability: serviceLocator(),
    ),
  );
}
