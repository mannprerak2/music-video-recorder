import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/providers.dart';

class ProjectCreator extends ConsumerWidget {
  ProjectCreator();

  @override
  Widget build(context, watch) {
    final recorderState = watch(recorderStateProvider).state;
    final device = watch(currentDeviceProvider).state;
    final _shell = watch(projectShellProvider).state;
    switch (recorderState) {
      case RecorderState.none:
        return Center(
          child: ElevatedButton(
            onPressed: () async {
              if (await _shell.startCamera(device)) {
                context.read(recorderStateProvider).state = RecorderState.ready;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Unable to start camera: ${_shell.lastError}')));
              }
            },
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(), minimumSize: Size(150, 150)),
            child: Text(
              'Start\nCamera',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      case RecorderState.ready:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // start recording.
                    if (await _shell.startRecording(device)) {
                      context.read(recorderStateProvider).state =
                          RecorderState.recording;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Unable to start recording: ${_shell.lastError}')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), minimumSize: Size(150, 150)),
                  child: Text(
                    'Record',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      case RecorderState.recording:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // stop recording.
                    if (await _shell.stopRecording(device)) {
                      context.read(recorderStateProvider).state =
                          RecorderState.processing;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), minimumSize: Size(150, 150)),
                  child: Text(
                    'Stop',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      case RecorderState.processing:
        return Text('unimplemented');
    }
  }
}
