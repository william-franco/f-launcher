import 'package:f_launcher/src/common/constants/value_constant.dart';
import 'package:f_launcher/src/common/enums/launcher_filter_enum.dart';
import 'package:f_launcher/src/common/patterns/app_state_pattern.dart';
import 'package:f_launcher/src/features/launcher/models/launcher_model.dart';
import 'package:f_launcher/src/features/launcher/repositories/launcher_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef _ViewModel = ChangeNotifier;

typedef LauncherState = AppState<List<LauncherModel>>;

abstract interface class LauncherViewModel extends _ViewModel {
  LauncherState get appsState;
  LauncherFilterEnum get currentFilter;

  Future<void> updateFilter(LauncherFilterEnum filter);
  Future<void> getApps();
  Future<void> openApp(String packageName);
}

class LauncherViewModelImpl extends _ViewModel implements LauncherViewModel {
  static final _channel = MethodChannel(ValueConstant.pathChannel);
  final LauncherRepository launcherRepository;

  LauncherViewModelImpl({required this.launcherRepository});

  LauncherState _appsState = InitialState();

  @override
  LauncherState get appsState => _appsState;

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
    final method = {
      LauncherFilterEnum.all: 'getAllApps',
      LauncherFilterEnum.system: 'getSystemApps',
      LauncherFilterEnum.user: 'getUserApps',
      LauncherFilterEnum.playStore: 'getAppsFromPlayStore',
      LauncherFilterEnum.recentlyUsed: 'getRecentlyUsedApps',
    }[_currentFilter];
    final result = await launcherRepository.findApps(method ?? '');
    final apps = result.fold<LauncherState>(
      onSuccess: (value) => SuccessState(data: value),
      onError: (error) => ErrorState(message: '$error'),
    );
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

  void _emit(LauncherState newState) {
    if (_appsState != newState) {
      _appsState = newState;
      notifyListeners();
      debugPrint('Launcher state: $_appsState');
    }
  }
}
