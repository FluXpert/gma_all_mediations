import 'dart:developer' as developer;

/// Internal logger for the `gma_all_mediations` package.
///
/// Provides structured, tagged logging with optional log levels.
/// All messages are prefixed with `[GMA]` for easy filtering in DevTools.
///
/// Enable or disable logging via [GmaLogger.init]. In production builds,
/// always pass `debug: false` to [GmaMediationConfig] so no logs appear
/// in the console and binary size stays lean.
class GmaLogger {
  GmaLogger._(); // Prevent instantiation

  static bool _enabled = false;

  /// Initialises the logger for the package.
  ///
  /// Call this once, typically inside [GmaAllMediations.initialize].
  ///
  /// [enable] – set to `true` during development/debugging,
  /// `false` for release builds to silence all output.
  static void init({required bool enable}) {
    _enabled = enable;
  }

  /// Logs an informational [message].
  ///
  /// Only emits output when the logger is enabled.
  static void info(String message) {
    if (_enabled) developer.log('ℹ️  $message', name: 'GMA');
  }

  /// Logs a success / milestone [message].
  static void success(String message) {
    if (_enabled) developer.log('✅  $message', name: 'GMA');
  }

  /// Logs a warning [message].
  ///
  /// Warnings are non-fatal but worth investigating.
  static void warn(String message) {
    if (_enabled) developer.log('⚠️  $message', name: 'GMA');
  }

  /// Logs an error [message] with an optional [error] object and [stackTrace].
  ///
  /// Always emits, regardless of [_enabled], so errors are never swallowed.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      '❌  $message',
      name: 'GMA',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
