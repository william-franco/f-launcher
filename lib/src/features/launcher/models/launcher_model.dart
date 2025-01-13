import 'package:flutter/services.dart';

class LauncherModel {
  final String name;
  final String packageName;
  final Uint8List icon;

  LauncherModel({
    required this.name,
    required this.packageName,
    required this.icon,
  });

  factory LauncherModel.fromMap(Map<String, dynamic> map) {
    return LauncherModel(
      name: map['name'] ?? 'Unknown',
      packageName: map['packageName'] ?? '',
      icon: map['icon'] != null
          ? Uint8List.fromList(List<int>.from(map['icon']))
          : Uint8List(0),
    );
  }
}
