import 'dart:io';
import 'dart:math';

import 'utils.dart';

/// A utility class that automates the localization of the iOS app name.
///
/// This class handles creating `.lproj` directories, generating `InfoPlist.strings`,
/// enabling localized display names in `Info.plist`, and programmatically
/// modifying the `project.pbxproj` file to register these changes in Xcode.
class IosProcessor {
  /// The main entry point for iOS localization processing.
  ///
  /// It takes a [config] map where keys are language codes and values are app names.
  /// It validates the iOS project structure and orchestrates the creation of
  /// localized string files and project file updates.
  static void process(Map<String, String> config) {
    print("🍎 Processing iOS...");
    final String runnerPath = 'ios/Runner';
    final String projectFilePath = 'ios/Runner.xcodeproj/project.pbxproj';

    if (!Directory(runnerPath).existsSync()) {
      print("⚠️ iOS project not found at $runnerPath");
      return;
    }

    List<String> languagesToRegister = [];
    config.forEach((lang, name) {
      String folderName = '$lang.lproj';
      String dirPath = '$runnerPath/$folderName';
      Directory(dirPath).createSync(recursive: true);

      // Generating the content for InfoPlist.strings
      String content =
          '''
"CFBundleDisplayName" = "$name";
"CFBundleName" = "$name";
''';
      File('$dirPath/InfoPlist.strings').writeAsStringSync(content);

      if (lang != 'en' && lang != 'Base') {
        languagesToRegister.add(lang);
      }
    });

    // Step 1: Enable LSHasLocalizedDisplayName in Info.plist
    _updateInfoPlist(runnerPath);

    // Step 2: Inject references into the Xcode project file
    List<String> allLangs = config.keys.toList();
    _updatePbxProject(projectFilePath, allLangs);
  }

  /// Updates the `project.pbxproj` file to include the new localization variants.
  ///
  /// This involves identifying or creating a `PBXVariantGroup` for `InfoPlist.strings`,
  /// adding language-specific children to that group, and updating `knownRegions`.
  static void _updatePbxProject(String projectPath, List<String> languages) {
    Utils.backupFile(projectPath);
    File projectFile = File(projectPath);
    if (!projectFile.existsSync()) return;

    String content = projectFile.readAsStringSync();

    String variantGroupUUID;
    RegExp variantGroupRegex = RegExp(
      r'([A-F0-9]{24}) /\* InfoPlist.strings \*/ = \{',
    );
    Match? match = variantGroupRegex.firstMatch(content);

    if (match != null) {
      variantGroupUUID = match.group(1)!;
    } else {
      print("   ⚙️ Creating InfoPlist.strings Group...");
      var result = _createInfoPlistVariantGroup(content);
      content = result.content;
      variantGroupUUID = result.id;
      projectFile.writeAsStringSync(content);
    }

    content = _addChildrenToVariantGroup(content, variantGroupUUID, languages);
    content = _addToCopyBundleResources(content, variantGroupUUID);

    // Update the knownRegions section in Xcode
    for (String lang in languages) {
      if (!content.contains(RegExp(r'\s' + lang + r','))) {
        content = content.replaceFirst(
          'knownRegions = (',
          'knownRegions = (\n\t\t\t\t$lang,',
        );
      }
    }

    projectFile.writeAsStringSync(content);
    print("   ✅ Xcode project updated successfully.");
  }

  /// Ensures the `InfoPlist.strings` variant group is linked to the Resources Build Phase.
  ///
  /// This allows Xcode to actually include the localized strings in the final app bundle.
  static String _addToCopyBundleResources(String content, String fileRefUUID) {
    print("   🔨 Checking Build Phase linkage...");

    String buildFileUUID = "";

    // Check for existing PBXBuildFile entry for this resource
    RegExp buildFileRegex = RegExp(
      r'([A-F0-9]{24})\s*/\*.*?\*/\s*=\s*\{isa\s*=\s*PBXBuildFile;\s*fileRef\s*=\s*' +
          RegExp.escape(fileRefUUID),
    );
    Match? match = buildFileRegex.firstMatch(content);

    if (match != null) {
      buildFileUUID = match.group(1)!;
      print("   ℹ️ Found existing BuildFile definition: $buildFileUUID");
    } else {
      print("   ⚙️ Creating new PBXBuildFile definition...");
      buildFileUUID = _generateUUID();
      String buildFileEntry =
          '\t\t$buildFileUUID = {isa = PBXBuildFile; fileRef = $fileRefUUID; };\n';

      int buildSectionStart = content.indexOf(
        '/* Begin PBXBuildFile section */',
      );
      if (buildSectionStart != -1) {
        int insertPos = content.indexOf('\n', buildSectionStart) + 1;
        content = content.replaceRange(insertPos, insertPos, buildFileEntry);
      }
    }

    // Locate the PBXResourcesBuildPhase and inject the buildFile UUID
    int targetFilesIndex = -1;
    List<int> phaseIndices = [];
    int index = content.indexOf('isa = PBXResourcesBuildPhase;');
    while (index != -1) {
      phaseIndices.add(index);
      index = content.indexOf('isa = PBXResourcesBuildPhase;', index + 1);
    }

    for (int phaseIdx in phaseIndices) {
      int filesStart = content.indexOf('files = (', phaseIdx);
      int filesEnd = content.indexOf(');', filesStart);

      if (filesStart != -1 && filesEnd != -1) {
        String filesBlock = content.substring(filesStart, filesEnd);

        if (filesBlock.contains('Assets.xcassets') ||
            filesBlock.contains('LaunchScreen')) {
          targetFilesIndex = filesStart;

          if (filesBlock.contains(buildFileUUID)) {
            print(
              "   ✅ InfoPlist.strings is valid and linked. No action needed.",
            );
            return content;
          }
          break;
        }
      }
    }

    if (targetFilesIndex == -1) {
      print("   ❌ Error: Could not locate Main App Resources Phase.");
      return content;
    }

    int insertionIndex = targetFilesIndex + 9;
    String newFileItem = '\n\t\t\t\t$buildFileUUID,';
    content = content.replaceRange(insertionIndex, insertionIndex, newFileItem);

    return content;
  }

  /// Adds language-specific `PBXFileReference` entries to a `PBXVariantGroup`.
  static String _addChildrenToVariantGroup(
    String content,
    String parentUUID,
    List<String> languages,
  ) {
    String startMarker = '$parentUUID = {';
    int startIndex = content.indexOf(startMarker);
    if (startIndex == -1) return content;

    int childrenStart = content.indexOf('children = (', startIndex);
    int childrenEnd = content.indexOf(');', childrenStart);
    if (childrenStart == -1 || childrenEnd == -1) return content;

    String existingChildrenBlock = content.substring(
      childrenStart,
      childrenEnd,
    );
    String newChildrenLines = "";
    String newFileRefLines = "";
    bool changesMade = false;

    for (String lang in languages) {
      if (!existingChildrenBlock.contains('/* $lang */')) {
        String childUUID = _generateUUID();
        newChildrenLines += '\n\t\t\t\t$childUUID,';
        String path = '$lang.lproj/InfoPlist.strings';
        newFileRefLines +=
            '\t\t$childUUID = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = $lang; path = "$path"; sourceTree = "<group>"; };\n';
        changesMade = true;
        print("   ➕ Registering language '$lang'...");
      }
    }

    if (changesMade) {
      content = content.replaceRange(
        childrenEnd,
        childrenEnd,
        newChildrenLines,
      );
      int refSectionStart = content.indexOf(
        '/* Begin PBXFileReference section */',
      );
      if (refSectionStart != -1) {
        int insertPos = content.indexOf('\n', refSectionStart) + 1;
        content = content.replaceRange(insertPos, insertPos, newFileRefLines);
      }
    }
    return content;
  }

  /// Creates a new `PBXVariantGroup` for `InfoPlist.strings` if it doesn't exist.
  static ({String content, String id}) _createInfoPlistVariantGroup(
    String content,
  ) {
    String newUUID = _generateUUID();
    RegExp infoPlistRegex = RegExp(r'([A-F0-9]{24}) /\* Info.plist \*/,');
    Match? match = infoPlistRegex.firstMatch(content);
    if (match != null) {
      String infoPlistLine = match.group(0)!;
      String newLine = '\n\t\t\t\t$newUUID,';
      content = content.replaceFirst(infoPlistLine, '$infoPlistLine$newLine');
    }
    String groupDefinition =
        '''
\t\t$newUUID = {
\t\t\tisa = PBXVariantGroup;
\t\t\tchildren = (
\t\t\t);
\t\t\tname = InfoPlist.strings;
\t\t\tsourceTree = "<group>";
\t\t};
''';
    if (content.contains('/* Begin PBXVariantGroup section */')) {
      int sectionStart = content.indexOf('/* Begin PBXVariantGroup section */');
      int insertPos = content.indexOf('\n', sectionStart) + 1;
      content = content.replaceRange(insertPos, insertPos, groupDefinition);
    } else {
      String newSection =
          '\n/* Begin PBXVariantGroup section */\n$groupDefinition/* End PBXVariantGroup section */\n';
      int lastBrace = content.lastIndexOf('}');
      content = content.replaceRange(lastBrace, lastBrace, newSection);
    }
    return (content: content, id: newUUID);
  }

  /// Injects the `LSHasLocalizedDisplayName` key into `Info.plist`.
  ///
  /// This boolean flag tells iOS to look for localized app names in `InfoPlist.strings`.
  static void _updateInfoPlist(String runnerPath) {
    final File infoPlistFile = File('$runnerPath/Info.plist');
    if (!infoPlistFile.existsSync()) return;
    String content = infoPlistFile.readAsStringSync();
    if (!content.contains('LSHasLocalizedDisplayName')) {
      int lastDictIndex = content.lastIndexOf('</dict>');
      if (lastDictIndex != -1) {
        String newContent =
            '${content.substring(0, lastDictIndex)}\t<key>LSHasLocalizedDisplayName</key>\n\t<true/>\n${content.substring(lastDictIndex)}';
        infoPlistFile.writeAsStringSync(newContent);
        print("   ✅ Enabled LSHasLocalizedDisplayName.");
      }
    }
  }

  /// Generates a unique 24-character hexadecimal string.
  ///
  /// This mimics the UUID format used by Xcode to identify project elements.
  static String _generateUUID() {
    final Random random = Random();
    const String hexDigits = "0123456789ABCDEF";
    String uuid = "";
    for (int i = 0; i < 24; i++) {
      uuid += hexDigits[random.nextInt(16)];
    }
    return uuid;
  }
}
