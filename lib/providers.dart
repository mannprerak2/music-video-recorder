import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkmnrec_app/services/shell.dart';

final materialAppGlobalKey = GlobalKey<NavigatorState>();

enum ProjectLoaderState { none, loading, empty, complete }
final currentProjectLoaderState = StateProvider<ProjectLoaderState>((ref) {
  ref.watch(currentProjectProvider).state;
  return ProjectLoaderState.none;
});

final currentProjectProvider = StateProvider((ref) => '');
final projectShellProvider = StateProvider<ProjectShell>((ref) {
  final projectName = ref.watch(currentProjectProvider).state;
  return ProjectShell.fromName(projectName);
});

final currentDeviceProvider = StateProvider((ref) => '');

enum RecorderState { none, ready, recording, processing }
final recorderStateProvider = StateProvider((ref) => RecorderState.none);

final processingStateProvider = StateProvider((ref) => '');
