import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart' as mui;
import 'package:pkmnrec_app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/services/shell.dart';
import 'package:pkmnrec_app/widgets/project_loader.dart';
import 'package:pkmnrec_app/widgets/side_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return mui.Scaffold(
      resizeBoundary: 170,
      sidebar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SidePanel(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WorkArea(),
      ),
    );
  }
}

class WorkArea extends ConsumerWidget {
  @override
  Widget build(context, watch) {
    final projectName = watch(currentProjectProvider).state;

    final recorderState = watch(recorderStateProvider).state;
    final projectShell = watch(projectShellProvider).state;
    final device = watch(currentDeviceProvider).state;

    if (projectName.isEmpty) {
      return Center(
        child: Text('No Project Selected.'),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                projectName,
                style: TextStyle(fontSize: 50),
              ),
              AbsorbPointer(
                absorbing: recorderState == RecorderState.recording,
                child: OutlinedButton(
                  onPressed: () {
                    _showQuickActionsDialog(projectShell, device);
                  },
                  child: Icon(
                    Icons.settings,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: ProjectLoader(),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsDialog(ProjectShell projectShell, String device) async {
    return showDialog(
        context: materialAppGlobalKey.currentContext!,
        builder: (context) {
          return SimpleDialog(
            title: Text('Quick Actions'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  child: Text('Reset Camera State'),
                  onPressed: () {
                    context.read(recorderStateProvider).state =
                        RecorderState.none;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  child: Text(
                    'Delete from phone\n${projectShell.lastVideo}',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    if (projectShell.lastVideo != null && device.isNotEmpty) {
                      if (await projectShell.deleteVideoFromDevice(device)) {
                        return showDialog(
                            context: materialAppGlobalKey.currentContext!,
                            builder: (_) => AlertDialog(
                                  content: Text('Deleted Successfully.'),
                                ));
                      } else {
                        return showDialog(
                            context: materialAppGlobalKey.currentContext!,
                            builder: (_) => AlertDialog(
                                  content: Text(
                                      'Unable to delete file: ${projectShell.lastError}'),
                                ));
                      }
                    }
                  },
                ),
              ),
            ],
          );
        });
  }
}
