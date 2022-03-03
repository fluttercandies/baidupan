mixin ILogger {
  bool isShowLog = false;

  void log(String message) {
    if (isShowLog) {
      print(message);
    }
  }

  void logError(String tag, Object error, [StackTrace? stackTrace]) {
    if (isShowLog) {
      print('$tag: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }
}
