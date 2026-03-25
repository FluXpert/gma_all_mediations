# For all mediations, you need to update app-ads.txt

# App Lovin Setup: https://developers.google.com/admob/flutter/mediation/applovin
Android side update is not required.
iOS Side Infoplist.
copy from: https://skadnetwork-ids.applovin.com/v1/skadnetworkids.xml





# Chartboost Setup: https://developers.google.com/admob/flutter/mediation/chartboost

Android side update:

android/build.gradle — add Chartboost maven repo inside `repositories {}`:
```groovy
repositories {
    google()
    mavenCentral()
    maven {
        url "https://cboost.jfrog.io/artifactory/chartboost-ads/"
    }
}
```

android/build.gradle — add lint workaround inside `subprojects {}`:
```groovy
subprojects {
    afterEvaluate { project ->
        if (project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")) {
            // Kotlin Analysis API binary incompatibility with this lint detector crashes
            // all subproject lint tasks. Disabling it globally is the documented workaround.
            android {
                lint {
                    disable "NullSafeMutableLiveData"
                }
            }
        }
    }
}
```

Optional - AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```


iOS Side info plist. (add dicts in SKAdNetworkItems if you've it already)

<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>f38h382jlk.skadnetwork</string>
    </dict>
</array>







# DT Exchange Setup: https://developers.google.com/admob/flutter/mediation/dt-exchange
Check from setup website to check if any extra setup is required in android/ios.

# InMobi Setup: https://developers.google.com/admob/flutter/mediation/inmobi
Android side: Nothing required.

## iOS 14+ Checklist (https://support.inmobi.com/monetize/sdk-documentation/ios-guidelines/preparing-for-ios-14)

A. Latest SDK — keep `gma_mediation_inmobi` up-to-date in pubspec.yaml. ✅ Auto
B. SKAdNetwork attribution — handled automatically by the adapter once SKAN IDs are in Info.plist. ✅ Auto
C. SKAdNetwork IDs in Info.plist — ⚠️ MANUAL: copy from https://www.inmobi.com/skadnetworkids.xml into Info.plist
D. ATT prompt — ✅ Auto-handled by this package (GmaMediationConfig.enableATT = true)
E. iOS 14 demand guide — informational only, no code action needed.


# IronSource (LevelPlay) Setup: https://developers.google.com/admob/flutter/mediation/ironsource
GDPR/CCPA consent: ✅ Auto-handled by this package (setConsent + setDoNotSell).
ProGuard rules: ✅ Auto-applied via consumerProguardFiles (no proguard-user.txt edits needed).
Activity lifecycle (onResume/onPause): ✅ Auto-handled by IronSourceLifecycleObserver (no MainActivity changes needed).

## Android — Only 1 manual step

### Maven repositories ⚠️ MANUAL — add to android/settings.gradle
```groovy
dependencyResolutionManagement {
  repositories {
    // ... existing repos ...
    maven { url = uri("https://android-sdk.is.com/") }
    maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
  }
}
```
Note: Must be in settings.gradle (dependencyResolutionManagement), NOT build.gradle allprojects.
Modern Flutter Android projects ignore plugin-declared maven repos at the host level.

iOS Plist update:
https://developers.is.com/ironsource-mobile/ios/ios-14-network-support/

Infoplist update (check from link for latest one)
<key>SKAdNetworkItems</key>
<array>
   <dict>
      <key>SKAdNetworkIdentifier</key>
      <string>su67r6k2v3.skadnetwork</string>
   </dict>
</array>




# Meta Setup: 


If you face issue in Android - add this in android/app/proguard-rules.pro:
-dontwarn com.facebook.infer.annotation.Nullsafe$Mode
-dontwarn com.facebook.infer.annotation.Nullsafe


