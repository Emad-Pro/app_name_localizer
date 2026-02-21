import 'dart:io';

class AndroidProcessor {
  static void validateManifest() {
    final File manifest = File('android/app/src/main/AndroidManifest.xml');
    if (!manifest.existsSync()) {
      print('⚠️ AndroidManifest.xml not found.');
      return;
    }

    String content = manifest.readAsStringSync();

    if (!content.contains('android:label="@string/app_name"')) {
      print('\x1B[33m⚠️ Warning: Your AndroidManifest.xml does not seem to use @string/app_name.\x1B[0m');
      print('\x1B[36m🔧 Fixing it automatically...\x1B[0m');

      final RegExp appLabelRegex = RegExp(r'(<application[^>]*?)android:label="[^"]*"');

      if (appLabelRegex.hasMatch(content)) {
        content = content.replaceFirstMapped(appLabelRegex, (match) {
          return '${match.group(1)}android:label="@string/app_name"';
        });

        manifest.writeAsStringSync(content);
        print('\x1B[32m✅ AndroidManifest.xml updated successfully!\x1B[0m');
      } else {
        print('\x1B[31m❌ Could not find android:label in <application> tag to replace. Please do it manually.\x1B[0m');
      }
    } else {
      print('\x1B[32m✅ AndroidManifest.xml is already configured correctly.\x1B[0m');
    }
  }

  static void process(Map<String, String> config) {
    print("🤖 Processing Android...");
    final String resPath = 'android/app/src/main/res';

    if (!Directory(resPath).existsSync()) {
      print("⚠️ Android project not found at $resPath");
      return;
    }

    config.forEach((lang, name) {
      String folderName = lang == 'en' ? 'values' : 'values-$lang';
      String dirPath = '$resPath/$folderName';

      Directory(dirPath).createSync(recursive: true);

      File stringsFile = File('$dirPath/strings.xml');
      String newContent;

      if (stringsFile.existsSync()) {
        String currentContent = stringsFile.readAsStringSync();
        final regex = RegExp(r'<string name="app_name">.*?</string>');

        if (regex.hasMatch(currentContent)) {
          newContent = currentContent.replaceFirst(regex, '<string name="app_name">$name</string>');
        } else {
          newContent = currentContent.replaceFirst(
            '</resources>',
            '    <string name="app_name">$name</string>\n</resources>',
          );
        }
      } else {
        newContent =
            '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$name</string>
</resources>''';
      }

      stringsFile.writeAsStringSync(newContent);
      print("   ✅ Updated: $folderName/strings.xml");
    });
  }
}
