import 'dart:io';

import 'package:process_run/shell.dart' as shell;

Future<bool> getDevices() async {
  print('launching');
  Process a = await Process.start('rec', ['audio.mp3']);
  print(a);
  return true;
}

void main() async {
  print(await getDevices());
}
