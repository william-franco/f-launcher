import 'package:f_launcher/src/common/services/storage_service.dart';
import 'package:f_launcher/src/features/launcher/controllers/launcher_controller.dart';
import 'package:f_launcher/src/features/launcher/repositories/launcher_repository.dart';
import 'package:f_launcher/src/features/settings/controllers/setting_controller.dart';
import 'package:f_launcher/src/features/settings/repositories/setting_repository.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void dependencyInjector() {
  _startFeatureLauncher();
  _startFeatureSetting();
}

void _startFeatureLauncher() {
  locator.registerCachedFactory<LauncherRepository>(
    () => LauncherRepositoryImpl(),
  );
  locator.registerCachedFactory<LauncherController>(
    () => LauncherControllerImpl(
      launcherRepository: locator<LauncherRepository>(),
    ),
  );
}

void _startFeatureSetting() {
  locator.registerCachedFactory<StorageService>(
    () => StorageServiceImpl(),
  );
  locator.registerCachedFactory<SettingRepository>(
    () => SettingRepositoryImpl(
      storageService: locator<StorageService>(),
    ),
  );
  locator.registerCachedFactory<SettingController>(
    () => SettingControllerImpl(
      settingRepository: locator<SettingRepository>(),
    ),
  );
}

void resetDependencies() {
  locator.reset();
}

void resetFeatureUser() {
  locator.unregister<LauncherRepository>();
  locator.unregister<LauncherController>();
  _startFeatureLauncher();
}
