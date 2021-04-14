import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentProjectProvider = StateProvider((ref) => '');
final currentDeviceProvider = StateProvider((ref) => '');

enum RecorderState { none, ready, recording, processing }
final recorderStateProvider = StateProvider((ref) => RecorderState.none);
