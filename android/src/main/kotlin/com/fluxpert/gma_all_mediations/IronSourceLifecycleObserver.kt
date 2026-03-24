// Copyright 2024 FluXpert. All rights reserved.
//
// IronSourceLifecycleObserver.kt
//
// Registers an Application-level ActivityLifecycleCallback so that
// IronSource.onResume(Activity) and IronSource.onPause(Activity) are called
// automatically whenever any Activity in the host app resumes or pauses.
//
// This completely eliminates the need for the host app to add lifecycle hooks
// in its MainActivity. The observer is registered once when the Flutter
// plugin engine attaches and is self-contained within gma_all_mediations.

package com.fluxpert.gma_all_mediations

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.util.Log

/**
 * Application-level lifecycle observer that forwards Activity
 * resume and pause events to the IronSource SDK via reflection.
 *
 * Registered automatically by [GmaAllMediationsPlugin] — the host app
 * needs zero changes to `MainActivity` or any other Activity.
 *
 * Uses `Class.forName` at runtime so there is no compile-time dependency
 * on the IronSource SDK. If the host app does not include
 * `gma_mediation_ironsource`, the calls are silently skipped.
 */
class IronSourceLifecycleObserver : Application.ActivityLifecycleCallbacks {

  override fun onActivityResumed(activity: Activity) {
    invokeIronSource("onResume", activity)
  }

  override fun onActivityPaused(activity: Activity) {
    invokeIronSource("onPause", activity)
  }

  // ── Unused callbacks ────────────────────────────────────────────────────

  override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
  override fun onActivityStarted(activity: Activity) {}
  override fun onActivityStopped(activity: Activity) {}
  override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
  override fun onActivityDestroyed(activity: Activity) {}

  // ── Reflection helper ───────────────────────────────────────────────────

  /**
   * Calls `IronSource.<methodName>(Activity)` via reflection.
   *
   * Swallows [ClassNotFoundException] silently so apps that don't include the
   * IronSource adapter are not affected.
   */
  private fun invokeIronSource(methodName: String, activity: Activity) {
    try {
      val cls = Class.forName("com.ironsource.mediationsdk.IronSource")
      val method = cls.getMethod(methodName, Activity::class.java)
      method.invoke(null /* static */, activity)
      Log.d(TAG, "IronSource.$methodName() — auto-called via lifecycle hook.")
    } catch (_: ClassNotFoundException) {
      // IronSource not on classpath — gma_mediation_ironsource not included. Safe to skip.
    } catch (e: Exception) {
      Log.w(TAG, "IronSource lifecycle hook ($methodName) failed: ${e.message}")
    }
  }

  companion object {
    private const val TAG = "GMA"
  }
}
