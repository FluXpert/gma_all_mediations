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




# Meta Setup: https://developers.google.com/admob/flutter/mediation/meta


If you face issue in Android - add this in android/app/proguard-rules.pro:
-dontwarn com.facebook.infer.annotation.Nullsafe$Mode
-dontwarn com.facebook.infer.annotation.Nullsafe


Info Plist:
https://developers.facebook.com/docs/setting-up/platform-setup/ios/SKAdNetwork

<key>NSUserTrackingUsageDescription</key>
	<string>This identifier will be used to deliver personalized ads to you.</string>
	<key>FacebookAdvertiserTrackingEnabled</key>
	<true/>



# LiftOff Monetize Setup: https://developers.google.com/admob/flutter/mediation/liftoff-monetize

Nothing required on Android side
iOS setup required:
https://support.vungle.com/hc/en-us/articles/360002925791-Integrate-Vungle-SDK-for-iOS#h_01KGGW4G4GK8SB6YF7P9B20DCR

You only need to update Info.Plist: 
Link: https://vungle-static-assets.s3.amazonaws.com/dashboard/admin/prod/skadnetworkids.xml


# Mintegral Setup: https://developers.google.com/admob/flutter/mediation/mintegral

NOthing required on Android.
iOS Info Plist: https://dev.mintegral.com/doc/index.html?file=sdk-m_sdk-ios&lang=en

# Moloco Setup: https://developers.google.com/admob/flutter/mediation/moloco

No Code required on Android or iOS.

# myTarget Setup: https://developers.google.com/admob/flutter/mediation/mytarget

Nothing Required on Android

iOS Info Plist: https://target.vk.ru/help/partners/mob/ios14integration/en

<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>n9x2a789qt.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
  <string>r26jy69rpl.skadnetwork</string>
 </dict>
</array>

# Pangle Setup: https://developers.google.com/admob/flutter/mediation/pangle

Android Setup - (Android only) Add the following repositories to the build.gradle file inside your project's android directory:
  repositories {
      google()
      mavenCentral()
      maven {
          uri("https://artifact.bytedance.com/repository/pangle/")
      }
  }


iOS Setup: https://pangleglobal.com/integration/ios14-readiness
Only update your INfo.plist

# PubMatic Setup: https://developers.google.com/admob/flutter/mediation/pubmatic
  
(Android only) Add the following repositories to the build.gradle file inside your project's android directory:
  repositories {
      google()
      mavenCentral()
      maven {
          uri("https://repo.pubmatic.com/artifactory/public-repos")
      }
  }



iOS info plist update: https://help.pubmatic.com/openwrap/reference/home-get-started-with-ios-openwrap-sdk-as-primary-ad-sdk#configure-skadnetwork-settings-to-track-conversions
Only update info plist

