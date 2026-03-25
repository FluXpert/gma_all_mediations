# For all mediations, you need to update app-ads.txt
# google_mobile_ads: ^7.0.0

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

# Unity Ads Setup: https://developers.google.com/admob/flutter/mediation/unity

No update required on Android Side.

iOS Info plist Update: https://docs.unity.com/ads/en-us/manual/ConfiguringAdNetworkIDs
Only update info plist




# Overall build.gradle
Please update it as per your project's requirement.
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea"
        }
        maven{
            url "https://android-sdk.is.com/"
        }
        maven {
            url "https://cboost.jfrog.io/artifactory/chartboost-ads/"
        }
        maven {
            url "https://artifact.bytedance.com/repository/pangle/"
        }
        maven {
            url "https://repo.pubmatic.com/artifactory/public-repos"
        }
    }
    subprojects {
        afterEvaluate { project ->
            if (project.hasProperty('android')) {
                project.android {
                    if (namespace == null) {
                        namespace project.group
                    }
                }
            }
        }
    }
}

rootProject.buildDir = '../build'
subprojects {
    afterEvaluate { project ->
        if (project.plugins.hasPlugin("com.android.application") ||
                project.plugins.hasPlugin("com.android.library")) {
            project.android {
                compileSdkVersion 36
                buildToolsVersion "36.0.0"
                // Kotlin Analysis API binary incompatibility with this lint detector crashes
                // all subproject lint tasks. Disabling it globally is the documented workaround.
                lint {
                    disable "NullSafeMutableLiveData"
                }
            }
        }
        if (project.hasProperty("android")) {
            project.android {
                if (namespace == null) {
                    namespace project.group
                }
            }
        }
        
        // Suppress compiler warnings globally for all subprojects
        project.tasks.withType(JavaCompile).configureEach {
            options.compilerArgs += ['-Xlint:-deprecation', '-Xlint:-unchecked', '-Xlint:-options']
            options.deprecation = false
            options.warnings = false
        }
    }
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
//    project.evaluationDependsOn(':app')
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}



# overall Info.plist

Your SKAdNetworkItems can vary so please use links to add yours.

<key>AdNetworkIdentifiers</key>
	<array>
		<string>thzdn4h5nc.adattributionkit</string>
		<string>raa6f494kr.adattributionkit</string>
		<string>6lz2ygh3q6.adattributionkit</string>
		<string>m2jqnlggk3.adattributionkit</string>
		<string>pg7ctvrt6f.adattributionkit</string>
		<string>77y3x8wds4.adattributionkit</string>
	</array>

	<key>FacebookAdvertiserTrackingEnabled</key>
	<true/>


	<key>NSUserTrackingUsageDescription</key>
	<string>This identifier will be used to deliver personalized ads to you.</string>
	<key>SKAdNetworkItems</key>
	<array>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v9wttpbfk9.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>n38lu8286q.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>kbd757ywx3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>pwa73g5rt2.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5f5u5tfb26.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>44jx6755aq.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>p78axxw29g.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>x44k69ngh6.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>tl55sbb4fm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>a2p9lx4jpn.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>g6gcrrvk4p.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>238da6jt44.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5lm9lj6jb7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4pfyvq9l8r.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>32z4fx6l9h.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5l3tpt7t6e.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v72qych5uu.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3qy4746246.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mlmmfzh3r3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>uw77j35x4d.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>2fnua5tdw4.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9t245vhmpl.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cstr6suwn9.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>vhf287vqwu.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v79kvwwj4g.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ydx93a7ass.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>f7s53z58qe.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mp6xlyr22a.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ppxm28t8ap.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5a6flpkh64.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4468km3ulz.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9nlqeag3gk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mqn7fxpca7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>klf5c3l5u5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>zmvfpc5aq8.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5tjdwbrq8w.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>wg4vff78zm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3sh42y64q3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>glqzh8vgby.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>wzmmz9fp6w.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>prcb7njmu6.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>zq492l623r.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>feyaarzu9v.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v9wttpbfk9.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4w7y6s5ca2.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>xga6mpmplv.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>m8dbw4sv7c.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>e5fvkxwrpn.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6yxyv74ff7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>hs6bdukanm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4dzt52r2t5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>8s468mfl3y.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9rd848q2bz.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>f38h382jlk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>c6k4g5qg8m.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mj797d8u6f.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>578prtvx9j.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>488r3q3dtq.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>2u9pt9hc89.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>s39g8k73mm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>97r2b46745.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>k6y4y55b64.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>f73kdq92p3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>k674qkevps.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>lr83yxwka7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>yclnxrl5pm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>n9x2a789qt.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>a8cz6cu7e5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>294l99pt4k.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>t38b2kh725.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>av6w8kgt66.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4fzdc2evr5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>424m5254lk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>22mmun2rn5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3rd42ekr43.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>w9q455wk68.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>7ug5zh24hu.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>22mmun2rn5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>238da6jt44.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>24t9a8vw3c.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>24zw6aqk47.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>252b5q8x7y.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>275upjj5gd.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>294l99pt4k.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>2fnua5tdw4.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>2u9pt9hc89.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>32z4fx6l9h.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3l6bd9hu43.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3qcr597p9d.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3qy4746246.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3rd42ekr43.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>3sh42y64q3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>424m5254lk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4468km3ulz.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>44jx6755aq.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>44n7hlldy6.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>47vhws6wlr.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>488r3q3dtq.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4dzt52r2t5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4fzdc2evr5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4mn522wn87.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4pfyvq9l8r.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>4w7y6s5ca2.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>523jb4fst2.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>52fl2v3hgk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>54nzkqm89y.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>578prtvx9j.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5a6flpkh64.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5l3tpt7t6e.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5lm9lj6jb7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>5tjdwbrq8w.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6964rsfnh4.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6g9af3uyq4.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6p4ks3rnbw.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6v7lgmsu45.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6xzpu9s2p8.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>737z793b9f.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>74b6s63p6l.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>79pbpufp6p.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>7fmhfwg9en.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>7rz58n8ntl.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>7ug5zh24hu.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>84993kbrcf.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>89z7zv988g.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>8c4e2ghe7u.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>8m87ys6875.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>8r8llnkz5a.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>8s468mfl3y.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>97r2b46745.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9b89h5y424.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9nlqeag3gk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9rd848q2bz.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9t245vhmpl.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9vvzujtq5s.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>9yg77x724h.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>a2p9lx4jpn.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>a7xqa6mtl2.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>a8cz6cu7e5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>av6w8kgt66.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>b9bk5wbcq9.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>bxvub5ada5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>c3frkrj4fj.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>c6k4g5qg8m.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cg4yq2srnc.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cj5566h2ga.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cp8zw746q7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cs644xg564.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cstr6suwn9.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>dbu4b84rxf.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>dkc879ngq3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>dzg6xy7pwj.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>e5fvkxwrpn.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ecpz2srf59.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>eh6m2bh4zr.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ejvt5qm6ak.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>f38h382jlk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>f73kdq92p3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>f7s53z58qe.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>feyaarzu9v.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>g28c52eehv.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>g2y4y55b64.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>g6gcrrvk4p.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ggvn48r87g.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>glqzh8vgby.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>gta8lk7p23.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>gta9lk7p23.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>hb56zgv37p.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>hdw39hrw9y.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>hs6bdukanm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>k674qkevps.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>kbd757ywx3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>kbmxgpxpgc.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>klf5c3l5u5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>krvm3zuq6h.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>lr83yxwka7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ludvb6z3bs.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>m297p6643m.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>m5mvw97r93.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>m8dbw4sv7c.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mj797d8u6f.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mlmmfzh3r3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mls7yz5dvl.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mp6xlyr22a.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mqn7fxpca7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>mtkv5xtk9e.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>n38lu8286q.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>n66cz3y3bx.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>n6fk4nfna4.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>n9x2a789qt.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>nzq8sh4pbs.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>p78axxw29g.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ppxm28t8ap.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>prcb7njmu6.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>pwa73g5rt2.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>pwdxu55a5a.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>qqp299437r.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>qu637u8glc.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>r45fhb6rf7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>rvh3l7un93.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>rx5hdcabgc.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>s39g8k73mm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>s69wq72ugq.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>su67r6k2v3.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>t38b2kh725.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>tl55sbb4fm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>u679fj5vs4.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>uw77j35x4d.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v4nxqhlyqp.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v72qych5uu.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v79kvwwj4g.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>v9wttpbfk9.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>vcra2ehyfk.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>vhf287vqwu.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>vutu7akeur.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>w9q455wk68.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>wg4vff78zm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>wzmmz9fp6w.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>x44k69ngh6.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>x5l83yy675.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>x8jxxk4ff5.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>x8uqf25wch.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>xga6mpmplv.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>xy9t38ct57.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>y45688jllp.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>y5ghdn5j9k.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>yclnxrl5pm.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ydx93a7ass.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>zmvfpc5aq8.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>zq492l623r.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>apzhy3va96.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>t6d3zquu66.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>qwpu75vrh2.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cwn433xbcr.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ns5j362hk7.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>z959bm4gru.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>fz2k2k5tej.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>bvpn9ufa9b.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6rd35atwn8.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>ln5gz23vtd.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>tmhh9296z4.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>sczv5946wb.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>87u5trcl3r.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>fq6vru337s.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>thzdn4h5nc.adattributionkit</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>raa6f494kr.adattributionkit</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>6lz2ygh3q6.adattributionkit</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>m2jqnlggk3.adattributionkit</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>f2zub97jtl.skadnetwork</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>pg7ctvrt6f.adattributionkit</string>
		</dict>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>77y3x8wds4.adattributionkit</string>
		</dict>
	</array>