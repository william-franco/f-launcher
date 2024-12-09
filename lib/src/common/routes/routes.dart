import 'package:f_launcher/src/features/launcher/routes/launcher_routes.dart';
import 'package:f_launcher/src/features/settings/routes/setting_routes.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static final GoRouter routes = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: LauncherRoutes.apps,
    routes: [
      ...LauncherRoutes.routes,
      ...SettingRoutes.routes,
    ],
  );
}
