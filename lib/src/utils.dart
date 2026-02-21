import 'dart:io';

/// A utility class containing helper methods for user interaction,
/// console logging, and file safety operations.
class Utils {
  /// Prompts the user with a [question] in the terminal and returns the input.
  ///
  /// The [question] is displayed in cyan color. If the user provides no input
  /// (empty line), it returns the specified [defaultValue].
  ///
  /// Returns a [String] representing the user's response or the default value.
  static String askUser(String question, {String defaultValue = ''}) {
    // Write the question in Cyan color
    stdout.write('\x1B[36m$question\x1B[0m ');
    String input = stdin.readLineSync()?.trim() ?? '';
    return input.isEmpty ? defaultValue : input;
  }

  /// Logs a formatted message to the console with color-coding.
  ///
  /// * Set [error] to true for red-colored output (used for failures).
  /// * Set [success] to true for green-colored output (used for completion).
  /// * Default is blue-colored output (used for general information).
  static void log(String msg, {bool error = false, bool success = false}) {
    if (error) {
      print('\x1B[31m$msg\x1B[0m'); // Red
    } else if (success) {
      print('\x1B[32m$msg\x1B[0m'); // Green
    } else {
      print('\x1B[34m$msg\x1B[0m'); // Blue
    }
  }

  /// Creates a backup copy of a file before performing destructive operations.
  ///
  /// Takes a file [path] and creates a duplicate named `path.bak`.
  /// This is essential for critical files like `project.pbxproj`.
  static void backupFile(String path) {
    final file = File(path);
    if (file.existsSync()) {
      file.copySync('$path.bak');
    }
  }

  /// Restores a file from its `.bak` backup copy.
  ///
  /// This is used as a recovery mechanism if an operation fails.
  /// It logs a message using the error format to alert the user.
  static void restoreBackup(String path) {
    final backup = File('$path.bak');
    if (backup.existsSync()) {
      backup.copySync(path);
      log("♻️ Restored backup for: $path", error: true);
    }
  }
}
