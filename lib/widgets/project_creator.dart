import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/providers.dart';
import 'package:macos_ui/macos_ui.dart' as mui;
import 'package:pkmnrec_app/services/shell.dart';

class ProjectCreator extends ConsumerWidget {
  ProjectCreator();

  Future<bool> processProject(
      ProjectShell _shell, String device, BuildContext context) async {
    context.read(processingStateProvider).state = 'Pulling video from phone.';
    if (!await _shell.pullVideoFromDevice(device)) {
      context.read(processingStateProvider).state =
          'Error pulling video from device';
      return false;
    }
    context.read(processingStateProvider).state = 'Merging audio and video.';
    if (!await _shell.mergeAudioVideo()) {
      context.read(processingStateProvider).state =
          'Error merging audio and video.';
      return false;
    }

    // Reset to show completed project screen.
    String curProj = context.read(currentProjectProvider).state;
    context.read(currentProjectProvider).state = '';
    context.read(currentProjectProvider).state = curProj;

    return true;
  }

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
                return showDialog(
                    context: materialAppGlobalKey.currentContext!,
                    builder: (_) => AlertDialog(
                          content: Text(
                              'Unable to start camera: ${_shell.lastError}'),
                        ));
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
                      return showDialog(
                          context: materialAppGlobalKey.currentContext!,
                          builder: (_) => AlertDialog(
                                content: Text(
                                    'Unable to start recording: ${_shell.lastError}'),
                              ));
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
                      if (!await processProject(_shell, device, context)) {
                        return showDialog(
                            context: materialAppGlobalKey.currentContext!,
                            builder: (_) => AlertDialog(
                                  content: Text(
                                      'Unable to process project: ${_shell.lastError}'),
                                ));
                      }
                    } else {
                      return showDialog(
                          context: materialAppGlobalKey.currentContext!,
                          builder: (_) => AlertDialog(
                                content: Text(
                                    'Unable to stop recording: ${_shell.lastError}'),
                              ));
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
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              mui.ProgressCircle(),
              Consumer(builder: (_, watch, __) {
                final ps = watch(processingStateProvider).state;
                return Text(ps);
              }),
            ],
          ),
        );
    }
  }
}
