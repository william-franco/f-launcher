import 'package:f_launcher/src/common/enums/launcher_filter_enum.dart';
import 'package:f_launcher/src/features/launcher/view_models/launcher_view_model.dart';
import 'package:f_launcher/src/features/settings/view_models/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingView extends StatelessWidget {
  final SettingViewModel settingViewModel;
  final LauncherViewModel launcherViewModel;

  const SettingView({
    super.key,
    required this.settingViewModel,
    required this.launcherViewModel,
  });

  void _showAboutDialog(BuildContext context) {
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
                value: launcherViewModel.currentFilter,
                items: LauncherFilterEnum.values.map((filter) {
                  return DropdownMenuItem<LauncherFilterEnum>(
                    value: filter,
                    child: Text(filter.name),
                  );
                }).toList(),
                onChanged: (filter) {
                  if (filter != null) {
                    launcherViewModel.updateFilter(filter);
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Dark theme'),
              trailing: ListenableBuilder(
                listenable: settingViewModel,
                builder: (context, child) {
                  return Switch(
                    value: settingViewModel.settingModel.isDarkTheme,
                    onChanged: (bool isDarkTheme) {
                      settingViewModel.changeTheme(isDarkTheme: isDarkTheme);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
