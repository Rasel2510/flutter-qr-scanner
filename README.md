<div align="center">

<img src="assets/qr_scanner.png" width="96" alt="QRCraft Logo" />

# QRCraft

**A warm, cozy QR code scanner & generator for Android**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)
[![Release](https://img.shields.io/badge/Release-v1.0.0-FFE53B?labelColor=141414)](#-download)

</div>

---

## 📥 Download

> Pick the APK that matches your device architecture. If unsure, download **arm64-v8a** — it covers most modern Android phones.

| Architecture | Target Devices | Download |
|---|---|---|
| **arm64-v8a** | Most modern phones (2017+) | [Download APK](https://github.com/Rasel2510/flutter-qr-scanner/releases/latest/download/app-arm64-v8a-release.apk) |
| **armeabi-v7a** | Older / 32-bit phones | [Download APK](https://github.com/Rasel2510/flutter-qr-scanner/releases/latest/download/app-armeabi-v7a-release.apk) |
| **x86_64** | Emulators / Intel phones | [Download APK](https://github.com/Rasel2510/flutter-qr-scanner/releases/latest/download/app-x86_64-release.apk) |

> **Note:** Enable *"Install from unknown sources"* in your Android settings before installing.

---

## ✨ Features

### 📷 Scan
- Scan QR codes in real-time using the camera
- Upload an image from gallery and extract the QR code
- Auto-detects content type: URL, Email, Phone, Wi-Fi, Text
- One-tap **Copy**, **Open**, or **Connect to Wi-Fi**
- Light haptic feedback on successful scan

### 🎨 Generate
- Create QR codes for URLs, emails, phones, Wi-Fi credentials, or plain text
- Customize foreground & background color
- Adjust output size and error-correction level
- Save to gallery or share directly

### 🕘 History
- All scanned and generated QR codes saved automatically
- Filter by **All**, **Scanned**, or **Generated**
- Delete individual items or clear all history

---

## 🎨 Theme — Cozy Pop

QRCraft uses a warm neo-brutalist design system:

| Token | Value | Role |
|---|---|---|
| Background | `#FFF3E4` | Scaffold / page background |
| Surface | `#FFFAF2` | Cards, sheets, nav bar |
| Ink | `#141414` | Text, borders, shadows |
| Primary | `#FFE53B` | Buttons, FAB, active tab |
| Secondary | `#F2695C` | Coral accent |
| Info | `#7FD1EA` | Sky blue accent |
| Success | `#6CC24A` | Green accent |
| Error | `#E5484D` | Destructive actions |

- **Font:** Lexend (Google Fonts) — w700 titles, w600 labels, regular body
- **Borders:** 2px solid ink on every interactive element
- **Shadows:** Hard 4px offset, no blur — true neo-brutalist style
- **Corners:** 14px cards/buttons · pill inputs & nav bar · 24px bottom sheets

---

## 🏗️ Project Structure

```
lib/
├── main.dart                        # App entry point, theme setup
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          # All color constants (AppColors)
│   │   └── app_theme.dart           # ThemeData — Material 3, Lexend, component themes
│   ├── widgets/
│   │   ├── neo_box.dart             # Reusable neo-brutalist card with hard shadow
│   │   └── scan_frame.dart          # Scanner overlay — corners, dark mask, scan line
│   ├── providers/
│   │   ├── scan_provider.dart       # Riverpod state for scan screen
│   │   ├── history_provider.dart    # Riverpod state for history
│   │   └── generate_provider.dart   # Riverpod state for generator
│   └── utils/
│       ├── qr_history_item.dart     # QR item model + type detection
│       └── history_manager.dart     # SharedPreferences persistence
│
├── features/
│   ├── scan/
│   │   ├── presentation/
│   │   │   └── scan_screen.dart     # Camera / upload scan UI
│   │   └── widgets/
│   │       ├── camara_section.dart  # Live camera preview widget
│   │       ├── upload_section.dart  # Gallery pick UI
│   │       └── scan_result_widget.dart  # Result card with action buttons
│   │
│   ├── history/
│   │   ├── presentation/
│   │   │   └── history_screen.dart  # History list + empty state
│   │   └── widgets/
│   │       ├── history_card.dart    # NeoBox history item card
│   │       └── filter_tabs.dart     # All / Scanned / Generated tabs
│   │
│   └── generate/
│       ├── presentation/
│       │   └── generate_screen.dart # QR generator UI
│       └── widgets/
│           ├── qr_type_selector.dart    # URL / Email / Phone / Wi-Fi / Text picker
│           ├── qr_input_form.dart       # Dynamic input fields per type
│           ├── qr_customize_options.dart # Color & size controls
│           └── qr_preview_widget.dart   # Live QR preview + save/share
│
└── shared/
    └── widgets/
        ├── main_screen.dart         # Root scaffold + IndexedStack navigation
        ├── app_bottom_nav_bar.dart  # Floating pill nav bar (Scan / History / Generate)
        └── app_widgets.dart         # Shared UI helpers
```

---

## 🛠️ Tech Stack

| Package | Purpose |
|---|---|
| `mobile_scanner` | Camera-based QR scanning |
| `qr_flutter` | QR code rendering |
| `image_picker` | Gallery image selection |
| `shared_preferences` | Local history persistence |
| `flutter_riverpod` | State management |
| `google_fonts` | Lexend font (Cozy Pop theme) |
| `share_plus` | Native share sheet |
| `url_launcher` | Open URLs, emails, phone dialer |
| `wifi_iot` | Wi-Fi QR auto-connect |
| `gal` | Save QR image to gallery |

---

## 🚀 Build from Source

**Requirements:** Flutter 3.x · Android SDK · Java 17+

```bash
# 1. Clone
git clone https://github.com/Rasel2510/flutter-qr-scanner.git
cd flutter-qr-scanner

# 2. Install dependencies
flutter pub get

# 3. Run on device / emulator
flutter run

# 4. Build split APKs (release)
flutter build apk --split-per-abi --release
# Output: build/app/outputs/flutter-apk/
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ and Flutter · **Cozy Pop** theme

</div>
