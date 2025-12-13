import 'package:f_launcher/src/common/states/state.dart';
import 'package:f_launcher/src/common/widgets/skeleton_refresh_widget.dart';
import 'package:f_launcher/src/features/launcher/view_models/launcher_view_model.dart';
import 'package:f_launcher/src/features/settings/routes/setting_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LauncherView extends StatefulWidget {
  final LauncherViewModel launcherViewModel;

  const LauncherView({super.key, required this.launcherViewModel});

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getApps();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getApps() async {
    await widget.launcherViewModel.getApps();
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
            await _getApps();
          },
          child: ListenableBuilder(
            listenable: widget.launcherViewModel,
            builder: (context, child) {
              return switch (widget.launcherViewModel.appsState) {
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
                            widget.launcherViewModel.openApp(app.packageName);
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
