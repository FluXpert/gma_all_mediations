// Copyright 2024 FluXpert. All rights reserved.
//
// GmaAllMediationsPlugin.kt
//
// Native Android plugin for the gma_all_mediations Flutter package.
//
// Handles the "gma_all_mediations/chartboost_consent" MethodChannel.
//
// On Android, the Chartboost mediation adapter reads GDPR / CCPA consent
// signals automatically via the Google Mobile Ads mediation framework.
// No explicit call to Chartboost.setDataUseConsent() is required on this
// platform — the adapter propagates consent through the standard
// RequestConfiguration set on MobileAds.
//
// This plugin therefore acts as a no-op for the "applyConsent" method on
// Android, while still sending a log entry for observability.

package com.fluxpert.gma_all_mediations

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Flutter plugin that registers the Chartboost consent MethodChannel.
 *
 * On Android, Chartboost reads consent automatically via the mediation
 * adapter — no explicit SDK call is needed. The "applyConsent" handler
 * therefore succeeds silently so the Dart layer behaves identically on
 * both platforms.
 */
class GmaAllMediationsPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel

  // ── FlutterPlugin ─────────────────────────────────────────────────────

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(
      binding.binaryMessenger,
      "gma_all_mediations/chartboost_consent"
    )
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // ── MethodCallHandler ─────────────────────────────────────────────────

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "applyConsent" -> handleApplyConsent(call, result)
      else -> result.notImplemented()
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────

  /**
   * Handles the "applyConsent" call from Dart.
   *
   * On Android, the Chartboost adapter inherits consent from the RequestConfiguration
   * already applied to MobileAds by [GmaAllMediations._startMobileAdsSdk()].
   * No additional Chartboost-specific call is required.
   *
   * @param call Contains "hasConsent" (Boolean) and "doNotSell" (Boolean) arguments.
   * @param result Flutter result callback — always succeeds on Android.
   */
  private fun handleApplyConsent(call: MethodCall, result: Result) {
    val hasConsent = call.argument<Boolean>("hasConsent") ?: false
    val doNotSell = call.argument<Boolean>("doNotSell") ?: false

    // Android: Chartboost reads consent via the mediation adapter automatically.
    // The explicit addDataUseConsent() call is an iOS-only requirement.
    Log.i(
      "GMA",
      "✅  Chartboost — Android adapter registered " +
      "(consent auto-managed). hasConsent=$hasConsent, doNotSell=$doNotSell"
    )

    result.success(null)
  }
}
