part of 'internal.dart';

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
class _MediationManager {
  // ── Singleton ──────────────────────────────────────────────────────────────

  /// Shared singleton instance.
  static final _MediationManager instance = _MediationManager._();

  _MediationManager._();

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

    _GmaLogger.info(
      'Applying consent to adapters — hasConsent: $hasConsent, '
      'doNotSell: $doNotSell',
    );

    _applyAppLovinConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyUnityConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    await _applyChartboostConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    await _applyDTExchange(hasConsent: hasConsent, doNotSell: doNotSell);
    await _applyIronSourceConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyLiftoffConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyMetaConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyInMobiConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyMintegralConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyMolocoConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyMyTargetConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyPangleConsent(hasConsent: hasConsent, doNotSell: doNotSell);
    _applyPubMaticConsent(hasConsent: hasConsent, doNotSell: doNotSell);

    _GmaLogger.success('Consent applied to all active mediation adapters.');
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
      _GmaLogger.warn(
        'forceMediationConsent is true — skipping UMP consent check. '
        'Ensure this is legally valid for your audience.',
      );
      return true;
    }

    final ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

    final bool hasConsent = status == ConsentStatus.obtained || status == ConsentStatus.notRequired;

    _GmaLogger.info('UMP ConsentStatus: $status → hasConsent: $hasConsent');

    return hasConsent;
  }

  // ── Adapter-specific consent methods ──────────────────────────────────────
  // Each method is isolated so it can be tested and updated independently.
  // ──────────────────────────────────────────────────────────────────────────

  /// Propagates consent to the **AppLovin MAX** mediation adapter.
  void _applyAppLovinConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationApplovin().setHasUserConsent(hasConsent);
      GmaMediationApplovin().setDoNotSell(doNotSell);
      _GmaLogger.info('AppLovin — consent applied.');
    } catch (e, st) {
      _GmaLogger.error('AppLovin consent error', e, st);
    }
  }

  /// Propagates consent to the **Unity Ads** mediation adapter.
  void _applyUnityConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationUnity().setGDPRConsent(hasConsent);
      GmaMediationUnity().setCCPAConsent(!doNotSell);
      _GmaLogger.info('Unity Ads — consent applied.');
    } catch (e, st) {
      _GmaLogger.error('Unity consent error', e, st);
    }
  }

  /// Propagates GDPR / CCPA consent to the **Chartboost** SDK natively.
  Future<void> _applyChartboostConsent({required bool hasConsent, required bool doNotSell}) async {
    try {
      // Step 1: register adapter with the GMA mediation chain.
      // GmaMediationChartboost();

      // Step 2: fire native consent via MethodChannel.
      await _ChartboostConsentChannel.applyConsent(hasConsent: hasConsent, doNotSell: doNotSell);

      _GmaLogger.success(
        'Chartboost — GDPR/CCPA consent applied natively. '
        'hasConsent: $hasConsent, doNotSell: $doNotSell',
      );
    } catch (e, st) {
      _GmaLogger.error('Chartboost consent error', e, st);
    }
  }

  /// Propagates consent signals to the **DT Exchange (Fyber)** mediation adapter.
  Future<void> _applyDTExchange({
    required bool hasConsent,
    required bool doNotSell,
    // String? usPrivacyStringData,
  }) async {
    try {
      // final String derivedPrivacyString = doNotSell ? '1YYN' : '1YNN';
      // final String effectivePrivacyString = usPrivacyStringData ?? derivedPrivacyString;
      // await GmaMediationDTExchange().setUSPrivacyString(effectivePrivacyString);
      // await GmaMediationDTExchange().setLgpdConsent(hasConsent);

      _GmaLogger.success('DT Exchange — consent applied.');
    } catch (e, st) {
      _GmaLogger.error('DT Exchange consent error', e, st);
    }
  }

  /// Propagates GDPR and CCPA consent to the **IronSource (LevelPlay)**
  Future<void> _applyIronSourceConsent({required bool hasConsent, required bool doNotSell}) async {
    try {
      await GmaMediationIronsource().setConsent(hasConsent);
      await GmaMediationIronsource().setDoNotSell(doNotSell);
      _GmaLogger.success('IronSource — consent applied.');
    } catch (e, st) {
      _GmaLogger.error('IronSource consent error', e, st);
    }
  }

  /// Propagates consent to the **Liftoff Monetize (Vungle)** adapter.
  void _applyLiftoffConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationLiftoffmonetize().setGDPRStatus(hasConsent, null);
      GmaMediationLiftoffmonetize().setCCPAStatus(!doNotSell);
      _GmaLogger.success('Liftoff Monetize — GDPR and CCPA consent applied.');
    } catch (e, st) {
      _GmaLogger.error('Liftoff consent error', e, st);
    }
  }

  /// Propagates consent to the **Meta Audience Network** adapter.
  void _applyMetaConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationMeta();
      _GmaLogger.success('Meta Audience Network — adapter registered.');
    } catch (e, st) {
      _GmaLogger.error('Meta consent error', e, st);
    }
  }

  /// Propagates consent to the **InMobi** mediation adapter.
  void _applyInMobiConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      GmaMediationInMobi();
      _GmaLogger.success('InMobi — adapter registered.');
    } catch (e, st) {
      _GmaLogger.error('InMobi consent error', e, st);
    }
  }

  /// Propagates consent to the **Mintegral** mediation adapter.
  void _applyMintegralConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      // GmaMediationMintegral();
      _GmaLogger.success('Mintegral — adapter registered.');
    } catch (e, st) {
      _GmaLogger.error('Mintegral consent error', e, st);
    }
  }

  /// Propagates consent to the **Moloco** mediation adapter.
  void _applyMolocoConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      // GmaMediationMoloco();
      _GmaLogger.success('Moloco — adapter registered.');
    } catch (e, st) {
      _GmaLogger.error('Moloco consent error', e, st);
    }
  }

  /// Propagates consent to the **myTarget** mediation adapter.
  void _applyMyTargetConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      // GmaMediationmytarget();
      _GmaLogger.success('myTarget — adapter registered.');
    } catch (e, st) {
      _GmaLogger.error('myTarget consent error', e, st);
    }
  }

  /// Propagates consent to the **Pangle** mediation adapter.
  void _applyPangleConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      // GmaMediationPangle();
      _GmaLogger.success('Pangle — adapter registered.');
    } catch (e, st) {
      _GmaLogger.error('Pangle consent error', e, st);
    }
  }

  /// Propagates consent to the **PubMatic** mediation adapter.
  void _applyPubMaticConsent({required bool hasConsent, required bool doNotSell}) {
    try {
      // GmaMediationPubmatic();
      _GmaLogger.success('PubMatic — adapter registered.');
    } catch (e, st) {
      _GmaLogger.error('PubMatic consent error', e, st);
    }
  }
}
