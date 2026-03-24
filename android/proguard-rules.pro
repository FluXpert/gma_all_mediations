# IronSource (LevelPlay) — Consumer ProGuard Rules
#
# These rules are applied automatically to any app that depends on
# gma_all_mediations. No manual proguard-user.txt edits are required.
#
# Source: https://developers.ironsrc.com/ironsource-mobile/android/android-sdk-integration-guide/#step-4

# Keep all IronSource / LevelPlay classes
-keep class com.ironsource.** { *; }
-keep interface com.ironsource.** { *; }
-dontwarn com.ironsource.**

# Keep LevelPlay adapters loaded via reflection
-keep class com.unity3d.mediation.** { *; }
-dontwarn com.unity3d.mediation.**

# Keep Kotlin coroutine infrastructure referenced by IS SDK
-keepclassmembernames class kotlinx.** { volatile <fields>; }

# Keep Javascript interface annotations used by IronSource webview ads
-keepattributes JavascriptInterface

# Google Mobile Ads (required for mediation bridge)
-keep public class com.google.android.gms.ads.** { public *; }
