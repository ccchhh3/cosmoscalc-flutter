import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'engine/calculator_engine.dart';
import 'theme/theme.dart';
import 'views/content_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
