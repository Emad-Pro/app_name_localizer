import 'dart:io';
import 'package:yaml/yaml.dart';

/// A utility class responsible for reading and parsing the configuration
/// from the project's `pubspec.yaml` file.
class ConfigReader {
  /// Loads the localization settings defined under the `app_name_localizer` key.
  ///
  /// This method looks for a `pubspec.yaml` file in the current directory,
  /// parses its content, and extracts the language-to-name mapping.
  ///
  /// ### Example Configuration in pubspec.yaml:
  /// ```yaml
  /// app_name_localizer:
  ///   en: "My App"
  ///   ar: "تطبيقي"
  /// ```
  ///
  /// Returns a [Map<String, String>] containing language codes as keys
  /// and localized names as values.
  ///
  /// Throws an [Exception] if:
  /// * The `pubspec.yaml` file is not found.
  /// * The `app_name_localizer` key is missing.
  /// * The configuration format is invalid.
  static Map<String, String>? loadConfig() {
    final File file = File('pubspec.yaml');
    if (!file.existsSync()) {
      throw Exception(
        '❌ Error: pubspec.yaml not found. Are you in the root of your Flutter project?',
      );
    }

    final String content = file.readAsStringSync();
    final Map yamlMap = loadYaml(content);

    // Ensure the configuration key exists
    if (yamlMap['app_name_localizer'] == null) {
      throw Exception(
        '❌ Error: Configuration key "app_name_localizer" not found in pubspec.yaml',
      );
    }

    final Map<String, String> config = {};
    final node = yamlMap['app_name_localizer'];

    if (node is Map) {
      node.forEach((key, value) {
        config[key.toString()] = value.toString();
      });
    } else {
      throw Exception(
        '❌ Error: Invalid format for "app_name_localizer". Expected a map of languages.',
      );
    }

    return config;
  }
}
