import 'package:f_launcher/src/features/launcher/views/launcher_view.dart';
import 'package:go_router/go_router.dart';

class LauncherRoutes {
  static String get apps => '/apps';

  final routes = [
    GoRoute(
      path: apps,
      builder: (context, state) {
        return const LauncherView();
      },
    ),
  ];
}
