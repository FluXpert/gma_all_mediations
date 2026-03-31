# CHANGELOG

## 0.0.4

* **Fix:** Ensured that `initialize()` properly awaits the completion of UMP consent flows. This fixes an issue where the initialisation method would return prematurely before the UMP consent form interactions and the subsequent mobile ads initialisation were completed.

## 0.0.3

* **Maintenance Release**: Updated package version to refresh and fix pending analysis on pub.dev.
* **Refinement**: Cleaned up internal testing structures and optimized package metadata for a polished release state.

## 0.0.2

* **API Refinement & Encapsulation:** Simplified the public API surface by privatizing internal utilities (`_MediationManager`, `_GmaLogger`) and organizing the codebase using `part`/`part of` directives.
* **Modernized Initialization:** Refactored the UMP and SDK initialization flows for better predictability and simpler asynchronous handling.
* **Resilient Ads Initialisation:** Updated the consent flow to ensure that ad initialisation proceeds even if UMP or ATT requests fail, preventing blocked revenue due to non-fatal configuration issues.
* **Comprehensive Testing:** Achieved significant test coverage with new unit tests for `GmaMediationConfig`, singleton logic, and mockable MethodChannel interactions.
* **Enhanced Documentation:**
  * Added a comprehensive **Mediation Platform Support** table in `README.md`.
  * Detailed **iOS Info.plist** and **Android build.gradle** requirements for all 13+ supported networks.
  * Expanded **SKAdNetwork ID** documentation with direct links to provider IDs.
* **CI/CD & Quality Control:** Integrated **GitHub Workflows** for automated package health checks (`pana`) and added Semantic Pull Request validation.
* **Project Maintenance:** Added repository funding configuration, resolved linting warnings, and synchronized the lock file for consistent builds.

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
