import 'dart:io';
import 'package:app_name_localizer/src/utils.dart'; // تأكد من مسار الاستدعاء الصحيح للـ Utils

/// A utility class responsible for processing and validating Android-specific localization.
///
/// This class handles the modification of `AndroidManifest.xml` and the generation
/// of `strings.xml` files for different locales.
class AndroidProcessor {
  /// Validates and ensures that the `AndroidManifest.xml` file is correctly configured.
  ///
  /// It checks if the `android:label` attribute in the `<application>` tag is set
  /// to `@string/app_name`. If it finds a hardcoded string, it attempts to
  /// automatically replace it with the required resource reference.
  static void validateManifest() {
    final File manifest = File('android/app/src/main/AndroidManifest.xml');
    if (!manifest.existsSync()) {
      print('⚠️ AndroidManifest.xml not found.');
      return;
    }

    String content = manifest.readAsStringSync();

    // Check if the manifest already uses the string resource for the app label
    if (!content.contains('android:label="@string/app_name"')) {
      print('\x1B[33m⚠️ Warning: Your AndroidManifest.xml does not seem to use @string/app_name.\x1B[0m');
      print('\x1B[36m🔧 Fixing it automatically...\x1B[0m');

      // Regex to find the <application> tag and its android:label attribute
      final RegExp appLabelRegex = RegExp(r'(<application[^>]*?)android:label="[^"]*"');

      if (appLabelRegex.hasMatch(content)) {
        content = content.replaceFirstMapped(appLabelRegex, (match) {
          return '${match.group(1)}android:label="@string/app_name"';
        });

        // 👈 أضفنا عملية أخذ نسخة احتياطية قبل التعديل
        Utils.backupFile(manifest.path);

        manifest.writeAsStringSync(content);
        print('\x1B[32m✅ AndroidManifest.xml updated successfully!\x1B[0m');
      } else {
        print('\x1B[31m❌ Could not find android:label in <application> tag to replace. Please do it manually.\x1B[0m');
      }
    } else {
      print('\x1B[32m✅ AndroidManifest.xml is already configured correctly.\x1B[0m');
    }
  }

  /// Generates and updates the `strings.xml` files for each language provided in [config].
  ///
  /// The [config] parameter should be a map where keys are language codes (e.g., 'ar', 'en')
  /// and values are the corresponding app names.
  ///
  /// It creates the necessary directory structure (`values`, `values-ar`, etc.)
  /// inside the Android `res` folder and writes the `app_name` string resource.
  static void process(Map<String, String> config) {
    print("🤖 Processing Android...");
    final String resPath = 'android/app/src/main/res';

    if (!Directory(resPath).existsSync()) {
      print("⚠️ Android project not found at $resPath");
      return;
    }

    config.forEach((lang, name) {
      // Use 'values' for English (default) and 'values-xx' for other languages
      String folderName = lang == 'en' ? 'values' : 'values-$lang';
      String dirPath = '$resPath/$folderName';

      Directory(dirPath).createSync(recursive: true);

      File stringsFile = File('$dirPath/strings.xml');
      String newContent;

      if (stringsFile.existsSync()) {
        String currentContent = stringsFile.readAsStringSync();
        final regex = RegExp(r'<string name="app_name">.*?</string>');

        // Update existing app_name or append it to the resources
        if (regex.hasMatch(currentContent)) {
          newContent = currentContent.replaceFirst(regex, '<string name="app_name">$name</string>');
        } else {
          newContent = currentContent.replaceFirst(
            '</resources>',
            '    <string name="app_name">$name</string>\n</resources>',
          );
        }
      } else {
        // Create a new strings.xml file if it doesn't exist
        newContent =
            '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$name</string>
</resources>''';
      }

      // 👈 أضفنا عملية أخذ نسخة احتياطية قبل التعديل
      Utils.backupFile(stringsFile.path);

      stringsFile.writeAsStringSync(newContent);
      print("   ✅ Updated: $folderName/strings.xml");
    });
  }

  /// Reverts all localization changes made to the Android project.
  ///
  /// This method restores the `AndroidManifest.xml` and all generated
  /// `strings.xml` files from their `.bak` backups using the [config] map
  /// to locate the language-specific directories.
  static void revert(Map<String, String> config) {
    print("⏪ Reverting Android changes...");

    // 1. Restore the AndroidManifest.xml
    Utils.restoreBackup('android/app/src/main/AndroidManifest.xml');

    // 2. Restore each strings.xml file generated for the languages
    final String resPath = 'android/app/src/main/res';
    config.forEach((lang, name) {
      String folderName = lang == 'en' ? 'values' : 'values-$lang';
      Utils.restoreBackup('$resPath/$folderName/strings.xml');
    });

    print("   ✅ Android revert complete.");
  }
}
