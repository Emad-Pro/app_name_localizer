import 'dart:io';
import 'package:app_name_localizer/src/config_reader.dart';
import 'package:app_name_localizer/src/android_processor.dart';
import 'package:app_name_localizer/src/ios_processor.dart';
import 'package:app_name_localizer/src/macos_processor.dart';
import 'package:app_name_localizer/src/utils.dart';
import 'package:app_name_localizer/src/version_reader.dart';

/// The main entry point for the **App Name Localizer Pro** CLI tool.
///
/// This script orchestrates the entire localization process by:
/// 1. Handling CLI arguments and flags.
/// 2. Loading the configuration from `pubspec.yaml`.
/// 3. Determining the target platform through flags or interactive menu.
/// 4. Executing the supported processors.
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

  // 1.4 Handle Coming Soon Flags
  if (args.contains('-l') ||
      args.contains('--linux') ||
      args.contains('-w') ||
      args.contains('--windows') ||
      args.contains('--web')) {
    Utils.log("\n🚀 This platform is Coming Soon! Stay tuned for the next updates.", success: true);
    return;
  }

  // 1.5 Handle Revert Flag
  if (args.contains('-r') || args.contains('--revert')) {
    bool revAndroid = args.contains('-a') || args.contains('--android');
    bool revIos = args.contains('-i') || args.contains('--ios');
    bool revMacos = args.contains('-m') || args.contains('--macos');

    // If no specific platform flag is passed with -r, revert all supported by default
    if (!revAndroid && !revIos && !revMacos) {
      revAndroid = true;
      revIos = true;
      revMacos = true;
    }

    _executeRevert(revertAndroid: revAndroid, revertIos: revIos, revertMacos: revMacos);
    return;
  }

  // 1.6 Handle Clean Flag (Delete .bak files)
  if (args.contains('-c') || args.contains('--clean')) {
    bool clnAndroid = args.contains('-a') || args.contains('--android');
    bool clnIos = args.contains('-i') || args.contains('--ios');
    bool clnMacos = args.contains('-m') || args.contains('--macos');

    // If no specific platform flag is passed with -c, clean all supported by default
    if (!clnAndroid && !clnIos && !clnMacos) {
      clnAndroid = true;
      clnIos = true;
      clnMacos = true;
    }

    _executeClean(cleanAndroid: clnAndroid, cleanIos: clnIos, cleanMacos: clnMacos);
    return;
  }

  // Display the branding banner
  print("\n");
  Utils.log("╔══════════════════════════════════════════════╗");
  Utils.log("║    🌍 App Name Localizer Pro v$currentVersion          ║");
  Utils.log("║    👨‍💻 Developed with ❤️ by Emad Younis (EA)  ║");
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
    bool processAndroid = false;
    bool processIos = false;
    bool processMacos = false;

    // Check for platform-specific flags
    if (args.contains('-a') ||
        args.contains('--android') ||
        args.contains('-i') ||
        args.contains('--ios') ||
        args.contains('-m') ||
        args.contains('--macos')) {
      if (args.contains('-a') || args.contains('--android')) {
        Utils.log("🚀 Target: Android (detected via flags)");
        processAndroid = true;
      }
      if (args.contains('-i') || args.contains('--ios')) {
        Utils.log("🚀 Target: iOS (detected via flags)");
        processIos = true;
      }
      if (args.contains('-m') || args.contains('--macos')) {
        Utils.log("🚀 Target: macOS (detected via flags)");
        processMacos = true;
      }
    } else {
      // Interactive mode: Prompt the user to choose operations manually
      Utils.log("❓ Which operation would you like to perform?");
      Utils.log("   [1] Update Android only");
      Utils.log("   [2] Update iOS only");
      Utils.log("   [3] Update macOS only");
      Utils.log("   [4] Update Linux only (Coming Soon ⏳)");
      Utils.log("   [5] Update Windows only (Coming Soon ⏳)");
      Utils.log("   [6] Update Web only (Coming Soon ⏳)");
      Utils.log("   [7] Update All Supported Platforms");
      Utils.log("   [8] ⏪ Revert previous changes (Restore Backups)");
      Utils.log("   [9] 🧹 Clean backup files (Delete .bak files)");

      String answer = Utils.askUser("👉 Select an option (1-9):").trim();

      switch (answer) {
        case "1":
          processAndroid = true;
          break;
        case "2":
          processIos = true;
          break;
        case "3":
          processMacos = true;
          break;
        case "4":
        case "5":
        case "6":
          Utils.log("\n🚀 This platform is Coming Soon! We are working hard to bring it to you.", success: true);
          exit(0);
        case "7":
          processAndroid = true;
          processIos = true;
          processMacos = true;
          break;
        case "8":
          // Sub-menu for Revert Option
          Utils.log("\n❓ Which platform(s) would you like to revert?");
          Utils.log("   [1] Revert Android only");
          Utils.log("   [2] Revert iOS only");
          Utils.log("   [3] Revert macOS only");
          Utils.log("   [4] Revert All Supported Platforms");

          String revertAnswer = Utils.askUser("👉 Select an option (1-4):").trim();

          bool revAndroid = false;
          bool revIos = false;
          bool revMacos = false;

          switch (revertAnswer) {
            case "1":
              revAndroid = true;
              break;
            case "2":
              revIos = true;
              break;
            case "3":
              revMacos = true;
              break;
            case "4":
              revAndroid = true;
              revIos = true;
              revMacos = true;
              break;
            default:
              Utils.log("\n❌ Invalid input: '$revertAnswer'.", error: true);
              exit(1);
          }
          _executeRevert(revertAndroid: revAndroid, revertIos: revIos, revertMacos: revMacos);
          return;

        case "9":
          // Sub-menu for Clean Option
          Utils.log("\n❓ Which platform's backups would you like to clean?");
          Utils.log("   [1] Clean Android only");
          Utils.log("   [2] Clean iOS only");
          Utils.log("   [3] Clean macOS only");
          Utils.log("   [4] Clean All Supported Platforms");

          String cleanAnswer = Utils.askUser("👉 Select an option (1-4):").trim();

          bool clnAndroid = false;
          bool clnIos = false;
          bool clnMacos = false;

          switch (cleanAnswer) {
            case "1":
              clnAndroid = true;
              break;
            case "2":
              clnIos = true;
              break;
            case "3":
              clnMacos = true;
              break;
            case "4":
              clnAndroid = true;
              clnIos = true;
              clnMacos = true;
              break;
            default:
              Utils.log("\n❌ Invalid input: '$cleanAnswer'.", error: true);
              exit(1);
          }
          _executeClean(cleanAndroid: clnAndroid, cleanIos: clnIos, cleanMacos: clnMacos);
          return;

        default:
          Utils.log("\n❌ Invalid input: '$answer'. Please select a valid option.", error: true);
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
      _printSeparator();
    }

    // 5. Execute iOS Localization
    if (processIos) {
      Utils.log("⚙️  Processing iOS...", success: false);
      IosProcessor.process(config);
      Utils.log("✅ iOS localization complete.", success: true);
      _printSeparator();
    }

    // 6. Execute macOS Localization
    if (processMacos) {
      Utils.log("⚙️  Processing macOS...", success: false);
      MacosProcessor.process(config);
      Utils.log("✅ macOS localization complete.", success: true);
      _printSeparator();
    }

    // 7. Success Banner
    Utils.log("🎉 SUCCESS! App names localized successfully.", success: true);
    print("\n");
  } catch (e) {
    Utils.log("\n💥 Fatal Error: $e", error: true);
    exit(1);
  }
}

/// Helper method to execute the revert process.
void _executeRevert({bool revertAndroid = false, bool revertIos = false, bool revertMacos = false}) {
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

  if (revertIos) IosProcessor.revert();
  if (revertMacos) MacosProcessor.revert();

  Utils.log("✅ Revert operation completed successfully.", success: true);
  exit(0);
}

/// Helper method to clean (delete) `.bak` files with confirmation.
void _executeClean({bool cleanAndroid = false, bool cleanIos = false, bool cleanMacos = false}) {
  Utils.log("\n🧹 Preparing to clean backup files (.bak)...", success: false);

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

  if (cleanMacos) {
    filesToDelete.add('macos/Runner.xcodeproj/project.pbxproj.bak');
    filesToDelete.add('macos/Runner/Info.plist.bak');
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
  print("👨‍💻 Developed by Emad Younis (EA) | ✉️ emadeadev@gmail.com\n");
  print("A powerful tool to easily localize your Flutter app name for multiple platforms.\n");
  print("Usage: dart run app_name_localizer [arguments]\n");
  print("Options:");
  print("  -a, --android    Target Android");
  print("  -i, --ios        Target iOS");
  print("  -m, --macos      Target macOS");
  print("  -l, --linux      Target Linux (Coming Soon)");
  print("  -w, --windows    Target Windows (Coming Soon)");
  print("      --web        Target Web (Coming Soon)");
  print("  -r, --revert     Revert changes and restore original files from backups.");
  print("  -c, --clean      Delete all .bak (backup) files created by the tool.");
  print("  -h, --help       Show this help message.");
  print("  -v, --version    Print the version number.");
  print("\nFor more information, visit the documentation on pub.dev.\n");
}
