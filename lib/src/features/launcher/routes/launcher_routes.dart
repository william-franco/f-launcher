import 'package:f_launcher/src/features/launcher/views/launcher_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LauncherRoutes {
  static const String apps = '/apps';

  static final List<GoRoute> routes = [
    GoRoute(
      path: apps,
      pageBuilder: (context, state) => const MaterialPage(
        child: LauncherView(),
      ),
    ),
  ];
}
