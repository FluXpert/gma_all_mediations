// Copyright 2024 FluXpert. All rights reserved.
//
// GmaAllMediationsPlugin.swift
//
// Native iOS plugin for the gma_all_mediations Flutter package.
//
// Responsibilities:
//  • Registers the "gma_all_mediations/chartboost_consent" MethodChannel.
//  • Handles the "applyConsent" method to forward GDPR and CCPA signals
//    to the Chartboost SDK via Chartboost.addDataUseConsent().
//
// The Chartboost SDK is brought in transitively through the
// gma_mediation_chartboost pod (GoogleMobileAdsMediationChartboost ~> 9.x).
// No additional pod dependency is required.
//
// Why natively?
// The gma_mediation_chartboost Flutter package exposes an intentionally
// empty Dart class — Google's design delegated consent to native.
// This plugin closes that gap so Flutter consumers have zero AppDelegate work.

import Flutter
import UIKit

@objc protocol DynamicCHBGDPRDataUseConsent: NSObjectProtocol {
  @objc(initWithValue:)
  init(_ value: Int)
}

@objc protocol DynamicCHBCCPADataUseConsent: NSObjectProtocol {
  @objc(initWithValue:)
  init(_ value: Int)
}

@objc protocol DynamicChartboost: NSObjectProtocol {
  @objc(addDataUseConsent:)
  static func addDataUseConsent(_ consent: AnyObject)
}

/// Flutter plugin that bridges Chartboost consent from Dart to the
/// Chartboost iOS SDK.
///
/// Registered automatically via the Flutter plugin system. Consumers do
/// **not** need to add anything to their `AppDelegate`.
public class GmaAllMediationsPlugin: NSObject, FlutterPlugin {
  // ── FlutterPlugin registration ──────────────────────────────────────────

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = GmaAllMediationsPlugin()

    // Chartboost channel
    let chartboostChannel = FlutterMethodChannel(
      name: "gma_all_mediations/chartboost_consent",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: chartboostChannel)

    // Meta (Facebook) channel
    let metaChannel = FlutterMethodChannel(
      name: "gma_all_mediations/meta_consent",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: metaChannel)
  }

  // ── MethodCall handler ──────────────────────────────────────────────────

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "applyConsent":
      applyChartboostConsent(call: call, result: result)
    case "setAdvertiserTrackingEnabled":
      applyMetaTracking(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  /// Applies GDPR and CCPA consent flags to the Chartboost SDK.
  ///
  /// Arguments expected in `call.arguments`:
  /// - `"hasConsent"` (Bool) – `true` → behavioural ads; `false` → non-behavioural.
  /// - `"doNotSell"`  (Bool) – `true` → opt-out of sale (CCPA); `false` → opt-in.
  private func applyChartboostConsent(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard let args = call.arguments as? [String: Any],
          let hasConsent = args["hasConsent"] as? Bool,
          let doNotSell = args["doNotSell"] as? Bool
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "applyConsent requires 'hasConsent' (Bool) and 'doNotSell' (Bool).",
          details: nil
        )
      )
      return
    }

    // Safely look up Chartboost classes via runtime reflection.
    // If the app does not link ChartboostSDK, this silently does nothing.
    guard let chartboostClass = NSClassFromString("Chartboost") as? DynamicChartboost.Type,
          let gdprClass = NSClassFromString("CHBGDPRDataUseConsent") as? DynamicCHBGDPRDataUseConsent.Type,
          let ccpaClass = NSClassFromString("CHBCCPADataUseConsent") as? DynamicCHBCCPADataUseConsent.Type
    else {
      result(nil)
      return
    }

    // ── GDPR ──────────────────────────────────────────────────────────────
    // 0 = non-behavioral, 1 = behavioral
    let gdprConsent = gdprClass.init(hasConsent ? 1 : 0)
    chartboostClass.addDataUseConsent(gdprConsent)

    // ── CCPA ──────────────────────────────────────────────────────────────
    // 0 = opt-in sale, 1 = opt-out sale
    let ccpaConsent = ccpaClass.init(doNotSell ? 1 : 0)
    chartboostClass.addDataUseConsent(ccpaConsent)

    result(nil) // Success
  }

  /// Forwards the ATT tracking authorization status to the Meta SDK.
  ///
  /// Arguments expected in `call.arguments`:
  /// - `"trackingEnabled"` (Bool) – `true` → authorized; `false` → not authorized.
  ///
  /// Uses Objective-C runtime reflection so that this plugin does not require
  /// a compile-time dependency on `FBAudienceNetwork`. If the app does not
  /// use the Meta adapter, this silently does nothing.
  private func applyMetaTracking(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard let args = call.arguments as? [String: Any],
          let trackingEnabled = args["trackingEnabled"] as? Bool
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "setAdvertiserTrackingEnabled requires 'trackingEnabled' (Bool).",
          details: nil
        )
      )
      return
    }

    // Safely look up FBAdSettings without importing FBAudienceNetwork.
    if let fbAdSettingsClass: AnyClass = NSClassFromString("FBAdSettings") {
      let selector = NSSelectorFromString("setAdvertiserTrackingEnabled:")
      if fbAdSettingsClass.responds(to: selector),
         let targetClass = fbAdSettingsClass as? NSObjectProtocol {
        targetClass.perform(selector, with: NSNumber(value: trackingEnabled))
      }
    }

    result(nil)
  }
}
