import 'package:process_run/shell.dart' as shell;
import 'dart:io';
import 'package:path/path.dart' as p;

const deps = ['rec', 'adb', 'ffmpeg'];

const myEnv = {'PATH': '/usr/local/bin'};
shell.Shell rootShell = shell.Shell(environment: myEnv);

Future<bool> checkDependencies() async {
  // Get path from user shell.

  for (final s in deps) {
    if (await shell.which(s, environment: myEnv) == null) {
      return false;
    }
  }

  return true;
}

final mainDirectory = Directory(p.join(shell.userHomePath, 'pkmn_recordings'));

Future<void> initWorkingShell() async {
  if (!(await mainDirectory.exists())) {
    await mainDirectory.create();
  }

  rootShell = rootShell.clone(workingDirectory: mainDirectory.absolute.path);
  await rootShell.run('adb start-server');
}

Future<List<String>> getDevices() async {
  final r = (await shell.run('adb devices'))[0].stdout as String;
  final lines = r.split('\n');
  List<String> devices = [];
  for (var i = 1; i < lines.length; i++) {
    List<String> deviceEntry = lines[i].split(RegExp(r'\s+'));
    if (deviceEntry.length > 1 && deviceEntry[1] == 'device') {
      devices.add(deviceEntry[0]);
    }
  }
  return devices;
}

class ProjectShell {
  final shell.Shell mshell;
  final Directory _dir;
  String lastError = '';

  ProjectShell(this.mshell) : _dir = Directory.current;
  ProjectShell.fromName(String projectName)
      : mshell = rootShell.clone(
            workingDirectory: p.join(mainDirectory.absolute.path, projectName)),
        _dir = Directory(p.join(mainDirectory.absolute.path, projectName));

  bool _isValidProjectFile(String path) {
    const exts = {'.mp3', '.mp4'};
    return exts.contains(p.extension(path));
  }

  Future<List<FileSystemEntity>> getProjectFiles() async {
    return (_dir.list())
        .where((element) => _isValidProjectFile(element.path))
        .toList();
  }

  void openFile(FileSystemEntity file) {
    mshell.run('open "${file.absolute.path}"');
  }

  Future<bool> startCamera(String device) async {
    try {
      // TODO: fix this.

      // return (await _shell.run(
      //             'adb -s $device shell "am start -a android.media.action.VIDEO_CAPTURE"'))[0]
      //         .exitCode ==
      //     0;

      return (await mshell.run(
                  'adb -s $device shell "am start -n com.oneplus.camera/.OPCameraActivity -a com.oneplus.camera.action.LAUNCH_IN_VIDEO" -W'))[0]
              .exitCode ==
          0;
    } catch (e) {
      lastError = (e as shell.ShellException).message;
      return false;
    }
  }

  Future<void> _toggleCam(String device) async {
    await mshell.run('adb -s $device shell "input keyevent 25"');
  }

  Future<bool> startRecording(String device) async {
    try {
      // Toggle Cam
      curProcess = await Process.start('rec', ['audio.mp3'],
          workingDirectory: mshell.path);
      await _toggleCam(device);
      print('started rec');
    } catch (e) {
      lastError = (e as shell.ShellException).message;
      return false;
    }
    return true;
  }

  Process? curProcess;

  Future<bool> stopRecording(String device) async {
    await _toggleCam(device);
    Process p = curProcess!;
    return p.kill(ProcessSignal.sigterm);
  }
}
