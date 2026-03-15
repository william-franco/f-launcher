import 'package:f_launcher/src/common/state_management/state_management.dart';
import 'package:f_launcher/src/features/settings/models/setting_model.dart';
import 'package:f_launcher/src/features/settings/repositories/setting_repository.dart';
import 'package:flutter/foundation.dart';

typedef _ViewModel = StateManagement<SettingModel>;

typedef SettingStateBuilder =
    StateBuilderWidget<SettingViewModel, SettingModel>;

abstract interface class SettingViewModel extends _ViewModel {
  SettingViewModel(super.initialValue);

  Future<void> getTheme();
  Future<void> changeTheme({required bool isDarkTheme});
}

class SettingViewModelImpl extends _ViewModel implements SettingViewModel {
  final SettingRepository settingRepository;

  SettingViewModelImpl({required this.settingRepository})
    : super(SettingModel());

  @override
  Future<void> getTheme() async {
    final model = await settingRepository.readTheme();
    _emit(model);
  }

  @override
  Future<void> changeTheme({required bool isDarkTheme}) async {
    final model = state.copyWith(isDarkTheme: isDarkTheme);
    await settingRepository.updateTheme(isDarkTheme: isDarkTheme);
    _emit(model);
  }

  void _emit(SettingModel newState) {
    emitState(newState);
    debugPrint('SettingController: ${state.isDarkTheme}');
  }
}
