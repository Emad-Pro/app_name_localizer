import 'dart:io';

class Utils {
  static String askUser(String question, {String defaultValue = ''}) {
    stdout.write('\x1B[36m$question\x1B[0m ');
    String input = stdin.readLineSync()?.trim() ?? '';
    return input.isEmpty ? defaultValue : input;
  }

  static void log(String msg, {bool error = false, bool success = false}) {
    if (error) {
      print('\x1B[31m$msg\x1B[0m');
    } else if (success) {
      print('\x1B[32m$msg\x1B[0m');
    } else {
      print('\x1B[34m$msg\x1B[0m');
    }
  }

  static void backupFile(String path) {
    final file = File(path);
    if (file.existsSync()) {
      file.copySync('$path.bak');
    }
  }

  static void restoreBackup(String path) {
    final backup = File('$path.bak');
    if (backup.existsSync()) {
      backup.copySync(path);
      log("♻️ Restored backup for: $path", error: true);
    }
  }
}
