// Copyright 2024 FluXpert. All rights reserved.
//
// GmaAllMediationsPlugin.kt
//
// Native Android plugin for the gma_all_mediations Flutter package.
//
// Responsibilities:
//  • Registers the "gma_all_mediations/chartboost_consent" MethodChannel.
//  • Implements ActivityAware to hook into the host Activity's lifecycle and
//    automatically call IronSource.onResume() / IronSource.onPause() via
//    reflection — so the host app's MainActivity never needs to be modified.
//
// Why reflection for IronSource lifecycle?
//  Our package has no compile-time dependency on the IronSource SDK. Using
//  Class.forName at runtime means this code is safe even if the host app
//  does not include gma_mediation_ironsource. If IronSource is absent from
//  the classpath, the calls are silently skipped.

package com.fluxpert.gma_all_mediations

import android.app.Activity
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Flutter plugin that:
 * 1. Handles the Chartboost consent MethodChannel (Android no-op).
 * 2. Implements [ActivityAware] to automatically call
 *    `IronSource.onResume(Activity)` and `IronSource.onPause(Activity)` via
 *    reflection — no host-app `MainActivity` changes are required.
 */
class GmaAllMediationsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private val lifecycleObserver = IronSourceLifecycleObserver()

  // ── FlutterPlugin ─────────────────────────────────────────────────────────

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(
      binding.binaryMessenger,
      "gma_all_mediations/chartboost_consent"
    )
    channel.setMethodCallHandler(this)

    // Register the IronSource lifecycle observer at the Application level.
    // This forwards onResume() / onPause() to the IronSource SDK via
    // reflection without any changes needed in the host app's MainActivity.
    val app = binding.applicationContext as? android.app.Application
    app?.registerActivityLifecycleCallbacks(lifecycleObserver)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    val app = binding.applicationContext as? android.app.Application
    app?.unregisterActivityLifecycleCallbacks(lifecycleObserver)
  }


  // ── MethodCallHandler ──────────────────────────────────────────────────────

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "applyConsent" -> handleApplyConsent(call, result)
      else -> result.notImplemented()
    }
  }

  // ── ActivityAware ──────────────────────────────────────────────────────────
  //
  // Flutter calls these when the host Activity transitions between states.
  // We forward the signals to IronSource via reflection so the host app's
  // MainActivity.kt needs zero changes.

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    // No setup needed at attach time; lifecycle handled via onResume/onPause.
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // Config change (e.g. rotation) — IronSource handles this internally.
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    // Reattached after config change — no action required.
  }

  override fun onDetachedFromActivity() {
    // Activity detached — no action required.
  }

  // ── IronSource lifecycle (called from FlutterActivity via reflection) ──────
  //
  // FlutterActivity is itself an Activity and its lifecycle maps directly to
  // the Android Activity lifecycle. We register a lifecycle observer below
  // via Application.registerActivityLifecycleCallbacks so we don't need a
  // direct reference from ActivityPluginBinding.
  //
  // Alternative: subclass FlutterActivity in MainActivity. But by using the
  // Application-level callback (registered when the plugin attaches to the
  // engine) we avoid any host-app changes entirely.

  /**
   * Forwards the Activity resume event to IronSource via reflection.
   *
   * This is invoked automatically by [IronSourceLifecycleObserver] which is
   * registered when the plugin first attaches to the Flutter engine.
   *
   * @param activity The Activity that has resumed, provided by the Android
   *   lifecycle callback system.
   */
  internal fun notifyResumed(activity: Activity) {
    invokeIronSource("onResume", activity)
  }

  /**
   * Forwards the Activity pause event to IronSource via reflection.
   *
   * @see notifyResumed
   */
  internal fun notifyPaused(activity: Activity) {
    invokeIronSource("onPause", activity)
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /**
   * Handles the Chartboost "applyConsent" MethodChannel call.
   *
   * On Android, the Chartboost adapter reads consent automatically via the
   * Google Mobile Ads RequestConfiguration. No explicit Chartboost SDK call
   * is needed, so this is effectively a no-op that returns success.
   */
  private fun handleApplyConsent(call: MethodCall, result: Result) {
    val hasConsent = call.argument<Boolean>("hasConsent") ?: false
    val doNotSell = call.argument<Boolean>("doNotSell") ?: false
    Log.i(
      TAG,
      "✅  Chartboost — Android adapter registered " +
      "(consent auto-managed). hasConsent=$hasConsent, doNotSell=$doNotSell"
    )
    result.success(null)
  }

  /**
   * Calls a static method on [com.ironsource.mediationsdk.IronSource] via
   * reflection, passing [activity] as the single argument.
   *
   * Falls back silently if IronSource is not on the classpath (i.e. the host
   * app does not include `gma_mediation_ironsource`).
   */
  private fun invokeIronSource(methodName: String, activity: Activity) {
    try {
      val cls = Class.forName("com.ironsource.mediationsdk.IronSource")
      val method = cls.getMethod(methodName, Activity::class.java)
      method.invoke(null, activity)
      Log.d(TAG, "IronSource.$methodName() called automatically via lifecycle hook.")
    } catch (e: ClassNotFoundException) {
      // IronSource not on classpath — gma_mediation_ironsource not included. Safe to skip.
    } catch (e: Exception) {
      Log.w(TAG, "IronSource.$methodName() failed: ${e.message}")
    }
  }

  companion object {
    private const val TAG = "GMA"
  }
}
