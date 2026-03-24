import 'package:google_mobile_ads/google_mobile_ads.dart';

class GmaMediationConfig {
  final bool enableATT;
  final bool debug;
  final bool forceMediationConsent;
  RequestConfiguration? requestConfiguration;
  final bool doNotSell;
  ConsentRequestParameters? consentRequestParameters;

  GmaMediationConfig({
    this.enableATT = true,
    this.debug = true,
    this.forceMediationConsent = true,
    this.doNotSell = false,
    this.consentRequestParameters,
  }) {
    requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      maxAdContentRating: MaxAdContentRating.unspecified,
      testDeviceIds: [],
    );

    consentRequestParameters = ConsentRequestParameters();
  }
}
