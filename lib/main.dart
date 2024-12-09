import 'package:f_launcher/src/common/dependency_injectors/dependency_injector.dart';
import 'package:f_launcher/src/common/routes/routes.dart';
import 'package:flutter/material.dart';

void main() {
  dependencyInjector();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'F Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: Routes.routes,
    );
  }
}
