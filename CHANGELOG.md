## 1.0.0

🚀 **Initial Release**

* ✨ **Core Feature:** Introduced a powerful CLI tool to automatically localize Flutter app names for both Android and iOS seamlessly.
* 🤖 **Smart Android Processing:** Automatically and safely updates `AndroidManifest.xml` and generates the required `strings.xml` files for all specified languages.
* 🍎 **Smart iOS Processing:** Automatically configures `Info.plist` and generates `InfoPlist.strings` directories for targeted iOS localizations.
* 💻 **Interactive CLI:** Added a user-friendly terminal interface allowing developers to target specific platforms (Android only, iOS only, or Both) using interactive prompts or fast CLI flags (`-a`, `-i`).
* ⚙️ **Easy Configuration:** Reads language key-value pairs effortlessly from the project configuration.
* 🎨 **Developer Experience:** Implemented colorful, formatted console logs with clear success messages, warnings, and error handling for a premium developer experience.

## 1.0.1

* 🛠️ **Fix:** Added missing `void` return type to `_printHelp` to satisfy static analysis.
* 📚 **Documentation:** Added comprehensive Dartdoc comments (API reference) for all public and private classes.
* 🔗 **Metadata:** Corrected repository and homepage URLs in `pubspec.yaml`.
* 📁 **Example:** Added an official example directory to demonstrate usage.
* ⚡ **Optimization:** Removed unnecessary Flutter dependencies to make the package "Pure Dart".