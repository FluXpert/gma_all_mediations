# GMA All Mediations 🚀

A zero-config, ultra-robust Flutter package that automatically manages Google AdMob Mediation, native adapter registration, and consent propagation (GDPR/CCPA/ATT) for 13+ top ad networks. Stop editing your `MainActivity` or `AppDelegate` and stop writing manual consent bridges. Install the adapters, initialize the package, and you are done.

> ⚠️ **IMPORTANT ACTION**: For all mediations to work properly and serve ads on production, **you MUST update your `app-ads.txt`** file on your developer website to include the IDs provided by each ad network.

## 🌟 Features

*   **Zero Native Code**: You do not have to touch any Java, Kotlin, Swift, or Objective-C code for 99% of use cases.
*   **Auto-Propagating Consent**: Automatically sends GDPR, CCPA, and UMP consent strings to third-party ad networks natively (via the User Messaging Platform).
*   **App Tracking Transparency (ATT)**: Automatically handles the iOS 14+ ATT prompt and forwards the tracking status directly to the iOS SDKs (like Meta Audience Network).
*   **Automated Lifecycle Management**: Automatically handles native Activity lifecycle events (`onResume`, `onPause`) required by networks like IronSource.
*   **Reflection-based Architecture**: You only install the adapters you want. The package uses reflection (`Class.forName`, `NSClassFromString`) to prevent compilation errors for omitted networks.

---

## 📦 Supported Adapters

These are the currently maintained and actively supported mediation adapters.

| Ad Network | Package Dependency | Action Required? | Consent Strategy |
| :--- | :--- | :--- | :--- |
| **AppLovin** | `gma_mediation_applovin` | ❎ None | Auto-forwarded natively by UMP |
| **Chartboost** | `gma_mediation_chartboost` | ✅ Gradle repo | Handled natively by UMP + SKAN IDs |
| **DT Exchange** | `gma_mediation_dtexchange` | ❎ None | Auto-forwarded natively by UMP |
| **InMobi** | `gma_mediation_inmobi` | ❎ None | Auto-forwarded natively by UMP |
| **IronSource** | `gma_mediation_ironsource` | ✅ Gradle repo | Exact Boolean setter execution (Dart) |
| **Liftoff (Vungle)** | `gma_mediation_liftoffmonetize` | ❎ None | Exact Boolean setter execution (Dart) |
| **Meta (Facebook)** | `gma_mediation_meta` | ✅ Info.plist flag | UMP + Auto-ATT Tracking execution |
| **Mintegral** | `gma_mediation_mintegral` | ✅ Gradle repo | Auto-forwarded natively by UMP |
| **Moloco** | `gma_mediation_moloco` | ❎ None | Auto-forwarded natively by UMP |
| **myTarget** | `gma_mediation_mytarget` | ❎ None | Auto-forwarded natively by UMP |
| **Pangle** | `gma_mediation_pangle` | ✅ Gradle repo | Auto-forwarded natively by UMP |
| **PubMatic** | `gma_mediation_pubmatic` | ✅ Gradle repo | Auto-forwarded natively by UMP |
| **Unity Ads** | `gma_mediation_unity` | ❎ None | Auto-forwarded natively by UMP |

---

## 🚀 Getting Started

### 1. Installation

First, add `gma_all_mediations` along with the mediation packages you plan to use to your `pubspec.yaml`:

```yaml
dependencies:
  gma_all_mediations: any
  google_mobile_ads: ^7.0.0
  # Install the specific adapters you want (Optional):
  gma_mediation_applovin: 2.5.2
  gma_mediation_meta: 1.5.1
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
* [Chartboost SKAdNetwork IDs](https://docs.chartboost.com/en/monetization/ios/integration/)
* [InMobi SKAdNetwork IDs](https://www.inmobi.com/skadnetworkids.xml)
* [Meta SKAdNetwork IDs](https://developers.facebook.com/docs/setting-up/platform-setup/ios/SKAdNetwork)
* [Mintegral SKAdNetwork IDs](https://dev.mintegral.com/doc/index.html?file=sdk-m_sdk-ios&lang=en)

---

## 🤝 Open Source
We maintain the latest robust reflections and implementations across 13 major mobile mediation networks. Open a GitHub pull request to add support for a new AdMob-certified SDK!
