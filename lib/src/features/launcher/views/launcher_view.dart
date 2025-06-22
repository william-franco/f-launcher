import 'package:f_launcher/src/common/states/state.dart';
import 'package:f_launcher/src/common/widgets/skeleton_refresh_widget.dart';
import 'package:f_launcher/src/features/launcher/controllers/launcher_controller.dart';
import 'package:f_launcher/src/features/settings/routes/setting_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LauncherView extends StatefulWidget {
  final LauncherController launcherController;

  const LauncherView({super.key, required this.launcherController});

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  late final LauncherController launcherController;

  @override
  void initState() {
    super.initState();
    launcherController = widget.launcherController;
    launcherController.getApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Apps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push(SettingRoutes.setting);
            },
          ),
        ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            await launcherController.getApps();
          },
          child: ListenableBuilder(
            listenable: launcherController,
            builder: (context, child) {
              return switch (launcherController.appsState) {
                InitialState() => const Text('List is empty.'),
                LoadingState() => ListView.builder(
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return const SkeletonRefreshWidget();
                  },
                ),
                SuccessState(data: final apps) => ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (BuildContext context, int index) {
                    final app = apps[index];
                    return InkWell(
                      child: Card(
                        child: ListTile(
                          leading: app.icon.isNotEmpty
                              ? Image.memory(app.icon, width: 40, height: 40)
                              : const Icon(Icons.apps),
                          title: Text(app.name),
                          subtitle: Text(app.packageName),
                          onTap: () {
                            launcherController.openApp(app.packageName);
                          },
                        ),
                      ),
                    );
                  },
                ),
                ErrorState(message: final message) => Text(message),
              };
            },
          ),
        ),
      ),
    );
  }
}
