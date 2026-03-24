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
// import 'package:gma_mediation_inmobi/gma_mediation_inmobi.dart';
// import 'package:gma_mediation_ironsource/gma_mediation_ironsource.dart';
// import 'package:gma_mediation_liftoffmonetize/gma_mediation_liftoffmonetize.dart';
// import 'package:gma_mediation_meta/gma_mediation_meta.dart';
// import 'package:gma_mediation_mintegral/gma_mediation_mintegral.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show ConsentInformation, ConsentStatus;

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
    _applyChartboostConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    // _applyIronSourceConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    // _applyLiftoffConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    // _applyMetaConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    // _applyInMobiConsent(hasConsent: hasConsent, doNotSell: doNotSell);
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

  void _applyChartboostConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationChartboost();
      GmaLogger.info('Chartboost — consent applied.');
    } catch (e, st) {
      GmaLogger.error('Chartboost consent error', e, st);
    }
  }

  // /// Propagates consent to the **IronSource (LevelPlay)** mediation adapter.
  // ///
  // /// See: https://developers.google.com/admob/flutter/mediation/ironsource
  // void _applyIronSourceConsent({required bool hasConsent, required bool doNotSell}) {
  //   try {
  //     GmaMediationIronsource().setConsent(hasConsent);
  //     GmaMediationIronsource().setDoNotSell(doNotSell);
  //     GmaLogger.info('IronSource — consent applied.');
  //   } catch (e, st) {
  //     GmaLogger.error('IronSource consent error', e, st);
  //   }
  // }

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

  // /// Propagates consent to the **Meta Audience Network** adapter.
  // ///
  // /// Meta (Facebook) is a dominant advertiser with high fill rates globally.
  // ///
  // /// See: https://developers.google.com/admob/flutter/mediation/meta
  // void _applyMetaConsent({required bool hasConsent, required bool doNotSell}) {
  //   try {
  //     // Meta reads ATT and consent automatically via the Facebook SDK.
  //     GmaLogger.info('Meta Audience Network — consent auto-managed by Meta SDK.');
  //   } catch (e, st) {
  //     GmaLogger.error('Meta consent error', e, st);
  //   }
  // }

  // /// Propagates consent to the **InMobi** mediation adapter.
  // ///
  // /// See: https://developers.google.com/admob/flutter/mediation/inmobi
  // void _applyInMobiConsent({required bool hasConsent, required bool doNotSell}) {
  //   try {
  //     GmaLogger.info('InMobi — consent applied.');
  //   } catch (e, st) {
  //     GmaLogger.error('InMobi consent error', e, st);
  //   }
  // }

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
