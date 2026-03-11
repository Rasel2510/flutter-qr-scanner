# QRcraft Flutter App

Modern dark-themed QR Code Generator & Scanner built with Flutter.

## Folder Structure

```
lib/
├── main.dart                                     ← Entry point
├── core/
│   ├── theme/
│   │   └── app_theme.dart                        ← Colors, text styles, ThemeData
│   └── utils/
│       ├── qr_history_item.dart                  ← Model: QRHistoryItem, QRType, QRMode
│       └── history_manager.dart                  ← SharedPreferences read/write
├── features/
│   ├── generate/
│   │   ├── presentation/
│   │   │   └── generate_screen.dart              ← Generate QR screen
│   │   └── widgets/
│   │       ├── qr_type_selector.dart             ← URL/Text/Email/Phone/WiFi tabs
│   │       ├── qr_input_form.dart                ← Dynamic input fields per type
│   │       ├── qr_customize_options.dart         ← Colors, size, error correction
│   │       └── qr_preview_widget.dart            ← QR display + download/share/copy
│   ├── scan/
│   │   ├── presentation/
│   │   │   └── scan_screen.dart                  ← Scan screen (camera + upload)
│   │   └── widgets/
│   │       └── scan_result_widget.dart           ← Scan result card
│   └── history/
│       ├── presentation/
│       │   └── history_screen.dart               ← History with filter tabs
│       └── widgets/
│           └── history_card.dart                 ← History list card widget
└── shared/
    └── widgets/
        ├── main_screen.dart                      ← IndexedStack + bottom nav
        ├── app_bottom_nav_bar.dart               ← Bottom nav bar widget
        └── app_widgets.dart                      ← AppCard, AppButton, AppBadge, etc.
```

## Dependencies

```yaml
qr_flutter: ^4.1.0          # QR generation
mobile_scanner: ^5.2.3      # QR scanning via camera
image_picker: ^1.1.2        # Pick image from gallery
shared_preferences: ^2.3.3  # History storage
share_plus: ^10.1.4         # Share QR image
path_provider: ^2.1.4       # Save QR to disk
flutter_svg: ^2.0.10+1      # SVG support
gap: ^3.0.1                 # Spacing
```

## Setup

1. Add dependencies:
```bash
flutter pub get
```

2. Add permissions (see PERMISSIONS.md):
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/Info.plist`

3. Run:
```bash
flutter run
```

## Features
- **Generate** — URL, Text, Email, Phone, WiFi QR codes
- **Customize** — foreground/background color, size, error correction
- **Save/Share** — download as PNG or share
- **Scan** — live camera scanning with animated frame
- **Gallery** — scan from image in gallery
- **History** — all codes saved locally, filter by generated/scanned
- **Delete** — individual delete or clear all history
