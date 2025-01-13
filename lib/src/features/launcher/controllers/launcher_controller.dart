import 'package:f_launcher/src/common/constants/constants.dart';
import 'package:f_launcher/src/common/enums/launcher_filter_enum.dart';
import 'package:f_launcher/src/common/exception_handlings/exception_handling.dart';
import 'package:f_launcher/src/features/launcher/repositories/launcher_repository.dart';
import 'package:f_launcher/src/features/launcher/states/launcher_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef _Controller = ValueNotifier<LauncherState>;

abstract interface class LauncherController extends _Controller {
  LauncherController() : super(LauncherInitialState());

  LauncherFilterEnum get currentFilter;

  Future<void> updateFilter(LauncherFilterEnum filter);
  Future<void> getApps();
  Future<void> openApp(String packageName);
}

class LauncherControllerImpl extends _Controller implements LauncherController {
  static const MethodChannel _channel = MethodChannel(Constants.pathChannel);
  final LauncherRepository launcherRepository;

  LauncherControllerImpl({
    required this.launcherRepository,
  }) : super(LauncherInitialState());

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
    value = LauncherLoadingState();
    final method = {
      LauncherFilterEnum.all: 'getAllApps',
      LauncherFilterEnum.system: 'getSystemApps',
      LauncherFilterEnum.user: 'getUserApps',
      LauncherFilterEnum.playStore: 'getAppsFromPlayStore',
      LauncherFilterEnum.recentlyUsed: 'getRecentlyUsedApps',
    }[_currentFilter];
    final result = await launcherRepository.findApps(method ?? '');
    final apps = switch (result) {
      Success(value: final apps) => LauncherSuccessState(apps: apps),
      Error(error: final exception) =>
        LauncherErrorState(message: 'Something went wrong: $exception'),
    };
    value = apps;
    _debug();
  }

  @override
  Future<void> openApp(String packageName) async {
    try {
      await _channel.invokeMethod('openApp', {'packageName': packageName});
    } catch (error) {
      debugPrint('Something went wrong: $error');
    }
  }

  void _debug() {
    debugPrint('Launcher state: $value');
  }
}
