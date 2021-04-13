import 'package:process_run/shell.dart' as shell;
import 'dart:io';
import 'package:path/path.dart' as p;

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
  ProjectShell(this._shell);
  ProjectShell.fromName(String projectName)
      : _shell = shell.Shell(
            workingDirectory: p.join(mainDirectory.absolute.path, projectName));

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
}
