import 'package:f_launcher/src/common/dependency_injectors/dependency_injector.dart';
import 'package:f_launcher/src/features/launcher/view_models/launcher_view_model.dart';
import 'package:f_launcher/src/features/settings/view_models/setting_view_model.dart';
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
          launcherViewModel: locator<LauncherViewModel>(),
          settingViewModel: locator<SettingViewModel>(),
        );
      },
    ),
  ];
}
