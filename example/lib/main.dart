import 'package:flutter/material.dart';
import 'package:gma_all_mediations/gma_all_mediations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize the mediation suite.
  // This automatically handles UMP consent forms, ATT prompts (iOS),
  // and starts the AdMob SDK with all mediation adapters.
  await GmaAllMediations.instance.initialize(
    config: GmaMediationConfig(debug: true, enableATT: true),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('GMA All Mediations Example')),
        body: const Center(
          child: Text(
            'Mediation Initialized!\nCheck logs for adapter status.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
