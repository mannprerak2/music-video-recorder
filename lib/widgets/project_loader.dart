import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:path/path.dart' as p;
import 'package:pkmnrec_app/widgets/make_project.dart';

enum ProjectLoaderState { none, loading, empty, complete }

class ProjectLoader extends StatefulWidget {
  final ProjectShell projectShell;

  ProjectLoader(this.projectShell);

  @override
  _ProjectLoaderState createState() => _ProjectLoaderState();
}

class _ProjectLoaderState extends State<ProjectLoader> {
  var state = ProjectLoaderState.loading;
  var lastProjectName = '';

  var projectFiles = <FileSystemEntity>[];

  void loadProject() async {
    state = ProjectLoaderState.loading;

    projectFiles = await widget.projectShell.getProjectFiles();
    if (projectFiles.isEmpty) {
      setState(() {
        state = ProjectLoaderState.empty;
      });
    } else {
      setState(() {
        state = ProjectLoaderState.complete;
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
        case ProjectLoaderState.none:
          return Container();
        case ProjectLoaderState.loading:
          return Center(child: CircularProgressIndicator());
        case ProjectLoaderState.empty:
          return MakeProject(widget.projectShell);
        case ProjectLoaderState.complete:
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
    });
  }
}
