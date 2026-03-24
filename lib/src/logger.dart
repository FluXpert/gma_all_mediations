import 'dart:developer';

class GmaLogger {
  static bool _enabled = true;

  static void init(bool enable) {
    _enabled = enable;
  }

  static void logMessage(String message) {
    if (_enabled) {
      log('[GMA_ALL_MEDIATIONS] $message');
    }
  }
}
