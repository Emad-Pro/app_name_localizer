# 🌍 App Name Localizer Pro

A powerful, interactive, and easy-to-use Command Line Interface (CLI) tool for Flutter developers to seamlessly localize their app's display name for both iOS and Android platforms.

No more manual editing of `AndroidManifest.xml`, `strings.xml`, `Info.plist`, or `project.pbxproj`! Just define your app names in your `pubspec.yaml` and let the magic happen.

---

## ✨ Features

* 🤖 **Smart Android Automation:** Automatically updates `AndroidManifest.xml` (safely targets only the `<application>` tag) and generates `strings.xml` for all defined languages.
* 🍎 **Smart iOS Automation:** Intelligently configures `Info.plist` (enables `LSHasLocalizedDisplayName`), registers language variants, and seamlessly injects `InfoPlist.strings` into your Xcode `project.pbxproj`.
* 🛡️ **Built-in Safety (Auto-Backups):** Before touching critical files like your iOS `.pbxproj`, the tool automatically creates a backup so you never lose your data in case of unexpected errors.
* 💻 **Interactive CLI:** Choose to update Android only, iOS only, or both using a beautiful, interactive terminal menu.
* ⚡ **CI/CD Ready:** Use terminal flags (`-a` for Android, `-i` for iOS) to bypass the interactive menu for automated pipelines.
* 🎨 **Beautiful Logs:** Enjoy a premium developer experience with colorful, formatted console logs and clear error handling.

---

## 🚀 Getting Started

### 1. Installation

Add the package to your `dev_dependencies` in your `pubspec.yaml` file:

```yaml
dev_dependencies:
  app_name_localizer: ^1.1.0
```

Or simply run:
```bash
dart pub add dev:app_name_localizer
```

### 2. Configuration

Add a new section at the root level of your `pubspec.yaml` file named `app_name_localizer`. Define your language codes and the corresponding app names:

```yaml
app_name_localizer:
  en: "My Super App"
  ar: "تطبيقي الخارق"
  es: "Mi Súper Aplicación"
  fr: "Mon Super App"
```

---

## 🛠️ Usage

Open your terminal and run the following command from the root of your Flutter project:

```bash
dart run app_name_localizer
```

### Fast CLI Flags
If you want to target a specific platform directly (useful for scripts or CI/CD):

* **Android Only:** `dart run app_name_localizer -a`
* **iOS Only:** `dart run app_name_localizer -i`
* **Help:** `dart run app_name_localizer -h`

---

## ⚠️ Important Next Steps

After running the tool and successfully applying the localizations, it is highly recommended to clean and rebuild your project to ensure the OS picks up the new native files:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 👨‍💻 Developer & Credits

Developed with ❤️ by **Emad Younis (EY)**. 

* 📧 Email: emadeadev@gmail.com
* 🐛 Found a bug or have a feature request? Please open an issue on the GitHub repository!