import 'package:f_launcher/src/common/dependency_injectors/dependency_injector.dart';
import 'package:f_launcher/src/features/launcher/controllers/launcher_controller.dart';
import 'package:f_launcher/src/features/settings/controllers/setting_controller.dart';
import 'package:f_launcher/src/features/settings/views/setting_view.dart';
import 'package:go_router/go_router.dart';

class SettingRoutes {
  static String get setting => '/setting';

  List<GoRoute> get routes => _routes;

  final List<GoRoute> _routes = [
    GoRoute(
      path: setting,
      builder: (context, state) {
        return SettingView(
          launcherController: locator<LauncherController>(),
          settingController: locator<SettingController>(),
        );
      },
    ),
  ];
}
