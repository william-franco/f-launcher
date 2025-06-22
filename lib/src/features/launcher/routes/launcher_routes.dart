import 'package:f_launcher/src/common/dependency_injectors/dependency_injector.dart';
import 'package:f_launcher/src/features/launcher/controllers/launcher_controller.dart';
import 'package:f_launcher/src/features/launcher/views/launcher_view.dart';
import 'package:go_router/go_router.dart';

class LauncherRoutes {
  static String get apps => '/apps';

  List<GoRoute> get routes => _routes;

  final List<GoRoute> _routes = [
    GoRoute(
      path: apps,
      builder: (context, state) {
        return LauncherView(launcherController: locator<LauncherController>());
      },
    ),
  ];
}
