import 'dart:io';

Future<bool> getDevices() async {
  print('launching');
  Process a = await Process.start('rec', ['audio.mp3']);
  print(a);
  return true;
}

void main() async {
  print(await getDevices());
}
