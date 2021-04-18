import 'package:macos_ui/macos_ui.dart' as mui;
import 'package:flutter/material.dart';
import 'package:pkmnrec_app/services/audio_permission.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:process_run/shell.dart' as shell;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? vdir;
  void init() async {
    if (!await getAudioPermission()) {
      setState(() async {
        vdir = 'Audio Permission Missing.';
      });
      return;
    }
    // Check dependencies.
    if (await checkDependencies()) {
      await initWorkingShell();
      Navigator.of(context).popAndPushNamed('home');
    } else {
      setState(() async {
        vdir = '''Dependencies missing, Env: $myEnv
        adb: ${shell.whichSync('adb')}
        rec: ${shell.whichSync('rec')}
        ffmpeg: ${shell.whichSync('ffmpeg')}
        ''';
      });
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return mui.Scaffold(
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
