/// ────────────────────────────────────────────────────────────────────────────
/// Responsible for applying GDPR / CCPA consent signals to every active
/// mediation adapter. Add new adapters here as you integrate them — the
/// pattern is always the same:
///
///   1. Uncomment the import for the adapter package.
///   2. Call the adapter's consent setters inside [applyConsentToAdapters],
///      using the `hasConsent` and `doNotSell` values already resolved for you.
///
/// Keeping consent propagation isolated here means a single function call from
/// [GmaAllMediations] can update every adapter without touching the main
/// initialisation flow.
///
/// ### Why this matters for revenue 💰
/// Mediation adapters that receive the correct consent signal are allowed to
/// participate in the ad auction. When adapters are blocked due to missing
/// consent, they drop out of the waterfall, dramatically reducing competition
/// and therefore eCPMs. Correct consent propagation is one of the highest-ROI
/// tasks in any AdMob mediation setup.
/// ────────────────────────────────────────────────────────────────────────────
library;

import 'package:gma_all_mediations/src/logger.dart';
import 'package:gma_mediation_applovin/gma_mediation_applovin.dart';
import 'package:gma_mediation_chartboost/gma_mediation_chartboost.dart';
import 'package:gma_mediation_dtexchange/gma_mediation_dtexchange.dart';
import 'package:gma_mediation_inmobi/gma_mediation_inmobi.dart';
import 'package:gma_mediation_ironsource/gma_mediation_ironsource.dart';
import 'package:gma_mediation_meta/gma_mediation_meta.dart';
// import 'package:gma_mediation_inmobi/gma_mediation_inmobi.dart';
// import 'package:gma_mediation_ironsource/gma_mediation_ironsource.dart';
// import 'package:gma_mediation_liftoffmonetize/gma_mediation_liftoffmonetize.dart';
// import 'package:gma_mediation_meta/gma_mediation_meta.dart';
// import 'package:gma_mediation_mintegral/gma_mediation_mintegral.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show ConsentInformation, ConsentStatus;

import 'chartboost_consent_channel.dart';

/// Manages consent propagation to all active mediation adapters.
///
/// This class is **internal** to the package. Consumers interact only with
/// [GmaAllMediations]; there is no need to use [MediationManager] directly.
///
/// ### Adding a new adapter
/// ```dart
/// // 1. Add the dependency to pubspec.yaml
/// // 2. Import the adapter package at the top of this file
/// // 3. Follow the pattern already used by AppLovin below
/// ```
class MediationManager {
  // ── Singleton ──────────────────────────────────────────────────────────────

  /// Shared singleton instance.
  static final MediationManager instance = MediationManager._();

  MediationManager._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Resolves the current UMP consent status and propagates GDPR / CCPA
  /// signals to every active mediation adapter.
  ///
  /// Parameters:
  /// - [forceMediationConsent] – treat the user as having consented even if
  ///   the UMP SDK has not yet obtained an explicit signal. Only use this when
  ///   you have a separate, legally-valid consent mechanism in place.
  /// - [doNotSell] – CCPA opt-out flag; when `true`, adapters that support
  ///   it will disable the sale of personal information.
  ///
  /// This method is idempotent and safe to call more than once if consent
  /// status changes at runtime (e.g. after the user updates their preferences).
  Future<void> applyConsentToAdapters({
    required bool forceMediationConsent,
    required bool doNotSell,
  }) async {
    final bool hasConsent = await _resolveConsentSignal(forceMediationConsent);

    GmaLogger.info(
      'Applying consent to adapters — hasConsent: $hasConsent, '
      'doNotSell: $doNotSell',
    );

    _applyAppLovinConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyUnityConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    await _applyChartboostConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyDTExchange(hasConsent: hasConsent, doNotSell: doNotSell);
    await _applyIronSourceConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    // _applyLiftoffConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyMetaConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyInMobiConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    // _applyMintegralConsent(hasConsent: hasConsent, doNotSell: doNotSell);

    GmaLogger.success('Consent applied to all active mediation adapters.');
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Resolves whether the user has given consent.
  ///
  /// Returns `true` when:
  /// * The UMP SDK reports [ConsentStatus.obtained] or
  ///   [ConsentStatus.notRequired], OR
  /// * [forceConsent] is `true` (developer override).
  Future<bool> _resolveConsentSignal(bool forceConsent) async {
    if (forceConsent) {
      GmaLogger.warn(
        'forceMediationConsent is true — skipping UMP consent check. '
        'Ensure this is legally valid for your audience.',
      );
      return true;
    }

    final ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

    final bool hasConsent = status == ConsentStatus.obtained || status == ConsentStatus.notRequired;

    GmaLogger.info('UMP ConsentStatus: $status → hasConsent: $hasConsent');

    return hasConsent;
  }

  // ── Adapter-specific consent methods ──────────────────────────────────────
  // Each method is isolated so it can be tested and updated independently.
  // ──────────────────────────────────────────────────────────────────────────

  /// Propagates consent to the **AppLovin MAX** mediation adapter.
  ///
  /// AppLovin is consistently one of the highest-CPM networks for interstitials
  /// and rewarded ads. Ensure your AppLovin SDK key is set in
  /// `AndroidManifest.xml` and `Info.plist`.
  ///
  /// See: https://developers.google.com/admob/flutter/mediation/applovin
  void _applyAppLovinConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationApplovin().setHasUserConsent(hasConsent);
      GmaMediationApplovin().setDoNotSell(doNotSell);
      GmaLogger.info('AppLovin — consent applied.');
    } catch (e, st) {
      GmaLogger.error('AppLovin consent error', e, st);
    }
  }

  // ── Template methods for future adapters ──────────────────────────────────
  // Un-comment and fill in when you add the corresponding package.

  /// Propagates consent to the **Unity Ads** mediation adapter.
  ///
  /// Unity LevelPlay is a top performer for gaming apps with rewarded-video
  /// inventory. GDPR and CCPA must both be set separately.
  ///
  /// See: https://developers.google.com/admob/flutter/mediation/unity
  void _applyUnityConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationUnity().setGDPRConsent(hasConsent);
      GmaMediationUnity().setCCPAConsent(!doNotSell);
      GmaLogger.info('Unity Ads — consent applied.');
    } catch (e, st) {
      GmaLogger.error('Unity consent error', e, st);
    }
  }

  /// Propagates GDPR / CCPA consent to the **Chartboost** SDK natively.
  ///
  /// ### How it works
  /// The `gma_mediation_chartboost` Flutter package intentionally exposes no
  /// Dart-level consent API — `GmaMediationChartboost` is an empty class used
  /// only for platform compatibility. This method bridges that gap in two steps:
  ///
  /// 1. Calls `GmaMediationChartboost()` to register the adapter with the
  ///    Google Mobile Ads mediation chain.
  /// 2. Invokes [ChartboostConsentChannel.applyConsent] which fires a
  ///    platform [MethodChannel] call handled by native code **inside this
  ///    package** — no `AppDelegate` or `MainActivity` changes needed by the
  ///    consumer.
  ///
  /// ### Per-platform behaviour
  /// | Platform | What happens |
  /// |----------|-------------|
  /// | **iOS**  | `GmaAllMediationsPlugin.swift` calls `Chartboost.addDataUseConsent(CBGDPRDataUseConsent)` and `Chartboost.addDataUseConsent(CBCCPADataUseConsent)` before the first ad request. |
  /// | **Android** | No-op — the Chartboost Android adapter reads consent automatically from the `RequestConfiguration` already applied to `MobileAds`. |
  ///
  /// ### Revenue impact 💶
  /// Without the correct GDPR signal, Chartboost drops out of the auction
  /// entirely for EEA users, causing a direct loss of fill rate and eCPM.
  /// This method fires automatically during [GmaAllMediations.initialize] so
  /// consent is always set before the first ad request.
  ///
  /// See: https://developers.google.com/admob/flutter/mediation/chartboost
  Future<void> _applyChartboostConsent({required bool hasConsent, required bool doNotSell}) async {
    try {
      // Step 1: register adapter with the GMA mediation chain.
      GmaMediationChartboost();

      // Step 2: fire native consent via MethodChannel.
      await ChartboostConsentChannel.applyConsent(hasConsent: hasConsent, doNotSell: doNotSell);

      GmaLogger.success(
        'Chartboost — GDPR/CCPA consent applied natively. '
        'hasConsent: $hasConsent, doNotSell: $doNotSell',
      );
    } catch (e, st) {
      GmaLogger.error('Chartboost consent error', e, st);
    }
  }

  /// Propagates consent signals to the **DT Exchange (Fyber)** mediation adapter.
  ///
  /// DT Exchange supports two independent privacy frameworks — CCPA (via US
  /// Privacy String) and LGPD (Brazil). Both are derived automatically from
  /// existing [GmaMediationConfig] values so no extra config fields are needed.
  ///
  /// ---
  ///
  /// ### US Privacy String (CCPA / US State Laws)
  ///
  /// The [IAB CCPA Compliance Framework](https://iabtechlab.com/standards/ccpa/)
  /// defines a standardised 4-character string to encode the user's US privacy
  /// choices:
  ///
  /// | Char | Field | Meaning |
  /// |------|-------|---------|
  /// | `1`  | Version | Always `"1"` (current spec) |
  /// | `Y`  | User notified | User was shown a privacy notice |
  /// | `N`/`Y` | Opted out of sale | `"N"` = sale allowed, `"Y"` = Do Not Sell |
  /// | `N`  | LSPA | Not applicable for most apps |
  ///
  /// **Derived automatically from [doNotSell] unless [usPrivacyStringData] is provided:**
  /// * `doNotSell = false` → `"1YNN"` (sale permitted)
  /// * `doNotSell = true`  → `"1YYN"` (Do Not Sell — opt-out)
  ///
  /// #### [usPrivacyStringData] — optional override
  /// Supply a custom IAB US Privacy String when your app manages US state
  /// privacy consent through a dedicated CMP or other mechanism. When provided,
  /// it takes precedence over the value derived from [doNotSell]. Pass `null`
  /// (the default) to use the automatically derived value.
  ///
  /// ```dart
  /// // Example: provide an explicit string from your CMP
  /// _applyDTExchange(
  ///   hasConsent: true,
  ///   doNotSell: false,
  ///   usPrivacyStringData: '1YNN',  // custom override
  /// );
  /// ```
  ///
  /// ### LGPD (Brazil — Lei Geral de Proteção de Dados)
  ///
  /// Brazil's privacy law operates similarly to GDPR. Mapped directly from
  /// [hasConsent]: `true` = consent granted; `false` = not granted.
  /// Harmless no-op for apps that do not operate in Brazil.
  ///
  /// ### Revenue impact 💶
  /// DT Exchange is a strong performer for interstitials and rewarded video,
  /// particularly in Latin America, Europe, and South-East Asia. Missing US
  /// Privacy or LGPD signals can cause DT Exchange to serve limited or no
  /// ads in those regions, directly reducing fill rate and eCPM.
  ///
  /// See: https://developers.google.com/admob/flutter/mediation/dt-exchange
  Future<void> _applyDTExchange({
    required bool hasConsent,
    required bool doNotSell,
    String? usPrivacyStringData,
  }) async {
    try {
      // ── US Privacy String (CCPA & US state laws) ─────────────────────────
      // Default derived from doNotSell: "1YNN" = sale allowed | "1YYN" = Do Not Sell.
      // usPrivacyStringData takes precedence when supplied by the caller.
      final String derivedPrivacyString = doNotSell ? '1YYN' : '1YNN';
      final String effectivePrivacyString = usPrivacyStringData ?? derivedPrivacyString;
      await GmaMediationDTExchange().setUSPrivacyString(effectivePrivacyString);

      // ── LGPD (Brazil) ─────────────────────────────────────────────────────
      // Maps hasConsent directly: true = consent granted, false = not granted.
      await GmaMediationDTExchange().setLgpdConsent(hasConsent);

      GmaLogger.success(
        'DT Exchange — consent applied. '
        'usPrivacyString: $effectivePrivacyString '
        '(${usPrivacyStringData != null ? 'custom' : 'derived from doNotSell'}), '
        'lgpdConsent: $hasConsent',
      );
    } catch (e, st) {
      GmaLogger.error('DT Exchange consent error', e, st);
    }
  }

  /// Propagates GDPR and CCPA consent to the **IronSource (LevelPlay)**
  /// mediation adapter.
  ///
  /// Unlike most adapters, IronSource exposes real Dart-level consent setters
  /// via the `gma_mediation_ironsource` package:
  ///
  /// * `setConsent(bool)` — GDPR: `true` = user consented, `false` = not consented.
  /// * `setDoNotSell(bool)` — CCPA: `true` = Do Not Sell (opt-out), `false` = permitted.
  ///
  /// Both are mapped directly from the resolved [hasConsent] and [doNotSell]
  /// values and are called automatically before the first ad is loaded.
  ///
  /// ---
  ///
  /// ### Android setup summary
  ///
  /// | Requirement | Status |
  /// |-------------|--------|
  /// | GDPR / CCPA consent (`setConsent`, `setDoNotSell`) | ✅ Auto — called here |
  /// | ProGuard rules | ✅ Auto — `consumerProguardFiles` in `android/build.gradle` |
  /// | Activity lifecycle (`onResume` / `onPause`) | ✅ Auto — `IronSourceLifecycleObserver` registered via `Application.ActivityLifecycleCallbacks` + reflection |
  /// | Maven repository (`https://android-sdk.is.com/`) | ⚠️ Manual — add to host app's `android/settings.gradle` |
  ///
  /// ### ⚠️ Only manual step: Maven repository
  /// Modern Flutter Android projects use `dependencyResolutionManagement` in
  /// `settings.gradle`, which cannot be injected by a plugin. Add the following
  /// to your host app's `android/settings.gradle`:
  /// ```groovy
  /// dependencyResolutionManagement {
  ///   repositories {
  ///     // ... existing repos ...
  ///     maven { url = uri("https://android-sdk.is.com/") }
  ///     maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
  ///   }
  /// }
  /// ```
  ///
  /// ### Revenue impact 💶
  /// IronSource LevelPlay is one of the highest-performing networks for
  /// rewarded video and interstitials globally. All lifecycle and consent
  /// signals are now wired up automatically by this package.
  ///
  /// See: https://developers.google.com/admob/flutter/mediation/ironsource

  Future<void> _applyIronSourceConsent({required bool hasConsent, required bool doNotSell}) async {
    try {
      // GDPR: true = user has consented to personalised ads.
      await GmaMediationIronsource().setConsent(hasConsent);

      // CCPA: true = Do Not Sell (user opted out of sale of personal data).
      await GmaMediationIronsource().setDoNotSell(doNotSell);

      GmaLogger.success(
        'IronSource — consent applied. '
        'hasConsent: $hasConsent, doNotSell: $doNotSell',
      );
    } catch (e, st) {
      GmaLogger.error('IronSource consent error', e, st);
    }
  }

  // /// Propagates consent to the **Liftoff Monetize (Vungle)** adapter.
  // ///
  // /// Liftoff excels at performance-based rewarded and interstitial campaigns.
  // ///
  // /// See: https://developers.google.com/admob/flutter/mediation/liftoffmonetize
  // void _applyLiftoffConsent({required bool hasConsent, required bool doNotSell}) {
  //   try {
  //     GmaMediationLiftoffmonetize().setGDPRStatus(hasConsent, null);
  //     GmaMediationLiftoffmonetize().setCCPAStatus(!doNotSell);
  //     GmaLogger.info('Liftoff Monetize — consent applied.');
  //   } catch (e, st) {
  //     GmaLogger.error('Liftoff consent error', e, st);
  //   }
  // }

  /// Propagates consent to the **Meta Audience Network** adapter.
  ///
  /// Meta (Facebook) is a dominant advertiser with high fill rates globally.
  ///
  /// See: https://developers.google.com/admob/flutter/mediation/meta
  void _applyMetaConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      // Meta reads ATT and consent automatically via the Facebook SDK.
      GmaMediationMeta();
      GmaLogger.info('Meta Audience Network — consent auto-managed by Meta SDK.');
    } catch (e, st) {
      GmaLogger.error('Meta consent error', e, st);
    }
  }

  /// Propagates consent to the **InMobi** mediation adapter.
  ///
  /// The `gma_mediation_inmobi` Flutter class is intentionally empty (same
  /// pattern as Chartboost). Instantiating it here registers the InMobi
  /// adapter with the Google Mobile Ads mediation chain. No Dart-level consent
  /// setters are exposed — consent flows via the GMA privacy APIs and the iOS
  /// App Tracking Transparency (ATT) status.
  ///
  /// ---
  ///
  /// ### iOS 14+ requirements (per InMobi guidelines)
  ///
  /// | Requirement | How it is handled |
  /// |-------------|-------------------|
  /// | **A. Latest SDK** | Managed by the `gma_mediation_inmobi` pub package version — keep it updated in `pubspec.yaml`. |
  /// | **B. SKAdNetwork attribution** | Handled automatically by the InMobi adapter once SKAN IDs are in `Info.plist` (see C). No code change needed. |
  /// | **C. SKAdNetwork IDs in Info.plist** | ⚠️ **Manual step** — copy the SKAN ID list from [https://www.inmobi.com/skadnetworkids.xml](https://www.inmobi.com/skadnetworkids.xml) into `Info.plist`. See README for details. |
  /// | **D. ATT prompt** | ✅ **Automatically handled** by [GmaAllMediations._requestAppTrackingTransparency] when [GmaMediationConfig.enableATT] is `true`. No extra work needed. |
  /// | **E. iOS 14 demand guide** | Informational — no code action required. InMobi adapts its demand pipeline automatically. |
  ///
  /// ### Revenue impact 💶
  /// InMobi has strong demand in Asia-Pacific, the Middle East, and emerging
  /// markets. Ensuring ATT is requested (already done by this package) and
  /// SKAN IDs are in place are the two highest-impact steps for InMobi eCPMs
  /// on iOS.
  ///
  /// See: https://developers.google.com/admob/flutter/mediation/inmobi
  /// See: https://support.inmobi.com/monetize/sdk-documentation/ios-guidelines/preparing-for-ios-14
  void _applyInMobiConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      // Registers the InMobi adapter with the GMA mediation chain.
      // Consent and ATT signals are propagated automatically via the GMA SDK
      // and the ATT flow already executed in GmaAllMediations._requestAppTrackingTransparency().
      GmaMediationInMobi();
      GmaLogger.success('InMobi — adapter registered. ATT handled by package.');
    } catch (e, st) {
      GmaLogger.error('InMobi consent error', e, st);
    }
  }

  // /// Propagates consent to the **Mintegral** mediation adapter.
  // ///
  // /// See: https://developers.google.com/admob/flutter/mediation/mintegral
  // void _applyMintegralConsent({required bool hasConsent, required bool doNotSell}) {
  //   try {
  //     GmaLogger.info('Mintegral — consent applied.');
  //   } catch (e, st) {
  //     GmaLogger.error('Mintegral consent error', e, st);
  //   }
  // }
}
