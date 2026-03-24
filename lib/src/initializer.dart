import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'config.dart';
import 'logger.dart';
import 'mediation_manager.dart';

class GmaAllMediations {
  static final GmaAllMediations instance = GmaAllMediations._();

  GmaMediationConfig? config;

  GmaMediationConfig get _config => config!;

  GmaAllMediations._();

  bool _initialized = false;

  Future<void> initialize({GmaMediationConfig? config}) async {
    config ??= GmaMediationConfig();
    this.config = config;

    GmaLogger.init(_config.debug);

    if (_initialized) {
      GmaLogger.logMessage("Already initialized");
      return;
    }

    GmaLogger.logMessage("Initializing GMA All Mediations...");

    _consentRequest();
  }

  Future<void> _initializeAds() async {
    if (Platform.isIOS && _config.enableATT) {
      try {
        final status = await AppTrackingTransparency.requestTrackingAuthorization();
        GmaLogger.logMessage("ATT Status: $status");
      } catch (e) {
        GmaLogger.logMessage("ATT Error: $e");
      }
    }

    // Step 3: Mediation setup
    await MediationManager().setup(_config.forceMediationConsent, _config.doNotSell);

    // Step 4: Initialize AdMob
    MobileAds.instance.updateRequestConfiguration(_config.requestConfiguration!);

    await MobileAds.instance.initialize();

    GmaLogger.logMessage("AdMob initialized");

    _initialized = true;
  }

  Future<void> _consentRequest() async {
    ConsentInformation.instance.requestConsentInfoUpdate(
      _config.consentRequestParameters!,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadAndShowConsentFormIfRequired((FormError? loadAndShowError) async {
            if (loadAndShowError != null) {
              debugPrint("Consent Form Error: ${loadAndShowError.message}");
            }
            if (await ConsentInformation.instance.canRequestAds()) {
              _initializeAds();
            }
          });
        } else {
          if (await ConsentInformation.instance.canRequestAds()) {
            _initializeAds();
          } else {
            _initializeAds();
          }
        }
      },
      (FormError requestConsentError) {
        debugPrint("Consent Info Update Error: ${requestConsentError.message}");
        _initializeAds();
      },
    );
  }
}
