/// GMA All Mediations
///
/// A Flutter package that simplifies the integration of Google Mobile Ads (GMA)
/// mediation adapters with proper GDPR / CCPA consent propagation, iOS App
/// Tracking Transparency (ATT) handling, and AdMob SDK initialisation — all
/// in a single [GmaAllMediations.initialize] call.
///
/// ### Supported adapters (enable in mediation_manager.dart)
/// * ✅ AppLovin MAX           – `gma_mediation_applovin`
/// * 🔜 Unity Ads             – `gma_mediation_unity`
/// * 🔜 IronSource (LevelPlay)– `gma_mediation_ironsource`
/// * 🔜 Liftoff Monetize      – `gma_mediation_liftoffmonetize`
/// * 🔜 Meta Audience Network – `gma_mediation_meta`
/// * 🔜 InMobi               – `gma_mediation_inmobi`
/// * 🔜 Mintegral            – `gma_mediation_mintegral`
///
/// ### Quick start
/// ```dart
/// // main.dart
/// import 'package:gma_all_mediations/gma_all_mediations.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await GmaAllMediations.instance.initialize(
///     config: GmaMediationConfig(
///       debug: false,            // disable logs in production
///       enableATT: true,         // request iOS ATT for higher eCPMs
///       forceMediationConsent: false,
///       doNotSell: false,
///     ),
///   );
///
///   runApp(const MyApp());
/// }
/// ```
library;

export 'src/config.dart';
export 'src/initializer.dart';
