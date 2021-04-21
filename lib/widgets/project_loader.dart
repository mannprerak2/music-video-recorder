import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:path/path.dart' as p;
import 'package:pkmnrec_app/widgets/project_creator.dart';

class ProjectLoader extends StatefulWidget {
  ProjectLoader();

  @override
  _ProjectLoaderState createState() => _ProjectLoaderState();
}

class _ProjectLoaderState extends State<ProjectLoader> {
  var projectFiles = <FileSystemEntity>[];

  void loadProject(ProjectShell projectShell) async {
    await Future.value(1); // Prevents error called setstate in build.
    context.read(currentProjectLoaderState).state = ProjectLoaderState.loading;

    projectFiles = await projectShell.getProjectFiles();
    if (projectFiles.isEmpty) {
      context.read(currentProjectLoaderState).state = ProjectLoaderState.empty;
    } else {
      context.read(currentProjectLoaderState).state =
          ProjectLoaderState.complete;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, watch, __) {
      final projectShell = watch(projectShellProvider).state;
      final state = watch(currentProjectLoaderState).state;

      switch (state) {
        case ProjectLoaderState.none:
          loadProject(projectShell);
          return Container();
        case ProjectLoaderState.loading:
          return Center(child: CircularProgressIndicator());
        case ProjectLoaderState.empty:
          return ProjectCreator();
        case ProjectLoaderState.complete:
          return ListView.builder(
              itemCount: projectFiles.length,
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      projectShell.openFile(projectFiles[i]);
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
