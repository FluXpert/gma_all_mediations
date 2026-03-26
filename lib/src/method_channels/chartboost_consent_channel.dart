part of '../internal.dart';

/// Internal MethodChannel bridge that applies Chartboost consent natively.
///
/// The `gma_mediation_chartboost` Flutter package deliberately exposes no
/// Dart-level consent API — the Chartboost SDK's `addDataUseConsent` method
/// must be called from native code. This class fires that call automatically
/// via a [MethodChannel] so consumers of `gma_all_mediations` never need to
/// touch `AppDelegate.swift` or `MainActivity.kt`.
///
/// The channel name **`gma_all_mediations/chartboost_consent`** is handled by:
/// * **iOS** – `GmaAllMediationsPlugin.swift` → calls
///   `Chartboost.addDataUseConsent(CBGDPRDataUseConsent)` and
///   `Chartboost.addDataUseConsent(CBCCPADataUseConsent)`.
/// * **Android** – `GmaAllMediationsPlugin.kt` → no-op; the Chartboost
///   Android adapter reads consent automatically via the mediation framework.
class _ChartboostConsentChannel {
  _ChartboostConsentChannel._(); // Prevent instantiation

  static const MethodChannel _channel = MethodChannel(
    'gma_all_mediations/chartboost_consent',
  );

  /// Sends GDPR and CCPA consent signals to the Chartboost SDK natively.
  ///
  /// - [hasConsent]: `true` → behavioural (personalised) ads are allowed;
  ///   `false` → non-behavioural (contextual) ads only (GDPR compliance).
  /// - [doNotSell]: `true` → opt-out from sale of personal information
  ///   (CCPA "Do Not Sell"); `false` → sale is permitted.
  ///
  /// This method is a no-op on platforms other than iOS and Android, and
  /// gracefully handles [MissingPluginException] so that unit-test
  /// environments (which have no platform channel) are never broken.
  static Future<void> applyConsent({
    required bool hasConsent,
    required bool doNotSell,
  }) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;

    try {
      await _channel.invokeMethod<void>('applyConsent', {
        'hasConsent': hasConsent,
        'doNotSell': doNotSell,
      });
    } on MissingPluginException {
      // Occurs in unit-test environments — safe to ignore.
      _GmaLogger.warn(
        'ChartboostConsentChannel: MissingPluginException — channel not '
        'registered (likely running in test environment).',
      );
    } catch (e, st) {
      _GmaLogger.error('ChartboostConsentChannel: native call failed', e, st);
    }
  }
}
