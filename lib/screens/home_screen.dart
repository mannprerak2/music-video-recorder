import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

enum SidePanelState { none, loading, ready }

class SidePanel extends StatefulWidget {
  @override
  _SidePanelState createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  var state = SidePanelState.none;

  List<String> projects = [];

  void _loadProjects() async {
    setState(() {
      state = SidePanelState.loading;
    });
    projects.clear();
    (await mainDirectory.list(followLinks: false).toList()).forEach((element) {
      if (element is Directory) {
        projects.add(p.basename(element.path));
      }
    });

    setState(() {
      state = SidePanelState.ready;
    });
  }

  @override
  void initState() {
    _loadProjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case SidePanelState.none:
        return Container();
      case SidePanelState.loading:
        return Center(child: CircularProgressIndicator());
      case SidePanelState.ready:
        return Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text("+ Create Project +"),
            ),
            projects.isEmpty
                ? Text("No Projects")
                : Expanded(
                    child: ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (_, i) {
                        return TextButton(
                          onPressed: () {
                            context.read(currentProjectProvider).state =
                                projects[i];
                          },
                          child: Text(projects[i]),
                        );
                      },
                    ),
                  ),
          ],
        );
    }
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
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, watch, __) {
      final projectName = watch(currentProjectProvider).state;

      return Container(
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
                onPressed: () async {
                  final r =
                      (await rootShell.run('adb devices'))[0].stdout as String;
                  final lines = r.split('\n');

                  if (lines.length > 1) {
                    setState(() {});
                  }
                },
              ),
              // Text('Device ID: $deviceId'),
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
      );
    });
  }
}
