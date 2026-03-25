# CHANGELOG

## 0.0.1

* **Initial Release:** Welcome to `gma_all_mediations`!
* **13 Major Ad Networks Supported:**
  * AppLovin (`gma_mediation_applovin`)
  * Chartboost (`gma_mediation_chartboost`)
  * DT Exchange (`gma_mediation_dtexchange`)
  * InMobi (`gma_mediation_inmobi`)
  * IronSource (`gma_mediation_ironsource`)
  * Liftoff / Vungle (`gma_mediation_liftoffmonetize`)
  * Meta Audience Network (`gma_mediation_meta`)
  * Mintegral (`gma_mediation_mintegral`)
  * Moloco (`gma_mediation_moloco`)
  * myTarget (`gma_mediation_mytarget`)
  * Pangle (`gma_mediation_pangle`)
  * PubMatic (`gma_mediation_pubmatic`)
  * Unity Ads (`gma_mediation_unity`)
* **Zero Config Setup:** Removed the need to bridge Objective-C, Swift, Kotlin, or Java for the host application.
* **Consent Auto-Propagation:** Implemented reflection and built automatic CCPA (`doNotSell`), UMP, and GDPR consent forwarders for networks that do not hook into UMP natively (e.g., Liftoff/Vungle, IronSource).
* **iOS 14.5+ ATT Support:** Fully automated `AppTrackingTransparency` authorization requests.
* **Meta Tracking Support:** Automated the forwarding of iOS authorized tracking flag directly into the Meta Audience Network SDK.
* **Auto Lifecycle Management:** Built automatic Android `Activity` lifecycle listener (`IronSourceLifecycleObserver`) to fire `onResume` and `onPause` seamlessly in Flutter.
* Added massive inline documentation and a complete `README.md` guide bridging iOS `SKAdNetworkItems` and Android Maven repositories.
