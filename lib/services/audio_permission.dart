import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('audio_permission_macos');

Future<bool> getAudioPermission() async {
  return (await _channel.invokeMethod<bool>('getAudioPermission')) ?? false;
}
