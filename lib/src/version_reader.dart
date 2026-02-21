import 'dart:io';
import 'dart:isolate';

class VersionReader {
  static Future<String> getVersion() async {
    try {
      final uri = await Isolate.resolvePackageUri(Uri.parse('package:app_name_localizer/'));

      if (uri != null) {
        final pubspecPath = uri.resolve('../pubspec.yaml').toFilePath();
        final file = File(pubspecPath);

        if (file.existsSync()) {
          final content = file.readAsStringSync();

          final match = RegExp(r'^version:\s*(.*)$', multiLine: true).firstMatch(content);
          if (match != null) {
            return match.group(1)?.trim() ?? 'Unknown';
          }
        }
      }
    } catch (e) {}

    return '1.0.0';
  }
}
