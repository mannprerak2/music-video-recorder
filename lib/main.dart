import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/screens/home_screen.dart';
import 'package:pkmnrec_app/screens/splash_screen.dart';
import 'package:pkmnrec_app/theme.dart';

void main() {
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: myTheme,
      initialRoute: 'splash',
      routes: {
        'splash': (_) => SplashScreen(),
        'home': (_) => HomeScreen(),
      },
    );
  }
}
