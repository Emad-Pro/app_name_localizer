import 'dart:io';
import 'package:app_name_localizer/src/config_reader.dart';
import 'package:app_name_localizer/src/android_processor.dart';
import 'package:app_name_localizer/src/ios_processor.dart';
import 'package:app_name_localizer/src/utils.dart';
import 'package:app_name_localizer/src/version_reader.dart';

/// The main entry point for the **App Name Localizer Pro** CLI tool.
///
/// This script orchestrates the entire localization process by:
/// 1. Handling CLI arguments and flags.
/// 2. Loading the configuration from `pubspec.yaml`.
/// 3. Determining the target platform through flags or interactive menu.
/// 4. Executing the Android and iOS processors.
///
/// Run this using: `dart run app_name_localizer`
Future<void> main(List<String> args) async {
  // Retrieve the current package version dynamically from pubspec.yaml
  final String currentVersion = await VersionReader.getVersion();

  // 1. Handle standard CLI flags (Help & Version) early
  if (args.contains('-h') || args.contains('--help')) {
    _printHelp(currentVersion);
    return;
  }
  if (args.contains('-v') || args.contains('--version')) {
    Utils.log("🌍 App Name Localizer Pro v$currentVersion");
    return;
  }

  // 1.5 Handle Revert Flag
  if (args.contains('-r') || args.contains('--revert')) {
    bool revAndroid = args.contains('-a') || args.contains('--android');
    bool revIos = args.contains('-i') || args.contains('--ios');

    if (!revAndroid && !revIos) {
      revAndroid = true;
      revIos = true;
    }

    _executeRevert(revertAndroid: revAndroid, revertIos: revIos);
    return;
  }

  // 1.6 Handle Clean Flag (Delete .bak files)
  if (args.contains('-c') || args.contains('--clean')) {
    bool clnAndroid = args.contains('-a') || args.contains('--android');
    bool clnIos = args.contains('-i') || args.contains('--ios');

    if (!clnAndroid && !clnIos) {
      clnAndroid = true;
      clnIos = true;
    }

    _executeClean(cleanAndroid: clnAndroid, cleanIos: clnIos);
    return;
  }

  // Display the branding banner
  print("\n");
  Utils.log("╔══════════════════════════════════════════════╗");
  Utils.log("║    🌍 App Name Localizer Pro v$currentVersion          ║");
  Utils.log("║    👨‍💻 Developed with ❤️ by Emad Younis (EY)  ║");
  Utils.log("╚══════════════════════════════════════════════╝");
  print("");

  try {
    // 2. Load Configuration from pubspec.yaml
    Utils.log("📂 Reading configuration file...", success: false);
    final config = ConfigReader.loadConfig();

    if (config == null || config.isEmpty) {
      Utils.log("❌ No languages found in configuration.", error: true);
      Utils.log("👉 Please ensure 'app_name_localizer' is properly defined in your pubspec.yaml.");
      exit(1);
    }

    Utils.log("✅ Found ${config.length} languages: ${config.keys.join(', ')}", success: true);
    _printSeparator();

    // 3. Determine Target Platforms (Logic Unit)
    bool processAndroid = true;
    bool processIos = true;

    // Check for platform-specific flags
    if (args.contains('-a') || args.contains('--android')) {
      Utils.log("🚀 Mode: Android Only (detected via flags)");
      processIos = false;
    } else if (args.contains('-i') || args.contains('--ios')) {
      Utils.log("🚀 Mode: iOS Only (detected via flags)");
      processAndroid = false;
    } else {
      // Interactive mode: Prompt the user to choose operations manually
      Utils.log("❓ Which operation would you like to perform?");
      Utils.log("   [1] Update Android only");
      Utils.log("   [2] Update iOS only");
      Utils.log("   [3] Update Both Android & iOS");
      Utils.log("   [4] ⏪ Revert previous changes (Restore Backups)");
      Utils.log("   [5] 🧹 Clean backup files (Delete .bak files)");

      String answer = Utils.askUser("👉 Select an option (1/2/3/4/5):").trim();

      switch (answer) {
        case "1":
          processIos = false;
          break;
        case "2":
          processAndroid = false;
          break;
        case "3":
          processAndroid = true;
          processIos = true;
          break;
        case "4":
          // Sub-menu for Revert Option
          Utils.log("\n❓ Which platform(s) would you like to revert?");
          Utils.log("   [1] Revert Android only");
          Utils.log("   [2] Revert iOS only");
          Utils.log("   [3] Revert Both");

          // إزالة defaultValue لمنع الإدخال الفارغ
          String revertAnswer = Utils.askUser("👉 Select an option (1/2/3):").trim();

          bool revAndroid = true;
          bool revIos = true;

          switch (revertAnswer) {
            case "1":
              revIos = false;
              break;
            case "2":
              revAndroid = false;
              break;
            case "3":
              break;
            default:
              // سيتم التقاط الـ Enter الفارغ هنا
              Utils.log("\n❌ Invalid input: '$revertAnswer'. Please select 1, 2, or 3.", error: true);
              Utils.log("🚫 Operation aborted. No changes were made.");
              exit(1);
          }
          _executeRevert(revertAndroid: revAndroid, revertIos: revIos);
          return;

        case "5":
          // Sub-menu for Clean Option
          Utils.log("\n❓ Which platform's backups would you like to clean?");
          Utils.log("   [1] Clean Android only");
          Utils.log("   [2] Clean iOS only");
          Utils.log("   [3] Clean Both");

          // إزالة defaultValue لمنع الإدخال الفارغ
          String cleanAnswer = Utils.askUser("👉 Select an option (1/2/3):").trim();

          bool clnAndroid = true;
          bool clnIos = true;

          switch (cleanAnswer) {
            case "1":
              clnIos = false;
              break;
            case "2":
              clnAndroid = false;
              break;
            case "3":
              break;
            default:
              // سيتم التقاط الـ Enter الفارغ هنا
              Utils.log("\n❌ Invalid input: '$cleanAnswer'. Please select 1, 2, or 3.", error: true);
              Utils.log("🚫 Operation aborted. No changes were made.");
              exit(1);
          }
          _executeClean(cleanAndroid: clnAndroid, cleanIos: clnIos);
          return;

        default:
          Utils.log("\n❌ Invalid input: '$answer'. Please select 1, 2, 3, 4, or 5.", error: true);
          Utils.log("🚫 Operation aborted. No changes were made.");
          exit(1);
      }
    }

    _printSeparator();

    // 4. Execute Android Localization
    if (processAndroid) {
      Utils.log("⚙️  Processing Android...", success: false);
      AndroidProcessor.process(config);
      AndroidProcessor.validateManifest();
      Utils.log("✅ Android localization complete.", success: true);
    } else {
      Utils.log("⏩ Skipping Android...", success: false);
    }

    _printSeparator();

    // 5. Execute iOS Localization
    if (processIos) {
      Utils.log("⚙️  Processing iOS...", success: false);
      IosProcessor.process(config);
      Utils.log("✅ iOS localization complete.", success: true);
    } else {
      Utils.log("⏩ Skipping iOS...", success: false);
    }

    _printSeparator();

    // 6. Success Banner and instructions
    Utils.log("🎉 SUCCESS! App names localized successfully.", success: true);
    Utils.log("👉 Next Step: Run 'flutter clean' && 'flutter run'");
    print("\n");
  } catch (e) {
    Utils.log("\n💥 Fatal Error: $e", error: true);
    exit(1);
  }
}

/// Helper method to execute the revert process.
void _executeRevert({bool revertAndroid = true, bool revertIos = true}) {
  Utils.log("\n⏪ Initiating Revert Process...", success: false);

  if (revertAndroid) {
    try {
      final config = ConfigReader.loadConfig();
      if (config != null && config.isNotEmpty) {
        AndroidProcessor.revert(config);
      }
    } catch (e) {
      Utils.restoreBackup('android/app/src/main/AndroidManifest.xml');
    }
  }

  if (revertIos) {
    IosProcessor.revert();
  }

  Utils.log("✅ Revert operation completed successfully.", success: true);
  exit(0);
}

/// Helper method to clean (delete) `.bak` files with confirmation.
void _executeClean({bool cleanAndroid = true, bool cleanIos = true}) {
  Utils.log("\n🧹 Preparing to clean backup files (.bak)...", success: false);

  // طلب التأكيد من المستخدم
  String confirm = Utils.askUser(
    "⚠️ Are you sure you want to permanently delete the selected backup files? (y/n):",
  ).trim().toLowerCase();

  if (confirm != 'y' && confirm != 'yes') {
    Utils.log("🚫 Clean operation cancelled by user.");
    exit(0);
  }

  List<String> filesToDelete = [];

  if (cleanAndroid) {
    filesToDelete.add('android/app/src/main/AndroidManifest.xml.bak');
    try {
      final config = ConfigReader.loadConfig();
      if (config != null && config.isNotEmpty) {
        final String resPath = 'android/app/src/main/res';
        config.forEach((lang, _) {
          String folderName = lang == 'en' ? 'values' : 'values-$lang';
          filesToDelete.add('$resPath/$folderName/strings.xml.bak');
        });
      }
    } catch (e) {
      // Ignore if config is missing
    }
  }

  if (cleanIos) {
    filesToDelete.add('ios/Runner.xcodeproj/project.pbxproj.bak');
    filesToDelete.add('ios/Runner/Info.plist.bak');
  }

  int deletedCount = 0;
  for (String path in filesToDelete) {
    File file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
      deletedCount++;
    }
  }

  if (deletedCount > 0) {
    Utils.log("✅ Successfully deleted $deletedCount backup file(s).", success: true);
  } else {
    Utils.log("ℹ️ No backup files found for the selected platform(s). Workspace is already clean.");
  }

  exit(0);
}

/// Helper method to print a consistent visual separator in the terminal.
void _printSeparator() {
  print("--------------------------------------------");
}

/// Helper method to display CLI usage instructions and developer credits.
void _printHelp(String version) {
  print("\n🌍 App Name Localizer Pro v$version");
  print("👨‍💻 Developed by Emad Younis (EY) | ✉️ emadeadev@gmail.com\n");
  print("A powerful tool to easily localize your Flutter app name for iOS and Android.\n");
  print("Usage: dart run app_name_localizer [arguments]\n");
  print("Options:");
  print("  -a, --android    Target Android only.");
  print("  -i, --ios        Target iOS only.");
  print("  -r, --revert     Revert changes and restore original files from backups.");
  print("  -c, --clean      Delete all .bak (backup) files created by the tool.");
  print("  -h, --help       Show this help message.");
  print("  -v, --version    Print the version number.");
  print("\nExamples:");
  print("  dart run app_name_localizer -r        (Reverts both Android and iOS)");
  print("  dart run app_name_localizer -c -a     (Cleans Android backups only)");
  print("\nFor more information, visit the documentation on pub.dev.\n");
}
