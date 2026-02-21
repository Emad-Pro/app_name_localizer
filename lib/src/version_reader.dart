import 'dart:io';
import 'dart:isolate';

/// A utility class designed to programmatically retrieve the current
/// version of the package from its `pubspec.yaml` file.
///
/// This is particularly useful for CLI tools to display the version
/// via a `--version` flag without hardcoding it in the Dart code.
class VersionReader {
  /// Dynamically retrieves the version string from the package's `pubspec.yaml`.
  ///
  /// It uses [Isolate.resolvePackageUri] to locate the absolute path of the
  /// package's root directory, then reads the `pubspec.yaml` file and
  /// extracts the version using a [RegExp].
  ///
  /// Returns the version string (e.g., '1.2.2') if found, or '1.0.0' as a fallback.
  static Future<String> getVersion() async {
    try {
      // Resolving the library URI to find the physical path on the user's machine
      final uri = await Isolate.resolvePackageUri(
        Uri.parse('package:app_name_localizer/'),
      );

      if (uri != null) {
        // Moving up from 'lib/' to the root directory to find pubspec.yaml
        final pubspecPath = uri.resolve('../pubspec.yaml').toFilePath();
        final file = File(pubspecPath);

        if (file.existsSync()) {
          final content = file.readAsStringSync();

          // Regex to capture the version value after the 'version:' key
          final match = RegExp(
            r'^version:\s*(.*)$',
            multiLine: true,
          ).firstMatch(content);
          if (match != null) {
            return match.group(1)?.trim() ?? 'Unknown';
          }
        }
      }
    } catch (e) {
      return '1.0.1';
      // If resolution fails (e.g., during local development without pub get),
      // the error is caught to prevent the CLI from crashing.
    }

    return '1.0.1'; // Fallback version (Update this whenever you bump version)
  }
}
