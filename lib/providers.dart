import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/services/shell.dart';

final currentProjectProvider = StateProvider((ref) => '');
final projectShellProvider = StateProvider<ProjectShell>((ref) {
  final projectName = ref.watch(currentProjectProvider).state;
  return ProjectShell.fromName(projectName);
});

final currentDeviceProvider = StateProvider((ref) => '');

enum RecorderState { none, ready, recording, processing }
final recorderStateProvider = StateProvider((ref) => RecorderState.none);
