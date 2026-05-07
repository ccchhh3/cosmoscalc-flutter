import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'engine/calculator_engine.dart';
import 'theme/theme.dart';
import 'views/content_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // window_manager only on Windows — macOS uses native window management
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.setSize(
        const Size(CosmosTheme.windowDefW, CosmosTheme.windowDefH));
    await windowManager.setMinimumSize(
        const Size(CosmosTheme.windowMinW, CosmosTheme.windowMinH));
    await windowManager.setTitle('CosmosCalc');
  }

  final engine = CalculatorEngine();
  await engine.loadHistory();

  runApp(
    ChangeNotifierProvider.value(
      value: engine,
      child: const CosmosCalcApp(),
    ),
  );
}

class CosmosCalcApp extends StatelessWidget {
  const CosmosCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CosmosCalc',
      debugShowCheckedModeBanner: false,
      theme: CosmosTheme.materialTheme,
      home: const ContentView(),
    );
  }
}
