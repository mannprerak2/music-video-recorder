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
