import 'dart:io';
import 'package:app_name_localizer/src/config_reader.dart';
import 'package:app_name_localizer/src/android_processor.dart';
import 'package:app_name_localizer/src/ios_processor.dart';
import 'package:app_name_localizer/src/utils.dart';
import 'package:app_name_localizer/src/version_reader.dart';

// Define the current version of your package

void main(List<String> args) async {
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

  // 1. Handle standard CLI flags (Help & Version) early
  if (args.contains('-h') || args.contains('--help')) {
    _printHelp(currentVersion); // نمرر الإصدار لدالة المساعدة
    return;
  }
  if (args.contains('-v') || args.contains('--version')) {
    Utils.log("🌍 App Name Localizer Pro v$currentVersion");
    return;
  }

  print("\n");
  Utils.log("╔══════════════════════════════════════════════╗");
  Utils.log("║    🌍 App Name Localizer Pro v$currentVersion          ║");
  Utils.log("║    👨‍💻 Developed with ❤️ by Emad Younis (EA)  ║");
  Utils.log("╚══════════════════════════════════════════════╝");
  print("");
  try {
    // 2. Load Configuration
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

    if (args.contains('-a') || args.contains('--android')) {
      Utils.log("🚀 Mode: Android Only (detected via flags)");
      processIos = false;
    } else if (args.contains('-i') || args.contains('--ios')) {
      Utils.log("🚀 Mode: iOS Only (detected via flags)");
      processAndroid = false;
    } else {
      // Interactive mode for terminal users
      Utils.log("❓ Which platform(s) would you like to update?");
      Utils.log("   [1] Android only");
      Utils.log("   [2] iOS only");
      Utils.log("   [3] Both (Default)");

      String answer = Utils.askUser("👉 Select an option (1/2/3):", defaultValue: "3").trim();

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
        case "":
          break;
        default:
          processIos = false;
          processIos = false;
          Utils.log("\n❌ Invalid input: '$answer'. Please select 1, 2, or 3.", error: true);
          Utils.log("🚫 Operation aborted. No changes were made.");
          exit(1); // Use 1 for error exit code
      }
    }

    _printSeparator();

    // 4. Execute Localization
    if (processAndroid) {
      Utils.log("⚙️  Processing Android...", success: false);
      AndroidProcessor.process(config);
      AndroidProcessor.validateManifest();
      Utils.log("✅ Android localization complete.", success: true);
    } else {
      Utils.log("⏩ Skipping Android...", success: false);
    }

    _printSeparator();

    if (processIos) {
      Utils.log("⚙️  Processing iOS...", success: false);
      IosProcessor.process(config);
      Utils.log("✅ iOS localization complete.", success: true);
    } else {
      Utils.log("⏩ Skipping iOS...", success: false);
    }

    _printSeparator();

    // 5. Success Banner
    Utils.log("🎉 SUCCESS! App names localized successfully.", success: true);
    Utils.log("👉 Next Step: Run 'flutter clean' && 'flutter run'");
    print("\n");
  } catch (e) {
    Utils.log("\n💥 Fatal Error: $e", error: true);
    exit(1);
  }
}

/// Helper method to print a consistent visual separator
void _printSeparator() {
  print("--------------------------------------------");
}

/// Helper method to display CLI usage instructions
/// Helper method to display CLI usage instructions
_printHelp(String version) {
  print("\n🌍 App Name Localizer Pro v$version");
  print("👨‍💻 Developed by Emad Younis (EA) | ✉️ emadeadev@gmail.com\n");
  print("A powerful tool to easily localize your Flutter app name for iOS and Android.\n");
  print("Usage: dart run app_name_localizer [arguments]\n");
  print("Options:");
  print("  -a, --android    Update Android app name only.");
  print("  -i, --ios        Update iOS app name only.");
  print("  -h, --help       Show this help message.");
  print("  -v, --version    Print the version number.");
  print("\nFor more information, visit the documentation on pub.dev.\n");
}
