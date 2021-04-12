import 'package:process_run/shell.dart' as shell;

void main() async {
  print(await shell.which('sox'));
}
