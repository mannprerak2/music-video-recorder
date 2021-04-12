import 'package:flutter/material.dart';
import 'package:pkmnrec_app/services/shell.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? vdir;
  void init() async {
    await initWorkingShell();
    // Check dependencies.
    checkDependencies().then((value) {
      if (value) {
        Navigator.of(context).popAndPushNamed('home');
      } else {
        setState(() {
          vdir = "Dependencies missing";
        });
      }
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Logo: pkmnrec'),
              if (vdir != null) Text(vdir!),
            ],
          ),
        ),
      ),
    );
  }
}
