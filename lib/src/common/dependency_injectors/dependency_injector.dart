import 'package:f_launcher/src/common/services/storage_service.dart';
import 'package:f_launcher/src/features/launcher/view_models/launcher_view_model.dart';
import 'package:f_launcher/src/features/launcher/repositories/launcher_repository.dart';
import 'package:f_launcher/src/features/settings/view_models/setting_view_model.dart';
import 'package:f_launcher/src/features/settings/repositories/setting_repository.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void dependencyInjector() {
  _startStorageService();
  _startFeatureLauncher();
  _startFeatureSetting();
}

void _startStorageService() {
  locator.registerLazySingleton<StorageService>(() => StorageServiceImpl());
}

void _startFeatureLauncher() {
  locator.registerCachedFactory<LauncherRepository>(
    () => LauncherRepositoryImpl(),
  );
  locator.registerLazySingleton<LauncherViewModel>(
    () => LauncherViewModelImpl(
      launcherRepository: locator<LauncherRepository>(),
    ),
  );
}

void _startFeatureSetting() {
  locator.registerCachedFactory<SettingRepository>(
    () => SettingRepositoryImpl(storageService: locator<StorageService>()),
  );
  locator.registerLazySingleton<SettingViewModel>(
    () => SettingViewModelImpl(settingRepository: locator<SettingRepository>()),
  );
}

Future<void> initDependencies() async {
  await locator<StorageService>().initStorage();
  await Future.wait([locator<SettingViewModel>().getTheme()]);
}

void resetDependencies() {
  locator.reset();
}

void resetFeatureSetting() {
  locator.unregister<SettingRepository>();
  locator.unregister<SettingViewModel>();
  _startFeatureSetting();
}
