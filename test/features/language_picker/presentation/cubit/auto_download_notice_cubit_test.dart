import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_cached_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_offline_packs_settings_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/watch_offline_model_updates_usecase.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/auto_download_notice_cubit.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/auto_download_notice_state.dart';

import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';

void main() {
  late FakeOfflineModelsRepo models;

  setUp(() => models = FakeOfflineModelsRepo());

  AutoDownloadNoticeCubit buildCubit() {
    final cubit = AutoDownloadNoticeCubit(
      watchOfflineModelUpdates: WatchOfflineModelUpdatesUseCase(models),
      getCachedLanguages: GetCachedLanguagesUseCase(
        FakeLanguagesRepo(cached: testLanguages),
      ),
      getSettings: GetOfflinePacksSettingsUseCase(models),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> report(String code, OfflineModelStatus status) async {
    models.updates.add((code: code, status: status));
    await pumpEventQueue();
  }

  AutoDownloadNoticeShown shown(AutoDownloadNoticeCubit cubit) =>
      cubit.state as AutoDownloadNoticeShown;

  test('starts hidden', () {
    expect(buildCubit().state, isA<AutoDownloadNoticeHidden>());
  });

  test('shows a language being auto-downloaded', () async {
    final cubit = buildCubit();

    await report('fr', const OfflineModelDownloading(isAuto: true));

    expect(shown(cubit).language, testFrench);
  });

  test('says when the download only runs on Wi-Fi', () async {
    final cubit = buildCubit();

    await report('fr', const OfflineModelDownloading(isAuto: true));

    expect(shown(cubit).wifiOnly, isTrue);
  });

  test('ignores a download the user started', () async {
    final cubit = buildCubit();

    await report('fr', const OfflineModelDownloading());

    expect(cubit.state, isA<AutoDownloadNoticeHidden>());
  });

  test('hides once the download is over', () async {
    final cubit = buildCubit();
    await report('fr', const OfflineModelDownloading(isAuto: true));

    await report('fr', const OfflineModelDownloaded(isAuto: true));

    expect(cubit.state, isA<AutoDownloadNoticeHidden>());
  });

  test('hides once the download failed', () async {
    final cubit = buildCubit();
    await report('fr', const OfflineModelDownloading(isAuto: true));

    await report('fr', const OfflineModelNotDownloaded());

    expect(cubit.state, isA<AutoDownloadNoticeHidden>());
  });

  test('shows the newest of two downloads', () async {
    final cubit = buildCubit();

    await report('fr', const OfflineModelDownloading(isAuto: true));
    await report('de', const OfflineModelDownloading(isAuto: true));

    expect(shown(cubit).language, testGerman);
  });

  test('goes back to the other download when the newest ends', () async {
    final cubit = buildCubit();
    await report('fr', const OfflineModelDownloading(isAuto: true));
    await report('de', const OfflineModelDownloading(isAuto: true));

    await report('de', const OfflineModelDownloaded(isAuto: true));

    expect(shown(cubit).language, testFrench);
  });

  test('dismissing hides the notice', () async {
    final cubit = buildCubit();
    await report('fr', const OfflineModelDownloading(isAuto: true));

    cubit.dismiss();

    expect(cubit.state, isA<AutoDownloadNoticeHidden>());
  });

  test('a dismissed language shows again on its next download', () async {
    final cubit = buildCubit();
    await report('fr', const OfflineModelDownloading(isAuto: true));
    cubit.dismiss();
    await report('fr', const OfflineModelNotDownloaded());

    await report('fr', const OfflineModelDownloading(isAuto: true));

    expect(shown(cubit).language, testFrench);
  });

  test('skips a language missing from the cached list', () async {
    final cubit = buildCubit();

    await report('xx', const OfflineModelDownloading(isAuto: true));

    expect(cubit.state, isA<AutoDownloadNoticeHidden>());
  });

  test('stops listening once closed', () async {
    final cubit = buildCubit();
    await cubit.close();

    await report('fr', const OfflineModelDownloading(isAuto: true));

    expect(cubit.state, isA<AutoDownloadNoticeHidden>());
  });
}
