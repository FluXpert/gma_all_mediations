# gma_all_mediations — Complete AI Handoff Context

> **Last updated:** 2026-03-25
> **Purpose:** This document gives any AI assistant full context to continue work on this package without re-reading all source code. Read this before touching anything.

---

## 1. What This Package Does

`gma_all_mediations` is a **Flutter plugin package** that wraps and automates the entire Google Mobile Ads (AdMob) mediation setup:

1. **ATT** — requests App Tracking Transparency on iOS 14.5+
2. **UMP** — shows the Google User Messaging Platform consent form (GDPR/ePrivacy)
3. **Consent propagation** — forwards GDPR/CCPA signals to every active mediation adapter
4. **AdMob SDK init** — initialises `MobileAds` with the correct `RequestConfiguration`

**Goal:** A Flutter developer adds this package, calls `GmaAllMediations.instance.initialize()` in `main()`, and every mediation adapter is correctly configured for maximum revenue. Zero native file changes needed (with one exception per adapter — see § 6).

---

## 2. Package Structure

``` txt
gma_all_mediations/
├── lib/
│   ├── gma_all_mediations.dart          ← barrel file / public API
│   └── src/
│       ├── initializer.dart             ← GmaAllMediations (main entry point, singleton)
│       ├── mediation_manager.dart       ← MediationManager (consent propagation, singleton)
│       ├── config.dart                  ← GmaMediationConfig (configuration model)
│       ├── logger.dart                  ← GmaLogger (internal tagged logger)
│       └── chartboost_consent_channel.dart ← MethodChannel bridge for Chartboost native consent
│
├── ios/
│   ├── Classes/GmaAllMediationsPlugin.swift  ← iOS plugin: Chartboost consent + MethodChannel
│   └── gma_all_mediations.podspec           ← declares GoogleMobileAdsMediationChartboost dep
│
├── android/
│   ├── build.gradle                         ← standard plugin Gradle + consumerProguardFiles
│   ├── proguard-rules.pro                   ← IronSource ProGuard rules (auto-applied to host)
│   └── src/main/kotlin/com/fluxpert/gma_all_mediations/
│       ├── GmaAllMediationsPlugin.kt         ← Android plugin: Chartboost no-op + IronSource lifecycle
│       └── IronSourceLifecycleObserver.kt    ← registers Application.ActivityLifecycleCallbacks for IronSource
│
├── pubspec.yaml
├── README.md                                ← developer-facing setup notes
└── INFORMATION.md                           ← THIS FILE
```

---

## 3. Initialization Flow

```
GmaAllMediations.initialize()
  │
  ├─ Step 1: ConsentInformation.requestConsentInfoUpdate()  [UMP]
  │    └─ If form available → ConsentForm.loadAndShowConsentFormIfRequired()
  │
  └─ _initializeAdsSdk()
       ├─ Step 2: _requestAppTrackingTransparency()   [iOS only, if enableATT=true]
       ├─ Step 3: MediationManager.applyConsentToAdapters()
       │    ├─ _applyAppLovinConsent()
       │    ├─ _applyUnityConsent()
       │    ├─ _applyChartboostConsent()   ← async (MethodChannel)
       │    ├─ _applyDTExchange()          ← async (US Privacy String + LGPD)
       │    ├─ _applyIronSourceConsent()   ← async (real Dart API)
       │    └─ _applyInMobiConsent()       ← adapter registration only
       │
       └─ Step 4: MobileAds.instance.initialize()  [Google AdMob SDK]
```

**Guard:** `GmaAllMediations._initialized` prevents double-initialization. Second calls to `initialize()` are no-ops.

---

## 4. Key Classes

### `GmaAllMediations` (`initializer.dart`)
- Singleton: `GmaAllMediations.instance`
- Public method: `initialize({GmaMediationConfig? config})`
- State: `bool isInitialized`
- Drives the 4-step flow above

### `MediationManager` (`mediation_manager.dart`)
- Singleton: `MediationManager.instance`
- Public method: `applyConsentToAdapters({required bool forceMediationConsent, required bool doNotSell})`
- Internally resolves consent via `_resolveConsentSignal()` → checks `ConsentStatus.obtained` or `ConsentStatus.notRequired`
- Each adapter has its own isolated `_apply*Consent()` method wrapped in try-catch

### `GmaMediationConfig` (`config.dart`)
- All fields have sensible defaults
- Key fields:
  - `debug` (bool, default true) — controls `GmaLogger`
  - `enableATT` (bool, default true) — iOS ATT prompt
  - `forceMediationConsent` (bool, default false) — skip UMP check (use with legal caution)
  - `doNotSell` (bool, default false) — CCPA opt-out
  - `testDeviceIds` (List\<String\>) — for test ad serving
  - `tagForChildDirectedTreatment` (int?) — COPPA
  - `tagForUnderAgeOfConsent` (int?) — GDPR Article 8
  - `maxAdContentRating` (String?) — content filter
  - `consentRequestParameters` — optional UMP override (used for geo-debugging)
- Computes `requestConfiguration` (a `RequestConfiguration` object) in constructor

### `GmaLogger` (`logger.dart`)
- Static-only utility class
- `GmaLogger.init(enable: bool)` — called by `initialize()`
- Methods: `info()`, `success()`, `warn()`, `error()`
- Prefix: `[GMA]`. Errors always log; others only when enabled.

### `ChartboostConsentChannel` (`chartboost_consent_channel.dart`)
- Sends consent to Chartboost natively via MethodChannel `"gma_all_mediations/chartboost_consent"`
- Handles `MissingPluginException` gracefully (unit-test safe)
- iOS: calls are forwarded to `GmaAllMediationsPlugin.swift` → `Chartboost.addDataUseConsent()`
- Android: no-op (Chartboost reads consent automatically)

---

## 5. Active Mediation Adapters

| Adapter | Package | Dart Consent API | Consent Method | Notes |
|---------|---------|-------------------|----------------|-------|
| **AppLovin MAX** | `gma_mediation_applovin ^2.5.2` | ✅ Real | `setHasUserConsent`, `setDoNotSell` | |
| **Unity Ads** | `gma_mediation_unity ^1.6.5` | ✅ Real | `setGDPRConsent`, `setCCPAConsent(!doNotSell)` | Note: CCPA is inverted |
| **Chartboost** | `gma_mediation_chartboost ^1.4.1` | ❌ Empty class | Native MethodChannel → `GmaAllMediationsPlugin.swift` | iOS only has real native call; Android is no-op |
| **DT Exchange (Fyber)** | `gma_mediation_dtexchange ^1.3.3` | ✅ Real | `setUSPrivacyString`, `setLgpdConsent` | US Privacy String derived from `doNotSell`; supports `usPrivacyStringData` override |
| **IronSource (LevelPlay)** | `gma_mediation_ironsource ^2.3.0` | ✅ Real | `setConsent`, `setDoNotSell` | Lifecycle auto-managed by `IronSourceLifecycleObserver` via reflection |
| **InMobi** | `gma_mediation_inmobi ^2.0.1` | ❌ Empty class | Adapter registration only | ATT handled by package; SKAN IDs need manual plist entry |
| **Meta Audience Network** | `gma_mediation_meta` | ❌ Empty class | Adapter registration only | Consent auto-managed by OS/SDK via ATT and UMP forwarding |
| **Liftoff Monetize (Vungle)** | `gma_mediation_liftoffmonetize ^1.4.3` | ✅ Real | `setGDPRStatus(bool, null)`, `setCCPAStatus(!doNotSell)` | Exact boolean setters; depends on explicit Dart calls |
| **Mintegral** | `gma_mediation_mintegral ^2.0.3` | ❌ Empty class | Adapter registration only | Consent auto-managed natively by UMP |
| **Moloco** | `gma_mediation_moloco ^3.3.0` | ❌ Empty class | Adapter registration only | Consent auto-managed natively by UMP |
| **myTarget** | `gma_mediation_mytarget ^1.8.0` | ❌ Empty class | Adapter registration only | Consent auto-managed natively by UMP |
| **Pangle** | `gma_mediation_pangle ^3.5.3` | ❌ Empty class | Adapter registration only | Consent auto-managed natively by UMP |

### Commented-out (future) adapters
- (None currently)

---

## 6. Native Layer

### iOS (`ios/`)

**`GmaAllMediationsPlugin.swift`**
- Registers MethodChannel `"gma_all_mediations/chartboost_consent"`
- Handles `applyConsent` method:
  - Reads `hasConsent` (Bool) and `doNotSell` (Bool) from arguments
  - Calls `Chartboost.addDataUseConsent(CBGDPRDataUseConsent(consent: .behavioral/.nonBehavioral))`
  - Calls `Chartboost.addDataUseConsent(CBCCPADataUseConsent(consent: .optInSale/.optOutSale))`
- Depends on `ChartboostSDK` (imported via `GoogleMobileAdsMediationChartboost ~> 9.11.0` pod)

**`gma_all_mediations.podspec`**
- `s.dependency 'Flutter'`
- `s.dependency 'GoogleMobileAdsMediationChartboost', '~> 9.11.0'`
- Platform: iOS 13.0+, Swift 5.0

### Android (`android/`)

**`GmaAllMediationsPlugin.kt`** (`package com.fluxpert.gma_all_mediations`)
- Implements `FlutterPlugin`, `MethodCallHandler`, `ActivityAware`
- Registers MethodChannel `"gma_all_mediations/chartboost_consent"` → `handleApplyConsent` is a no-op + log
- On `onAttachedToEngine`: registers `IronSourceLifecycleObserver` with `Application.registerActivityLifecycleCallbacks()`
- On `onDetachedFromEngine`: unregisters the observer

**`IronSourceLifecycleObserver.kt`**
- Implements `Application.ActivityLifecycleCallbacks`
- In `onActivityResumed` / `onActivityPaused`: calls `IronSource.onResume(Activity)` / `IronSource.onPause(Activity)` via **reflection** (`Class.forName("com.ironsource.mediationsdk.IronSource")`)
- Reflection means zero compile-time dependency on IronSource → safe if `gma_mediation_ironsource` is removed

**`proguard-rules.pro`**
- Consumer ProGuard rules for IronSource (auto-applied to host app via `consumerProguardFiles`)
- Keeps `com.ironsource.**`, `com.unity3d.mediation.**`, `JavascriptInterface`, GMA classes

**`build.gradle`**
- `minSdkVersion 21`
- `consumerProguardFiles 'proguard-rules.pro'`

---

## 7. What Still Requires Manual Host-App Setup

| Item | Platform | Where | Why It Can't Be Automated |
|------|----------|-------|---------------------------|
| AppLovin SDK Key | Android + iOS | `AndroidManifest.xml`, `Info.plist` | App-specific value |
| InMobi SKAN IDs | iOS `Info.plist` | Copy from [inmobi.com/skadnetworkids.xml](https://www.inmobi.com/skadnetworkids.xml) | Apple plist file, not injectable |
| AppLovin SKAN IDs | iOS `Info.plist` | Copy from [applovin.com skadnetworkids.xml](https://skadnetwork-ids.applovin.com/v1/skadnetworkids.xml) | Same reason |
| IronSource Maven repos | Android `settings.gradle` | Add inside `dependencyResolutionManagement.repositories` | Modern Gradle sandboxes plugin repos; they don't propagate to host |
| Chartboost `READ_PHONE_STATE` (optional) | Android `AndroidManifest.xml` | `<uses-permission android:name="android.permission.READ_PHONE_STATE"/>` | Optional; app's manifest |

**IronSource maven (settings.gradle):**
```groovy
dependencyResolutionManagement {
  repositories {
    maven { url = uri("https://android-sdk.is.com/") }
    maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
  }
}
```

---

## 8. Pattern: Adding a New Adapter

Follow these exact steps every time:

1. **`pubspec.yaml`** — add `gma_mediation_<name>: ^x.y.z`
2. **`mediation_manager.dart` imports** — uncomment or add `import 'package:gma_mediation_<name>/...'`
3. **`mediation_manager.dart` call site** — add `_apply<Name>Consent(hasConsent: hasConsent, doNotSell: doNotSell);` inside `applyConsentToAdapters()`
4. **Implement the method:**
   - If the Flutter class is **empty** (like Chartboost/InMobi) → instantiate it for registration, then check if native code is needed
   - If it exposes **real Dart setters** (like AppLovin/IronSource) → call them directly
5. **Doc comment** — document per-platform behaviour and revenue impact
6. **README.md** — add a section with manual setup steps if any

---

## 9. DT Exchange — US Privacy String Reference

The `_applyDTExchange` method computes the IAB US Privacy String:

| `doNotSell` value | Derived string | Meaning |
|-------------------|----------------|---------|
| `false` | `"1YNN"` | User notified; sale allowed |
| `true` | `"1YYN"` | User notified; opted out (Do Not Sell) |

An optional `usPrivacyStringData` parameter overrides the derived value (useful when a CMP provides a precise string).

---

## 10. Conventions & Rules

- **No double-init:** `_initialized` flag in `GmaAllMediations` guards against repeated calls
- **Isolation:** every `_apply*Consent()` method has its own `try-catch` — one adapter failure never blocks others
- **Async:** `_applyChartboostConsent`, `_applyDTExchange`, `_applyIronSourceConsent` are all `async` and properly `await`ed in `applyConsentToAdapters`
- **Logger:** always use `GmaLogger.*()` — never `print()` or `debugPrint()` directly in `lib/src/`
- **dart analyze:** must always pass with `No issues found!` before committing — run:
  ```bash
  dart analyze lib/
  ```
- **Native reflection pattern:** when calling SDK lifecycle/consent methods in native Android without a compile-time dep, use `Class.forName(...)` + `.getMethod(...)` + `.invoke(null, ...)`, wrapped in `try-catch (_: ClassNotFoundException)`

---

## 11. Quick Usage (for host app developers)

```dart
// main.dart
import 'package:gma_all_mediations/gma_all_mediations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GmaAllMediations.instance.initialize(
    config: GmaMediationConfig(
      debug: false,          // true during development
      enableATT: true,       // iOS ATT prompt (+20-50% eCPM)
      doNotSell: false,      // set true for CCPA opt-out users
      testDeviceIds: [],     // add hashed device IDs during testing
    ),
  );
  runApp(const MyApp());
}
```

---

## 12. Reference Links

| Resource | URL |
|----------|-----|
| All Flutter mediation adapters | https://github.com/googleads/googleads-mobile-flutter/tree/main/packages/mediation |
| AppLovin | https://developers.google.com/admob/flutter/mediation/applovin |
| Chartboost | https://developers.google.com/admob/flutter/mediation/chartboost |
| DT Exchange | https://developers.google.com/admob/flutter/mediation/dt-exchange |
| InMobi | https://developers.google.com/admob/flutter/mediation/inmobi |
| InMobi iOS 14 guide | https://support.inmobi.com/monetize/sdk-documentation/ios-guidelines/preparing-for-ios-14 |
| IronSource | https://developers.google.com/admob/flutter/mediation/ironsource |
| Unity Ads | https://developers.google.com/admob/flutter/mediation/unity |
| Mintegral | https://developers.google.com/admob/flutter/mediation/mintegral |
| Liftoff Monetize | https://developers.google.com/admob/flutter/mediation/liftoffmonetize |
| Meta Audience Network | https://developers.google.com/admob/flutter/mediation/meta |
| InMobi SKAN IDs | https://www.inmobi.com/skadnetworkids.xml |
| AppLovin SKAN IDs | https://skadnetwork-ids.applovin.com/v1/skadnetworkids.xml |
| IronSource ProGuard | https://developers.ironsrc.com/ironsource-mobile/android/android-sdk-integration-guide/ |
