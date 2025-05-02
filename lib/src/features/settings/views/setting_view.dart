import 'package:f_launcher/src/common/dependency_injectors/dependency_injector.dart';
import 'package:f_launcher/src/common/enums/launcher_filter_enum.dart';
import 'package:f_launcher/src/features/launcher/controllers/launcher_controller.dart';
import 'package:f_launcher/src/features/settings/controllers/setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  late final SettingController settingController;
  late final LauncherController launcherController;

  @override
  void initState() {
    super.initState();
    settingController = locator<SettingController>();
    launcherController = locator<LauncherController>();
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationIcon: const FlutterLogo(),
      applicationName: 'F Launcher',
      applicationVersion: 'Version 1.0.0',
      applicationLegalese: '\u{a9} 2025 William Franco',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Select application type'),
              trailing: DropdownButton<LauncherFilterEnum>(
                value: launcherController.currentFilter,
                items:
                    LauncherFilterEnum.values.map((filter) {
                      return DropdownMenuItem<LauncherFilterEnum>(
                        value: filter,
                        child: Text(filter.name),
                      );
                    }).toList(),
                onChanged: (filter) {
                  if (filter != null) {
                    launcherController.updateFilter(filter);
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Dark theme'),
              trailing: ListenableBuilder(
                listenable: settingController,
                builder: (context, child) {
                  return Switch(
                    value: settingController.settingModel.isDarkTheme,
                    onChanged: (bool isDarkTheme) {
                      settingController.changeTheme(isDarkTheme: isDarkTheme);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }
}
