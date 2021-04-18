import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart' as mui;
import 'package:pkmnrec_app/providers.dart';
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
                if (watch(recorderStateProvider).state == RecorderState.ready)
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
            child: ProjectLoader(),
          ),
        ],
      ),
    );
  }
}
