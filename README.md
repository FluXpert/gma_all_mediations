# For all mediations, you need to update app-ads.txt

# App Lovin Setup: https://developers.google.com/admob/flutter/mediation/applovin
Android side update is not required.
iOS Side Infoplist.
copy from: https://skadnetwork-ids.applovin.com/v1/skadnetworkids.xml


# Chartboost Setup: https://developers.google.com/admob/flutter/mediation/chartboost

Android side update:
Optional - AndroidManifest.xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />


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
