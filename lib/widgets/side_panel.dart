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
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _displayProjectCreationDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.add),
                      Text("New Project"),
                    ],
                  ),
                ),
              ),
              projects.isEmpty
                  ? Text("No Projects")
                  : Expanded(
                      child: ListView.separated(
                        itemCount: projects.length,
                        itemBuilder: (_, i) {
                          return TextButton(
                            onPressed: () {
                              context.read(currentProjectProvider).state =
                                  projects[i];
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(projects[i]),
                                IconButton(
                                  iconSize: 12,
                                  icon: Icon(Icons.edit),
                                  color: Colors.grey,
                                  onPressed: () {
                                    _displayProjectEditDialog(projects[i]);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, i) {
                          return Divider();
                        },
                      ),
                    ),
            ],
          ),
        );
    }
  }

  Future<void> _displayProjectCreationDialog() async {
    _textFieldController.text = '';
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Project Name'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Must be unique."),
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
        context: context,
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
}
