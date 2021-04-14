import 'package:flutter/material.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/widgets/project_loader.dart';
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
          VerticalDivider(),
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

      projectShell = ProjectShell.fromName(projectName);
      return Consumer(builder: (_, watch, __) {
        final deviceName = watch(currentDeviceProvider).state;
        final recorderState = watch(recorderStateProvider).state;
        if (projectName.isEmpty) {
          return Center(
            child: Text('No Project Selected.'),
          );
        }

        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectName,
                style: TextStyle(fontSize: 50),
              ),
              AbsorbPointer(
                absorbing: recorderState == RecorderState.recording,
                child: Row(
                  children: [
                    deviceName.isEmpty
                        ? ElevatedButton(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('No device connected'),
                            ),
                            onPressed: _displayDeviceSelectDialog,
                          )
                        : TextButton(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Current Device - $deviceName'),
                            ),
                            onPressed: _displayDeviceSelectDialog,
                          ),
                    if (watch(recorderStateProvider).state ==
                        RecorderState.ready)
                      OutlinedButton(
                          onPressed: () {
                            context.read(recorderStateProvider).state =
                                RecorderState.none;
                          },
                          child: Text('Reset Camera State')),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: ProjectLoader(projectShell),
              ),
            ],
          ),
        );
      });
    });
  }

  Future<void> _displayDeviceSelectDialog() async {
    List<String> devices = await projectShell.getDevices();
    context.read(currentDeviceProvider).state = '';

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select a device'),
            content: devices.isEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('No devices found')])
                : SizedBox(
                    width: 300,
                    height: 100,
                    child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (_, i) {
                          return TextButton(
                            onPressed: () {
                              context.read(currentDeviceProvider).state =
                                  devices[i];
                              Navigator.pop(context);
                            },
                            child: Text(devices[i]),
                          );
                        }),
                  ),
          );
        });
  }
}
