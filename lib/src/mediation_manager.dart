// import 'package:gma_mediation_applovin/gma_mediation_applovin.dart';

// import 'package:gma_mediation_inmobi/gma_mediation_inmobi.dart';
// import 'package:gma_mediation_ironsource/gma_mediation_ironsource.dart';
// import 'package:gma_mediation_liftoffmonetize/gma_mediation_liftoffmonetize.dart';
// import 'package:gma_mediation_meta/gma_mediation_meta.dart';
// import 'package:gma_mediation_mintegral/gma_mediation_mintegral.dart';
// import 'package:gma_mediation_unity/gma_mediation_unity.dart';

import 'package:gma_all_mediations/src/logger.dart';
import 'package:gma_mediation_applovin/gma_mediation_applovin.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show ConsentInformation, ConsentStatus;

class MediationManager {
  Future<void> setup(bool forceMediationConsent, bool doNotSell) async {
    final consentStatus = await ConsentInformation.instance.getConsentStatus();
    final hasConsent =
        consentStatus == ConsentStatus.obtained ||
        consentStatus == ConsentStatus.notRequired ||
        forceMediationConsent;

    GmaLogger.logMessage("Setting up mediation adapters...");

    GmaMediationApplovin().setHasUserConsent(hasConsent);
    GmaMediationApplovin().setDoNotSell(doNotSell);

    // GmaMediationUnity().setGDPRConsent(hasConsent);
    // GmaMediationUnity().setCCPAConsent(hasConsent);

    // GmaMediationIronsource().setConsent(hasConsent);
    // GmaMediationIronsource().setDoNotSell(doNotSell);

    // GmaMediationLiftoffmonetize().setGDPRStatus(hasConsent, null);
    // GmaMediationLiftoffmonetize().setCCPAStatus(hasConsent);

    // GmaMediationMeta();
    // GmaMediationInMobi();
    // GmaMediationMintegral();

    GmaLogger.logMessage("Mediation setup complete");
  }
}
