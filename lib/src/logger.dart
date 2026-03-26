part of 'internal.dart';

/// Internal logger for the **GMA All Mediations** package.
///
/// Use [_GmaLogger.info], [_GmaLogger.success], and [_GmaLogger.error] to provide
/// developer feedback during the mediation and consent flow.
///
/// Logs are only printed when [GmaMediationConfig.debug] is `true`.
class _GmaLogger {
  _GmaLogger._(); // Prevent instantiation

  static bool _enabled = true;

  /// Initialises the logger.
  static void init({required bool enable}) {
    _enabled = enable;
  }

  /// Prints a standard informational message.
  static void info(String message) {
    if (_enabled) debugPrint('[GMA] ℹ️  $message');
  }

  /// Prints a success message (green circle).
  static void success(String message) {
    if (_enabled) debugPrint('[GMA] ✅  $message');
  }

  /// Prints a warning message (yellow triangle).
  static void warn(String message) {
    if (_enabled) debugPrint('[GMA] ⚠️  $message');
  }

  /// Prints an error message with optional exception and stacktrace details.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled) return;

    debugPrint('[GMA] ❌  $message');
    if (error != null) debugPrint('[GMA]     Error: $error');
    if (stackTrace != null) debugPrint('[GMA]     $stackTrace');
  }
}
