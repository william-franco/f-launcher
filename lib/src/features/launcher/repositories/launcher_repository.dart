import 'package:f_launcher/src/common/constants/constants.dart';
import 'package:f_launcher/src/common/exception_handlings/exception_handling.dart';
import 'package:f_launcher/src/features/launcher/models/launcher_model.dart';
import 'package:flutter/services.dart';

abstract interface class LauncherRepository {
  Future<Result<List<LauncherModel>, Exception>> findApps(String methodName);
  Future<void> openApp(String packageName);
}

class LauncherRepositoryImpl implements LauncherRepository {
  static const MethodChannel _channel = MethodChannel(Constants.pathChannel);

  @override
  Future<Result<List<LauncherModel>, Exception>> findApps(
    String methodName,
  ) async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod(methodName);
      final success = apps
          .map((app) =>
              LauncherModel.fromMap((app as Map).cast<String, dynamic>()))
          .toList();
      return Success(value: success);
    } on Exception catch (error) {
      return Error(error: error);
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
