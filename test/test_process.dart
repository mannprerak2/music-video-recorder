import 'package:process_run/shell.dart' as shell;

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

void main() async {
  print(await getDevices());
}
