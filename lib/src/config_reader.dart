import 'dart:io';
import 'package:yaml/yaml.dart';

class ConfigReader {
  static Map<String, String>? loadConfig() {
    final File file = File('pubspec.yaml');
    if (!file.existsSync()) {
      throw Exception('❌ Error: pubspec.yaml not found. Are you in the root of your Flutter project?');
    }

    final String content = file.readAsStringSync();
    final Map yamlMap = loadYaml(content);

    if (yamlMap['app_name_localizer'] == null) {
      throw Exception('❌ Error: Configuration key "app_name_localizer" not found in pubspec.yaml');
    }

    final Map<String, String> config = {};
    final node = yamlMap['app_name_localizer'];

    if (node is Map) {
      node.forEach((key, value) {
        config[key.toString()] = value.toString();
      });
    } else {
      throw Exception('❌ Error: Invalid format for "app_name_localizer". Expected a list of languages.');
    }

    return config;
  }
}
