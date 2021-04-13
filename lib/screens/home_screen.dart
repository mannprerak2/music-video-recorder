import 'package:flutter/material.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/widgets/side_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: SidePanel(),
          ),
          Expanded(
            child: WorkArea(),
          ),
        ],
      ),
    );
  }
}

class WorkArea extends StatefulWidget {
  const WorkArea({
    Key? key,
  }) : super(key: key);

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  var projectShell = ProjectShell(rootShell);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, watch, __) {
      final projectName = watch(currentProjectProvider).state;
      final deviceName = watch(currentDeviceProvider).state;

      if (projectName.isEmpty) {
        return Center(
          child: Text('No Project Selected.'),
        );
      }

      projectShell = ProjectShell.fromName(projectName);

      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              style: TextStyle(fontSize: 50),
            ),
            Text('Current Device: ' + deviceName),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(projectName),
                    TextButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Connect Device'),
                      ),
                      onPressed: () async {},
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                    ),
                    TextButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Start Cam'),
                      ),
                      onPressed: () async {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
