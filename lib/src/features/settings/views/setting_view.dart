import 'package:f_launcher/src/common/state_management/state_management.dart';
import 'package:f_launcher/src/features/launcher/view_models/launcher_view_model.dart';
import 'package:f_launcher/src/features/launcher/widgets/filter_app_type_widget.dart';
import 'package:f_launcher/src/features/settings/models/setting_model.dart';
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
            FilterAppTypeWidget(launcherViewModel: launcherViewModel),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Dark theme'),
              trailing: StateBuilderWidget<SettingViewModel, SettingModel>(
                viewModel: settingViewModel,
                builder: (context, settingModel) {
                  return Switch(
                    value: settingModel.isDarkTheme,
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
