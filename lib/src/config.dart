part of 'internal.dart';

/// Configuration model for the **GMA All Mediations** package.
///
/// Pass an instance of [GmaMediationConfig] into [GmaAllMediations.initialize]
/// to customise every aspect of the mediation and consent flow.
///
/// ### Quick start
/// ```dart
/// await GmaAllMediations.instance.initialize(
///   config: GmaMediationConfig(
///     debug: false,
///     enableATT: true,
///     forceMediationConsent: false,
///     doNotSell: false,
///     testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
///   ),
/// );
/// ```
///
/// ### Revenue tips 💡
/// * Keep [forceMediationConsent] = `false` in production and rely on the UMP
///   SDK returning the correct consent signal — this gives you the widest
///   possible waterfall coverage with every mediation partner.
/// * Populate [testDeviceIds] only during development so real impressions are
///   never lost.
/// * Set [tagForChildDirectedTreatment] and [tagForUnderAgeOfConsent]
///   correctly for your audience; mis-tagging adults as children can cut CPMs
///   dramatically.
class GmaMediationConfig {
  /// Whether to request **App Tracking Transparency** (ATT) authorisation on
  /// iOS 14.5+.
  ///
  /// Enabling ATT dramatically improves IDFA-based targeting, which can lift
  /// eCPMs by 20–50 % on iOS. Defaults to `true`.
  final bool enableATT;

  /// Enables verbose logging via [_GmaLogger].
  ///
  /// Set to `false` in production to keep the console clean and to avoid
  /// leaking debug information in release builds. Defaults to `true`.
  final bool debug;

  /// Forces mediation adapters to treat the user as having given consent,
  /// regardless of the actual UMP consent signal.
  ///
  /// **Only use this when you have obtained consent through your own mechanism
  /// and are 100 % sure it is legally valid for the applicable regulation
  /// (e.g. GDPR, CCPA).** Misuse can lead to regulatory penalties.
  /// Defaults to `false`.
  final bool forceMediationConsent;

  /// Signals the "Do Not Sell" (CCPA opt-out) flag to all mediation adapters.
  ///
  /// When `true`, personalised advertising is disabled for California users
  /// who have opted out. Defaults to `false`.
  final bool doNotSell;

  /// Test device IDs used when [debug] is `true`.
  ///
  /// Add the hashed device ID printed by the AdMob SDK in logcat / Xcode
  /// console during the first run. Test ads will then be served instead of
  /// live inventory, preventing invalid-click policy violations.
  final List<String> testDeviceIds;

  /// Controls child-directed content tagging for COPPA compliance.
  ///
  /// Use [TagForChildDirectedTreatment.yes] when your app is directed at
  /// children. This restricts ad categories and may reduce fill rate but is
  /// legally required under COPPA.
  ///
  /// Defaults to [TagForChildDirectedTreatment.unspecified].
  final int? tagForChildDirectedTreatment;

  /// Controls under-age-of-consent tagging (GDPR Article 8 / ePrivacy).
  ///
  /// Set to [TagForUnderAgeOfConsent.yes] if your audience includes users
  /// under the age of consent in the EEA.
  ///
  /// Defaults to [TagForUnderAgeOfConsent.unspecified].
  final int? tagForUnderAgeOfConsent;

  /// Maximum ad content rating allowed in ad responses.
  ///
  /// Restricting this (e.g. to [MaxAdContentRating.pg]) can reduce CPMs
  /// but may be required for certain audiences. Leave as
  /// [MaxAdContentRating.unspecified] (empty string) to maximise revenue.
  final String? maxAdContentRating;

  /// Custom [ConsentRequestParameters] forwarded to the UMP SDK.
  ///
  /// If `null`, a default instance is used. Override to pass a geography
  /// override during testing:
  /// ```dart
  /// consentRequestParameters: ConsentRequestParameters(
  ///   consentDebugSettings: ConsentDebugSettings(
  ///     debugGeography: ConsentDebugGeography.EEA,
  ///     testIdentifiers: ['YOUR_HASHED_ID'],
  ///   ),
  /// ),
  /// ```
  final ConsentRequestParameters? consentRequestParameters;

  // ── Derived / computed fields ────────────────────────────────────────────

  /// The fully-built [RequestConfiguration] derived from this config.
  ///
  /// Passed to [MobileAds.instance.updateRequestConfiguration] before the
  /// AdMob SDK is initialised.
  late final RequestConfiguration requestConfiguration;

  /// Creates a [GmaMediationConfig].
  ///
  /// All parameters are optional and have sensible defaults for quick
  /// integration. Override individual fields as your app requires.
  GmaMediationConfig({
    this.enableATT = true,
    this.debug = true,
    this.forceMediationConsent = false,
    this.doNotSell = false,
    this.testDeviceIds = const [],
    int? tagForChildDirectedTreatment,
    int? tagForUnderAgeOfConsent,
    String? maxAdContentRating,
    this.consentRequestParameters,
  }) : tagForChildDirectedTreatment =
           tagForChildDirectedTreatment ??
           TagForChildDirectedTreatment.unspecified,
       tagForUnderAgeOfConsent =
           tagForUnderAgeOfConsent ?? TagForUnderAgeOfConsent.unspecified,
       maxAdContentRating =
           maxAdContentRating ?? MaxAdContentRating.unspecified {
    requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: this.tagForChildDirectedTreatment,
      tagForUnderAgeOfConsent: this.tagForUnderAgeOfConsent,
      maxAdContentRating: this.maxAdContentRating,
      testDeviceIds: testDeviceIds,
    );
  }

  @override
  String toString() =>
      'GmaMediationConfig('
      'enableATT: $enableATT, '
      'debug: $debug, '
      'forceMediationConsent: $forceMediationConsent, '
      'doNotSell: $doNotSell, '
      'testDeviceIds: $testDeviceIds'
      ')';
}
