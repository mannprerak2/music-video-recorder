import 'package:process_run/shell.dart' as shell;
import 'dart:io';
import 'package:path/path.dart' as p;

const deps = ['rec', 'adb', 'ffmpeg', 'ffprobe'];

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

  rootShell = shell.Shell(
      workingDirectory: mainDirectory.absolute.path, environment: myEnv);
  await rootShell.run('adb start-server');
}

Future<List<String>> getDevices() async {
  final r = (await rootShell.run('adb devices'))[0].stdout as String;
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
  Object? lastError;
  String? lastVideo;

  ProjectShell.fromShell(this.mshell) : _dir = Directory.current;
  ProjectShell.fromName(String projectName)
      : mshell = shell.Shell(
            workingDirectory: p.join(mainDirectory.absolute.path, projectName),
            environment: myEnv),
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
      lastError = e;
      return false;
    }
  }

  Future<void> _toggleCam(String device) async {
    await mshell.run('adb -s $device shell "input keyevent 25"');
  }

  Future<bool> startRecording(String device) async {
    try {
      // Toggle Cam
      await _toggleCam(device);
      curProcess = await Process.start('rec', ['audio.mp3'],
          workingDirectory: mshell.path, environment: myEnv);
      print('started rec');
      // We need to listen to streams or recording stops when streams are
      // filled which happens at around 1min, 55sec.
      curProcess?.stdout.listen((value) {});
      curProcess?.stderr.listen((value) {});
    } catch (e) {
      lastError = e;
      return false;
    }
    return true;
  }

  Process? curProcess;

  Future<bool> stopRecording(String device) async {
    try {
      Process p = curProcess!;
      p.kill(ProcessSignal.sigterm);
      await _toggleCam(device);
      return true;
    } catch (e) {
      lastError = e;
      return false;
    }
  }

  Future<bool> deleteVideoFromDevice(String device) async {
    try {
      if (lastVideo == null) {
        throw Exception('No last video.');
      }
      await mshell.run('adb -s $device shell rm "$lastVideo"');
      lastVideo = null;
      return true;
    } catch (e) {
      lastError = e;
      return false;
    }
  }

  Future<bool> pullVideoFromDevice(String device) async {
    // Wait for phone to stop recording completely.
    await Future.delayed(Duration(seconds: 2));
    try {
      String videoName = (await mshell.run(
              'adb -s $device shell ls "/storage/emulated/0/DCIM/Camera/VID*" | tail -1'))[0]
          .outText;
      if (videoName.isEmpty) {
        print('Empty pull video.');
        return false;
      }
      lastVideo = videoName;
      String storeVidName = 'camVideo.mp4';
      await mshell.run('adb -s $device pull $videoName $storeVidName');

      return await File(p.join(_dir.path, storeVidName)).exists();
    } catch (e) {
      lastError = e;
      return false;
    }
  }

  Future<bool> mergeAudioVideo() async {
    try {
      await mshell.run(
          'ffmpeg -loglevel warning -i camvideo.mp4 -vcodec copy -an camnoaudio.mp4');

      double videoDurSec = double.parse((await mshell.run(
              'ffprobe -i camnoaudio.mp4 -show_entries format=duration -v quiet -of csv="p=0"'))[0]
          .outText);
      double audioDurSec = double.parse((await mshell.run(
              'ffprobe -i audio.mp3 -show_entries format=duration -v quiet -of csv="p=0"'))[0]
          .outText);
      if (audioDurSec > videoDurSec) {
        throw Exception('Unable to merge, Audio is larger than video.');
      }

      // Trim camnoaudio.mp4 to length of audio.
      await mshell.run(
          'ffmpeg -loglevel warning -i camnoaudio.mp4 -t $audioDurSec -c copy camnoaudiotrimmed.mp4');

      // Merge
      await mshell.run(
          'ffmpeg -loglevel warning -i audio.mp3 -i camnoaudiotrimmed.mp4 -c:v copy -c:a aac final.mp4');

      // Delete camnoaudio.mp4 and camnoaudiotrimmed
      await File(p.join(_dir.path, 'camnoaudio.mp4')).delete();
      await File(p.join(_dir.path, 'camnoaudiotrimmed.mp4')).delete();

      return true;
    } catch (e) {
      lastError = e;
      return false;
    }
  }
}
