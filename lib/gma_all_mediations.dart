/// GMA All Mediations
///
/// A Flutter package that simplifies the integration of Google Mobile Ads (GMA)
/// mediation adapters with proper GDPR / CCPA consent propagation, iOS App
/// Tracking Transparency (ATT) handling, and AdMob SDK initialisation — all
/// in a single [GmaAllMediations.initialize] call.
///
/// Supported ad networks: AppLovin, Chartboost, DT Exchange, InMobi, IronSource,
/// Liftoff Monetize, Meta Audience Network, Mintegral, Moloco, myTarget,
/// Pangle, PubMatic, and Unity Ads.
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

export 'src/internal.dart';
