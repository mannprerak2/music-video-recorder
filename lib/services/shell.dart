import 'package:process_run/shell.dart' as shell;
import 'dart:io';
import 'package:path/path.dart' as p;

const ctrl_c = 3;

late shell.Shell rootShell;

final mainDirectory = Directory(p.join(shell.userHomePath, 'pkmn_recordings'));

Future<void> initWorkingShell() async {
  if (!(await mainDirectory.exists())) {
    await mainDirectory.create();
  }

  rootShell = shell.Shell(workingDirectory: mainDirectory.absolute.path);
  await rootShell.run('adb start-server');
}

Future<bool> checkDependencies() async {
  const deps = ['rec', 'adb', 'ffmpeg'];
  for (final s in deps) {
    if (await shell.which(s) == null) {
      return false;
    }
  }

  return true;
}

class ProjectShell {
  final shell.Shell _shell;
  final Directory _dir;
  String lastError = '';

  ProjectShell(this._shell) : _dir = Directory.current;
  ProjectShell.fromName(String projectName)
      : _shell = shell.Shell(
            workingDirectory: p.join(mainDirectory.absolute.path, projectName)),
        _dir = Directory(p.join(mainDirectory.absolute.path, projectName));

  Future<List<String>> getDevices() async {
    final r = (await _shell.run('adb devices'))[0].stdout as String;
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
    _shell.run('open ${file.absolute.path}');
  }

  Future<bool> startCamera(String device) async {
    try {
      // TODO: fix this.

      // return (await _shell.run(
      //             'adb -s $device shell "am start -a android.media.action.VIDEO_CAPTURE"'))[0]
      //         .exitCode ==
      //     0;

      return (await _shell.run(
                  'adb -s $device shell "am start -n com.oneplus.camera/.OPCameraActivity -a com.oneplus.camera.action.LAUNCH_IN_VIDEO" -W'))[0]
              .exitCode ==
          0;
    } catch (e) {
      lastError = (e as shell.ShellException).message;
      return false;
    }
  }

  Future<void> _toggleCam(String device) async {
    await _shell.run('adb -s $device shell "input keyevent 25"');
  }

  Future<bool> startRecording(String device) async {
    try {
      // Toggle Cam
      await _toggleCam(device);

      curProcess = await Process.start('rec', ['audio.mp3']);
      print('started rec: $curProcess');
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
