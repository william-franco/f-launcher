import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void dependencyInjector() {
  _startFeatureUser();
  _startFeatureSetting();
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
  locator.unregister<UserRepository>();
  locator.unregister<UserController>();
  _startFeatureUser();
}
