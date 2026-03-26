part of '../internal.dart';

/// Internal MethodChannel bridge that applies Meta (Facebook) consent natively on iOS.
///
/// Under iOS 14+, Meta's Audience Network requires the App Tracking Transparency (ATT)
/// status to be explicitly forwarded to the SDK via `FBAdSettings.setAdvertiserTrackingEnabled()`.
///
/// This channel invokes that native method automatically based on the ATT result
/// obtained in `GmaAllMediations.initialize()`. It uses reflection on the iOS
/// side so the package remains free of compile-time dependencies on the Meta SDK.
class _MetaConsentChannel {
  _MetaConsentChannel._(); // Prevent instantiation

  static const MethodChannel _channel = MethodChannel('gma_all_mediations/meta_consent');

  /// Forwards the iOS ATT authorization status to the Meta SDK.
  ///
  /// - [trackingEnabled]: `true` if the user authorized tracking via the ATT
  ///   prompt; `false` otherwise (or if restricted/denied).
  ///
  /// This method is a no-op on non-iOS platforms.
  static Future<void> setAdvertiserTrackingEnabled(bool trackingEnabled) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod<void>('setAdvertiserTrackingEnabled', {
        'trackingEnabled': trackingEnabled,
      });
      _GmaLogger.success(
        'Meta Audience Network — native advertiser tracking set to $trackingEnabled.',
      );
    } on MissingPluginException {
      _GmaLogger.warn(
        'MetaConsentChannel: MissingPluginException — channel not '
        'registered (likely running in test environment).',
      );
    } catch (e, st) {
      _GmaLogger.error('MetaConsentChannel: native call failed', e, st);
    }
  }
}
