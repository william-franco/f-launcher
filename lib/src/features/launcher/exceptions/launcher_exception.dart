class LauncherException implements Exception {
  final String message;

  const LauncherException(this.message);

  @override
  String toString() => 'LauncherException: $message';
}
