import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:pkmnrec_app/services/shell.dart';

import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SidePanelState { none, loading, ready }

class SidePanel extends StatefulWidget {
  @override
  _SidePanelState createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  var state = SidePanelState.none;
  final _textFieldController = TextEditingController(text: '');

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
    projects.sort();
    context.read(currentProjectProvider).state = '';
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
        return Consumer(
          builder: (_, watch, __) {
            final recorderState = watch(recorderStateProvider).state;
            final deviceName = watch(currentDeviceProvider).state;

            return AbsorbPointer(
              absorbing: recorderState == RecorderState.recording,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    deviceName.isEmpty
                        ? ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.red)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Connect Device',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            onPressed: () =>
                                _displayDeviceSelectDialog(context),
                          )
                        : TextButton(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '$deviceName',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            onPressed: () =>
                                _displayDeviceSelectDialog(context),
                          ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _displayProjectCreationDialog,
                        child: Text("  New Project  "),
                      ),
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
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(projects[i]),
                                      IconButton(
                                        iconSize: 12,
                                        icon: Icon(Icons.edit),
                                        color: Colors.grey,
                                        onPressed: () {
                                          _displayProjectEditDialog(
                                              projects[i]);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
    }
  }

  Future<void> _displayProjectCreationDialog() async {
    _textFieldController.text = '';
    return showDialog(
        context: materialAppGlobalKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: Text('Project Name'),
            content: TextField(
              controller: _textFieldController,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  final d = Directory(p.join(
                      mainDirectory.absolute.path, _textFieldController.text));
                  if (await d.exists()) {
                    _textFieldController.text += '(2)';
                  } else {
                    await d.create();
                    _loadProjects();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayProjectEditDialog(String name) async {
    _textFieldController.text = name;
    return showDialog(
        context: materialAppGlobalKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: Text('Project Name'),
            content: TextField(
              controller: _textFieldController,
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Delete'),
                onPressed: () async {
                  final d =
                      Directory(p.join(mainDirectory.absolute.path, name));
                  if (await d.exists()) {
                    await d.delete(recursive: true);
                    _loadProjects();
                    Navigator.of(context).pop();
                  }
                },
              ),
              TextButton(
                child: Text('Rename'),
                onPressed: () async {
                  final nd = Directory(p.join(
                      mainDirectory.absolute.path, _textFieldController.text));
                  final d =
                      Directory(p.join(mainDirectory.absolute.path, name));
                  if (await nd.exists()) {
                    _textFieldController.text += '(2)';
                  } else if (await d.exists()) {
                    await d.rename(nd.absolute.path);
                    _loadProjects();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayDeviceSelectDialog(BuildContext context) async {
    List<String> devices = [];
    try {
      devices = await getDevices();
    } catch (e) {
      return showDialog(
          context: materialAppGlobalKey.currentContext!,
          builder: (_) => AlertDialog(
                content: Text(e.toString()),
              ));
    }
    context.read(currentDeviceProvider).state = '';

    return showDialog(
        context: materialAppGlobalKey.currentContext!,
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
