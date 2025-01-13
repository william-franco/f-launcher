import 'package:f_launcher/src/features/launcher/models/launcher_model.dart';

sealed class LauncherState {}

final class LauncherInitialState extends LauncherState {}

final class LauncherLoadingState extends LauncherState {}

final class LauncherSuccessState extends LauncherState {
  final List<LauncherModel> apps;

  LauncherSuccessState({
    required this.apps,
  });
}

final class LauncherErrorState extends LauncherState {
  final String message;

  LauncherErrorState({
    required this.message,
  });
}
