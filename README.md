# 🌍 App Name Localizer Pro

A powerful, interactive, and easy-to-use Command Line Interface (CLI) tool for Flutter developers to seamlessly localize their app's display name for multiple platforms.

No more manual editing of `AndroidManifest.xml`, `strings.xml`, `Info.plist`, or `project.pbxproj`! Just define your app names in your `pubspec.yaml` and let the magic happen.

---

## ✨ Features

* 🤖 **Smart Android Automation:** Automatically updates `AndroidManifest.xml` (safely targets only the `<application>` tag) and generates `strings.xml` for all defined languages.
* 🍎 **Smart iOS & macOS Automation:** Intelligently configures `Info.plist` (enables `LSHasLocalizedDisplayName`), registers language variants, and seamlessly injects `InfoPlist.strings` into your Xcode `project.pbxproj`.
* 🛡️ **Built-in Safety (Auto-Backups):** Before touching critical files, the tool automatically creates a backup (`.bak`) so you never lose your data.
* ⏪ **Safe Revert System:** Made a mistake? Easily restore all original files from backups with a single command (`-r`).
* 🧹 **Workspace Cleanup:** Keep your repository clean! Safely delete all generated `.bak` files once you are satisfied (`-c`).
* 💻 **Interactive CLI:** Choose to update, revert, or clean specific platforms using a beautiful terminal menu with safety confirmations.
* ⚡ **CI/CD Ready:** Use terminal flags (`-a`, `-i`, `-m`) to bypass the interactive menu for automated pipelines.

*(Linux, Windows, and Web support are **Coming Soon!** ⏳)*

---

## 🚀 Getting Started

### 1. Installation

Add the package to your `dev_dependencies` in your `pubspec.yaml` file:

```yaml
dev_dependencies:
  app_name_localizer: ^1.3.0
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

Open your terminal and run the following command from the root of your Flutter project to launch the interactive menu:

```bash
dart run app_name_localizer
```

### Fast CLI Flags
If you want to execute operations directly:

* **Target Android:** `dart run app_name_localizer -a`
* **Target iOS:** `dart run app_name_localizer -i`
* **Target macOS:** `dart run app_name_localizer -m`
* **Revert Changes:** `dart run app_name_localizer -r` 
* **Clean Backups:** `dart run app_name_localizer -c` 
* **Help:** `dart run app_name_localizer -h`

**💡 Pro Tip (Combining Flags):**
You can combine flags to perform highly specific operations!
* Update iOS and macOS only: `dart run app_name_localizer -i -m`
* Clean Android backups only: `dart run app_name_localizer -c -a`

---

## ⚠️ Important Next Steps

After running the tool successfully, it is highly recommended to clean and rebuild your project to ensure the OS picks up the new native files:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 👨‍💻 Developer & Credits

Developed with ❤️ by **Emad Younis (EA)**. 

* 📧 Email: emadeadev@gmail.com
* 🐛 Found a bug or have a feature request? Please open an issue on the GitHub repository!