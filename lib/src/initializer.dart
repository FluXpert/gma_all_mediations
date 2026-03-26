part of 'internal.dart';

class GmaAllMediations {
  // ── Singleton ──────────────────────────────────────────────────────────────

  /// Shared singleton instance.
  ///
  /// Always use this instead of constructing a new [GmaAllMediations] object.
  static final GmaAllMediations instance = GmaAllMediations._internal();

  GmaAllMediations._internal();

  // ── State ──────────────────────────────────────────────────────────────────

  /// The resolved configuration used for this session.
  ///
  /// Available after [initialize] has been called.
  GmaMediationConfig? _config;

  bool _initialized = false;

  /// Whether the AdMob SDK has been fully initialised.
  ///
  /// Check this before loading ads to avoid `MobileAds not initialised` errors.
  bool get isInitialized => _initialized;

  // ── Config accessor ────────────────────────────────────────────────────────

  GmaMediationConfig get _resolvedConfig => _config!;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Initialises the mediation stack.
  ///
  /// Must be called **once** before loading any ads, typically in `main()`:
  ///
  /// ```dart
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await GmaAllMediations.instance.initialize();
  ///   runApp(const MyApp());
  /// }
  /// ```
  ///
  /// Subsequent calls are no-ops; the SDK will not be re-initialised.
  ///
  /// If [config] is omitted, a [GmaMediationConfig] with default values is
  /// used. Override individual fields to customise the integration.
  Future<void> initialize({GmaMediationConfig? config}) async {
    _config = config ?? GmaMediationConfig();

    _GmaLogger.init(enable: _resolvedConfig.debug);

    if (_initialized) {
      _GmaLogger.warn('GmaAllMediations is already initialised — skipping.');
      return;
    }

    _GmaLogger.info('Starting GMA All Mediations initialisation…');
    _GmaLogger.info('Config: $_config');

    await _requestConsentAndInitialise();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Step 1 + 2: Request UMP consent info and show the form if available.
  ///
  /// After the consent flow completes (or fails), [_initializeAdsSdk] is
  /// called so ads are always loaded — even when the user dismisses the form.
  Future<void> _requestConsentAndInitialise() async {
    _GmaLogger.info('Requesting UMP consent info update…');

    ConsentInformation.instance.requestConsentInfoUpdate(
      _resolvedConfig.consentRequestParameters ?? ConsentRequestParameters(),
      () async {
        // Success — decide whether to show the consent form.
        _GmaLogger.info('Consent info update succeeded.');

        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await _loadAndShowConsentForm();
        } else {
          _GmaLogger.info('No consent form required — proceeding to ad init.');
          await _initializeAdsSdk();
        }
      },
      (FormError requestError) async {
        // Non-fatal: log the error and continue so revenue is not blocked.
        _GmaLogger.error(
          'Consent info update failed: ${requestError.message}. '
          'Proceeding without consent form.',
        );
        await _initializeAdsSdk();
      },
    );
  }

  /// Loads and shows the UMP consent form, then proceeds to init ads.
  Future<void> _loadAndShowConsentForm() async {
    _GmaLogger.info('Loading UMP consent form…');

    ConsentForm.loadAndShowConsentFormIfRequired((FormError? formError) async {
      if (formError != null) {
        _GmaLogger.error(
          'Failed to load/show consent form: ${formError.message}. '
          'Proceeding without form.',
        );
        // Proceed even on error so we don't permanently block ads.
      } else {
        _GmaLogger.success('Consent form dismissed by user.');
      }

      // Always proceed to ad initialisation after the form interaction.
      await _initializeAdsSdk();
    });
  }

  /// Step 3 + 4: Applies ATT (iOS), mediation consent, then inits AdMob.
  Future<void> _initializeAdsSdk() async {
    // Guard against being called multiple times from parallel consent paths.
    if (_initialized) {
      _GmaLogger.warn('_initializeAdsSdk called but already initialised.');
      return;
    }

    await _requestAppTrackingTransparency();
    await _applyMediationConsent();
    await _startMobileAdsSdk();

    _initialized = true;
    _GmaLogger.success('GMA All Mediations fully initialised. 🚀');
  }

  /// Requests ATT authorisation on iOS 14.5+.
  ///
  /// Only runs when [GmaMediationConfig.enableATT] is `true` and the platform
  /// is iOS. ATT authorisation unlocks IDFA-based targeting, which is one of
  /// the most impactful changes you can make for iOS eCPMs.
  Future<void> _requestAppTrackingTransparency() async {
    if (!Platform.isIOS || !_resolvedConfig.enableATT) return;

    _GmaLogger.info('Requesting App Tracking Transparency authorisation…');
    try {
      final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
      _GmaLogger.info('ATT status: $status');

      final bool isAuthorized = status == TrackingStatus.authorized;

      // Meta Audience Network requires this explicit flag on iOS 14+.
      await _MetaConsentChannel.setAdvertiserTrackingEnabled(isAuthorized);

      if (isAuthorized) {
        _GmaLogger.success('ATT granted — personalised iOS ads enabled.');
      } else {
        _GmaLogger.warn('ATT not granted ($status). iOS ads may be limited in targeting.');
      }
    } catch (e, st) {
      _GmaLogger.error('ATT request failed', e, st);
    }
  }

  /// Propagates GDPR / CCPA consent to all active mediation adapters.
  Future<void> _applyMediationConsent() async {
    _GmaLogger.info('Applying consent signals to mediation adapters…');
    await _MediationManager.instance.applyConsentToAdapters(
      forceMediationConsent: _resolvedConfig.forceMediationConsent,
      doNotSell: _resolvedConfig.doNotSell,
    );
  }

  /// Applies the request configuration and initialises the AdMob SDK.
  Future<void> _startMobileAdsSdk() async {
    _GmaLogger.info('Initialising Google Mobile Ads SDK…');
    try {
      MobileAds.instance.updateRequestConfiguration(_resolvedConfig.requestConfiguration);
      final InitializationStatus status = await MobileAds.instance.initialize();
      _logAdapterInitStatus(status);
      _GmaLogger.success('Mobile Ads SDK initialised successfully.');
    } catch (e, st) {
      _GmaLogger.error('Mobile Ads SDK initialisation failed', e, st);
      // Re-throw so callers can react if needed.
      rethrow;
    }
  }

  /// Logs the initialisation status of each mediation adapter for diagnostics.
  ///
  /// Use this output to verify that every adapter you've integrated is being
  /// picked up by the SDK at runtime. Adapters with a `notReady` status
  /// typically indicate a missing SDK key or mis-configured manifest entry.
  void _logAdapterInitStatus(InitializationStatus status) {
    if (!_resolvedConfig.debug) return;

    debugPrint('[GMA] Adapter initialisation status:');
    status.adapterStatuses.forEach((String adapter, AdapterStatus adapterStatus) {
      debugPrint(
        '[GMA]   • $adapter → ${adapterStatus.state.name} '
        '(${adapterStatus.description})',
      );
    });
  }
}
