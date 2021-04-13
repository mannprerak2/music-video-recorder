import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:path/path.dart' as p;

enum ProjectAreaState { none, loading, empty, complete }

class ProjectArea extends StatefulWidget {
  final ProjectShell projectShell;

  ProjectArea(this.projectShell);

  @override
  _ProjectAreaState createState() => _ProjectAreaState();
}

class _ProjectAreaState extends State<ProjectArea> {
  var state = ProjectAreaState.loading;
  var lastProjectName = '';

  var projectFiles = <FileSystemEntity>[];

  void loadProject() async {
    state = ProjectAreaState.loading;

    projectFiles = await widget.projectShell.getProjectFiles();
    if (projectFiles.isEmpty) {
      setState(() {
        state = ProjectAreaState.empty;
      });
    } else {
      setState(() {
        state = ProjectAreaState.complete;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, watch, __) {
      final projectName = watch(currentProjectProvider).state;
      if (projectName != lastProjectName) {
        // Project was changed, restart.
        loadProject();
        lastProjectName = projectName;
      }

      switch (state) {
        case ProjectAreaState.none:
          return Container();
        case ProjectAreaState.loading:
          return Center(child: CircularProgressIndicator());
        case ProjectAreaState.empty:
          // TODO: Handle this case.
          break;
        case ProjectAreaState.complete:
          return ListView.builder(
              itemCount: projectFiles.length,
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.projectShell.openFile(projectFiles[i]);
                    },
                    icon: p.extension(projectFiles[i].path) == '.mp3'
                        ? Icon(Icons.music_note)
                        : Icon(Icons.video_label),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        p.basename(projectFiles[i].path),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              });
      }
      return Text('unimplemented');
    });
  }
}
