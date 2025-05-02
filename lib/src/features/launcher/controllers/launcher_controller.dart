import 'package:f_launcher/src/common/constants/constants.dart';
import 'package:f_launcher/src/common/enums/launcher_filter_enum.dart';
import 'package:f_launcher/src/common/exception_handlings/exception_handling.dart';
import 'package:f_launcher/src/common/states/state.dart';
import 'package:f_launcher/src/features/launcher/models/launcher_model.dart';
import 'package:f_launcher/src/features/launcher/repositories/launcher_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef _Controller = ChangeNotifier;

abstract interface class LauncherController extends _Controller {
  AppState<List<LauncherModel>> get appsState;
  LauncherFilterEnum get currentFilter;

  Future<void> updateFilter(LauncherFilterEnum filter);
  Future<void> getApps();
  Future<void> openApp(String packageName);
}

class LauncherControllerImpl extends _Controller implements LauncherController {
  static const MethodChannel _channel = MethodChannel(Constants.pathChannel);
  final LauncherRepository launcherRepository;

  LauncherControllerImpl({required this.launcherRepository});

  AppState<List<LauncherModel>> _appsState =
      InitialState<List<LauncherModel>>();

  @override
  AppState<List<LauncherModel>> get appsState => _appsState;

  LauncherFilterEnum _currentFilter = LauncherFilterEnum.all;

  @override
  LauncherFilterEnum get currentFilter => _currentFilter;

  @override
  Future<void> updateFilter(LauncherFilterEnum filter) async {
    _currentFilter = filter;
    await getApps();
  }

  @override
  Future<void> getApps() async {
    _emit(LoadingState());
    final method =
        {
          LauncherFilterEnum.all: 'getAllApps',
          LauncherFilterEnum.system: 'getSystemApps',
          LauncherFilterEnum.user: 'getUserApps',
          LauncherFilterEnum.playStore: 'getAppsFromPlayStore',
          LauncherFilterEnum.recentlyUsed: 'getRecentlyUsedApps',
        }[_currentFilter];
    final result = await launcherRepository.findApps(method ?? '');
    final AppState<List<LauncherModel>> apps = switch (result) {
      Success(value: final apps) => SuccessState(data: apps),
      Error(error: final exception) => ErrorState(
        message: 'Something went wrong: $exception',
      ),
    };
    _emit(apps);
  }

  @override
  Future<void> openApp(String packageName) async {
    try {
      await _channel.invokeMethod('openApp', {'packageName': packageName});
    } catch (error) {
      debugPrint('Something went wrong: $error');
    }
  }

  void _emit(AppState<List<LauncherModel>> newValue) {
    if (_appsState != newValue) {
      _appsState = newValue;
      notifyListeners();
      debugPrint('Launcher state: $_appsState');
    }
  }
}
