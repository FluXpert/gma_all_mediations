# GMA All Mediations 🚀

<p align="center">
  <!-- <a href="https://github.com/FluXpert/gma_all_mediations/actions">
    <img alt="Build Status" src="https://github.com/FluXpert/gma_all_mediations/workflows/build/badge.svg">
  </a> -->
  <!-- <a href="https://github.com/FluXpert/gma_all_mediations/actions">
    <img alt="Code Coverage" src="https://raw.githubusercontent.com/FluXpert/gma_all_mediations/main/coverage_badge.svg">
  </a> -->
  <a href="https://pub.dartlang.org/packages/gma_all_mediations">
    <img alt="Pub Package" src="https://img.shields.io/pub/v/gma_all_mediations.svg">
  </a>
  <a href="https://github.com/FluXpert/gma_all_mediations">
    <img src="https://img.shields.io/github/stars/FluXpert/gma_all_mediations.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on GitHub">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
</p>

---

A zero-config, ultra-robust Flutter package that automatically manages Google AdMob Mediation, native adapter registration, and consent propagation (GDPR/CCPA/ATT) for 13+ top ad networks. Stop editing your `MainActivity` or `AppDelegate` and stop writing manual consent bridges. Install the adapters, initialize the package, and you are done.

> ⚠️ **IMPORTANT ACTION**: For all mediations to work properly and serve ads on production, **you MUST update your `app-ads.txt`** file on your developer website to include the IDs provided by each ad network.

## 🌟 Features

*   **Zero Native Code**: You do not have to touch any Java, Kotlin, Swift, or Objective-C code for 99% of use cases.
*   **Auto-Propagating Consent**: Automatically sends GDPR, CCPA, and UMP consent strings to third-party ad networks natively (via the User Messaging Platform).
*   **App Tracking Transparency (ATT)**: Automatically handles the iOS 14+ ATT prompt and forwards the tracking status directly to the iOS SDKs (like Meta Audience Network).
<!-- *   **Automated Lifecycle Management**: Automatically handles native Activity lifecycle events (`onResume`, `onPause`) required by networks like IronSource. -->
<!-- *   **Reflection-based Architecture**: You only install the adapters you want. The package uses reflection (`Class.forName`, `NSClassFromString`) to prevent compilation errors for omitted networks. -->

---

## 📦 Supported Adapters

These are the currently maintained and actively supported mediation adapters.

| Ad Network | Package Dependency | Action Required? | Consent Strategy |
| :--- | :--- | :--- | :--- |
| [**AppLovin**](https://developers.google.com/admob/flutter/mediation/applovin) | `gma_mediation_applovin` | ✅ Info.plist flag | Auto-forwarded natively by UMP |
| [**Chartboost**](https://developers.google.com/admob/flutter/mediation/chartboost) | `gma_mediation_chartboost` | ✅ Info.plist flag | Handled natively by UMP + SKAN IDs |
| [**DT Exchange**](https://developers.google.com/admob/flutter/mediation/dt-exchange) | `gma_mediation_dtexchange` | ✅ Info.plist flag | Auto-forwarded natively by UMP |
| [**InMobi**](https://developers.google.com/admob/flutter/mediation/inmobi) | `gma_mediation_inmobi` | ✅ Info.plist flag | Auto-forwarded natively by UMP |
| [**IronSource**](https://developers.google.com/admob/flutter/mediation/ironsource) | `gma_mediation_ironsource` | ✅ Info.plist flag | Exact Boolean setter execution (Dart) |
| [**Liftoff (Vungle)**](https://developers.google.com/admob/flutter/mediation/liftoff-monetize) | `gma_mediation_liftoffmonetize` | ✅ Info.plist flag | Exact Boolean setter execution (Dart) |
| [**Meta (Facebook)**](https://developers.google.com/admob/flutter/mediation/meta) | `gma_mediation_meta` | ✅ Info.plist flag | UMP + Auto-ATT Tracking execution |
| [**Mintegral**](https://developers.google.com/admob/flutter/mediation/mintegral) | `gma_mediation_mintegral` | ✅ Info.plist flag | Auto-forwarded natively by UMP |
| [**Moloco**](https://developers.google.com/admob/flutter/mediation/moloco) | `gma_mediation_moloco` | ❎ None | Auto-forwarded natively by UMP |
| [**myTarget**](https://developers.google.com/admob/flutter/mediation/mytarget) | `gma_mediation_mytarget` | ✅ Info.plist flag | Auto-forwarded natively by UMP |
| [**Pangle**](https://developers.google.com/admob/flutter/mediation/pangle) | `gma_mediation_pangle` | ✅ Info.plist flag | Auto-forwarded natively by UMP |
| [**PubMatic**](https://developers.google.com/admob/flutter/mediation/pubmatic) | `gma_mediation_pubmatic` | ✅ Info.plist flag | Auto-forwarded natively by UMP |
| [**Unity Ads**](https://developers.google.com/admob/flutter/mediation/unity) | `gma_mediation_unity` | ✅ Info.plist flag | Auto-forwarded natively by UMP |

---

## 🚀 Getting Started

### 1. Installation

First, add `gma_all_mediations` along with the mediation packages you plan to use to your `pubspec.yaml`:

```yaml
dependencies:
  gma_all_mediations: any
  google_mobile_ads: ^7.0.0
```

### 2. Initialization

Initialize the package *before* requesting any ads. `GmaAllMediations.instance` acts as your central hub.

<details open>
<summary><b>🔥 Required Code (Minimal Setup)</b></summary>

```dart
import 'package:gma_all_mediations/gma_all_mediations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize and automatically propagate to all installed SDKs!
  await GmaAllMediations.instance.initialize();

  runApp(const MyApp());
}
```

</details>

<details>
<summary><b>⚙️ Optional Code (Advanced Configuration)</b></summary>

```dart
import 'package:gma_all_mediations/gma_all_mediations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure the Mediation Setup
  // (All parameters are optional and have sensible defaults)
  final config = GmaMediationConfig(
    enableATT: true,
    debug: true,
    doNotSell: false,
    // Add custom CCPA/GDPR/UMP logic here if you want to override UMP defaults
  );

  // 2. Initialize and automatically propagate to all installed SDKs!
  await GmaAllMediations.instance.initialize(config: config);

  runApp(const MyApp());
}
```
</details>

---

## ⚙️ Platform Specific Setup

While `gma_all_mediations` requires **no structural bridging code**, some Ad SDKs strictly require specific Maven repositories (Android) or `Info.plist` setup (iOS) from the host app.

### 🤖 Android Setup

> 💡 **Example File:** See our full [example_build_gradle.txt](example/example_build_gradle.txt) for a complete working Android configuration.

#### Maven Repositories (`android/build.gradle` or `settings.gradle`)
If you are using **Chartboost**, **IronSource**, **Mintegral**, **Pangle**, or **PubMatic**, you must add their Maven repositories to your project.
_Note: For modern Flutter apps using `dependencyResolutionManagement`, put this in `settings.gradle` instead._

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        // Chartboost
        maven { url "https://cboost.jfrog.io/artifactory/chartboost-ads/" }
        // IronSource
        maven { url "https://android-sdk.is.com/" }
        // Mintegral
        maven { url "https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea" }
        // Pangle
        maven { url "https://artifact.bytedance.com/repository/pangle/" }
        // PubMatic
        maven { url "https://repo.pubmatic.com/artifactory/public-repos" }
    }
}
```

#### Lint Crashes (`android/build.gradle`)
> **Important:** To prevent `NullSafeMutableLiveData` lint crashes during Android builds, add this to the `subprojects` block:
```groovy
subprojects {
    afterEvaluate { project ->
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            android {
                lint { disable "NullSafeMutableLiveData" }
            }
        }
    }
}
```

### 🍎 iOS Setup (`ios/Runner/Info.plist`)

> 💡 **Example File:** See our full [example_info_plist.txt](example/example_info_plist.txt) for a complete working iOS configuration including all SKAdNetwork IDs.

#### App Tracking Transparency (ATT)
To accurately track attribution context (Meta, Liftoff, etc.), provide your tracking usage prompt inside `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

#### Meta Audience Network Tracking Flag
If using Meta, you **must** supply this flag to unlock network attribution tracking natively:

```xml
<key>FacebookAdvertiserTrackingEnabled</key>
<true/>
```

#### SKAdNetwork IDs
Almost every adapter on iOS relies on `SKAdNetworkItems` for view/click conversions mapping.
> Rather than bloating your `Info.plist` with thousands of lines, always retrieve the **latest** SKAdNetwork XMLs supplied directly by the ad networks you configure. Add them sequentially into the `<key>SKAdNetworkItems</key>` array tag.

* [AppLovin SKAdNetwork IDs](https://skadnetwork-ids.applovin.com/v1/skadnetworkids.xml)
* [Chartboost SKAdNetwork IDs](https://docs.chartboost.com/en/monetization/integrate/ios/upgrading-the-sdk/#enable-skadnetwork)
* [DT Exchange SKAdNetwork IDs](https://docs.digitalturbine.com/dt-fairbid/fairbid-sdk/sdk-reference/skadnetwork-id-auto-updater)
* [InMobi SKAdNetwork IDs](https://support.inmobi.com/monetize/ios-guidelines/preparing-for-ios-14) - [Info.plist](https://www.inmobi.com/skadnetworkids.xml)
* [IronSource SKAdNetwork IDs](https://developers.ironsrc.com/ironsource-mobile/ios/ios-14-network-support/)
* [Liftoff Monetize SKAdNetwork IDs](https://support.vungle.com/hc/en-us/articles/360002925791-Integrate-Vungle-SDK-for-iOS#h_01GWQTCFD182A6NRBT9PZ96FXY) - [Info.plist](https://vungle-static-assets.s3.amazonaws.com/dashboard/admin/prod/skadnetworkids.xml)
* [Meta SKAdNetwork IDs](https://developers.facebook.com/docs/setting-up/platform-setup/ios/SKAdNetwork)
* [Mintegral SKAdNetwork IDs](https://dev.mintegral.com/doc/index.html?file=sdk-m_sdk-ios&lang=en)
* [myTarget SKAdNetwork IDs](https://target.my.com/help/partners/mob/ios14integration/en)
* [Pangle SKAdNetwork IDs](https://pangleglobal.com/integration/ios14-readiness)
* [PubMatic SKAdNetwork IDs](https://help.pubmatic.com/openwrap/reference/home-get-started-with-ios-openwrap-sdk-as-primary-ad-sdk#configure-skadnetwork-settings-to-track-conversions)
* [Unity Ads SKAdNetwork IDs](https://docs.unity.com/en-us/grow/ads/ios-sdk/ios14/configure-ad-network-ids)

---

## 🤝 Open Source
We maintain the latest robust reflections and implementations across 13 major mobile mediation networks. Open a GitHub pull request to add support for a new AdMob-certified SDK!
