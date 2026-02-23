import 'dart:io';
import 'utils.dart';

/// A utility class that automates the localization of the Linux app name.
///
/// This class generates or updates a `.desktop` file in the `linux/` directory.
/// The `.desktop` file is the standard way Linux desktop environments (like GNOME, KDE)
/// localize application names in their app launchers and menus.
class LinuxProcessor {
  /// The main entry point for Linux localization processing.
  ///
  /// It extracts the binary name from `CMakeLists.txt`, then creates a
  /// `.desktop` file injecting the standard `Name` and `Name[lang]` keys.
  static void process(Map<String, String> config) {
    print("🐧 Processing Linux...");
    final String linuxPath = 'linux';

    if (!Directory(linuxPath).existsSync()) {
      print("⚠️ Linux project not found at $linuxPath");
      return;
    }

    // 1. Extract Binary Name from CMakeLists.txt
    String binaryName = 'app';
    File cmakeFile = File('$linuxPath/CMakeLists.txt');
    if (cmakeFile.existsSync()) {
      String cmakeContent = cmakeFile.readAsStringSync();
      // تبحث عن سطر set(BINARY_NAME "app_name")
      RegExp binaryNameRegex = RegExp(r'set\(BINARY_NAME\s+"([^"]+)"\)');
      Match? match = binaryNameRegex.firstMatch(cmakeContent);
      if (match != null) {
        binaryName = match.group(1)!;
      }
    }

    // 2. Define the .desktop file path
    File desktopFile = File('$linuxPath/$binaryName.desktop');

    // Backup if the file already exists
    if (desktopFile.existsSync()) {
      Utils.backupFile(desktopFile.path);
    }

    // 3. Generate .desktop content
    StringBuffer content = StringBuffer();
    content.writeln('[Desktop Entry]');
    content.writeln('Version=1.0');
    content.writeln('Type=Application');
    content.writeln('Terminal=false');
    content.writeln('Exec=$binaryName');
    content.writeln('Icon=$binaryName');

    // Add localized names
    config.forEach((lang, name) {
      if (lang == 'en' || lang == 'Base') {
        content.writeln('Name=$name');
      } else {
        content.writeln('Name[$lang]=$name');
      }
    });

    // Ensure a default fallback 'Name' exists if 'en' wasn't provided
    if (!config.containsKey('en') && !config.containsKey('Base')) {
      content.writeln('Name=${config.values.first}');
    }

    desktopFile.writeAsStringSync(content.toString());
    print("   ✅ Generated/Updated $binaryName.desktop successfully.");
  }

  /// Reverts all localization changes made to the Linux project.
  ///
  /// It searches for any `.desktop.bak` files in the `linux/` directory
  /// and restores them.
  static void revert() {
    print("⏪ Reverting Linux changes...");
    final String linuxPath = 'linux';
    if (!Directory(linuxPath).existsSync()) return;

    Directory dir = Directory(linuxPath);
    List<FileSystemEntity> files = dir.listSync();
    bool found = false;

    for (var file in files) {
      if (file.path.endsWith('.desktop.bak')) {
        // نمرر المسار الأصلي بدون .bak لدالة الاستعادة
        Utils.restoreBackup(file.path.replaceAll('.bak', ''));
        found = true;
      }
    }

    if (!found) {
      print("   ℹ️ No Linux backups found to revert.");
    } else {
      print("   ✅ Linux revert complete.");
    }
  }
}
