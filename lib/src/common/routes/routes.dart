import 'package:f_launcher/src/features/launcher/routes/launcher_routes.dart';
import 'package:f_launcher/src/features/settings/routes/setting_routes.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static String get home => LauncherRoutes.apps;

  GoRouter get routes => _routes;

  final GoRouter _routes = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: home,
    routes: [...LauncherRoutes().routes, ...SettingRoutes().routes],
  );
}
