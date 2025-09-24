import 'package:f_launcher/src/common/constants/value_constant.dart';
import 'package:f_launcher/src/common/results/result.dart';
import 'package:f_launcher/src/features/launcher/models/launcher_model.dart';
import 'package:flutter/services.dart';

typedef LauncherResult = Result<List<LauncherModel>, Exception>;

abstract interface class LauncherRepository {
  Future<LauncherResult> findApps(String methodName);
  Future<void> openApp(String packageName);
}

class LauncherRepositoryImpl implements LauncherRepository {
  static final _channel = MethodChannel(ValueConstant.pathChannel);

  @override
  Future<LauncherResult> findApps(String methodName) async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod(methodName);
      final success = apps
          .map(
            (app) =>
                LauncherModel.fromMap((app as Map).cast<String, dynamic>()),
          )
          .toList();
      return SuccessResult(value: success);
    } on Exception catch (error) {
      return ErrorResult(error: error);
    }
  }

  @override
  Future<void> openApp(String packageName) async {
    try {
      await _channel.invokeMethod('openApp', {'packageName': packageName});
    } catch (error) {
      throw Exception('Something went wrong: $error');
    }
  }
}
