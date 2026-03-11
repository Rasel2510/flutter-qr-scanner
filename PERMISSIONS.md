# Add these permissions to android/app/src/main/AndroidManifest.xml
# inside the <manifest> tag:

# <uses-permission android:name="android.permission.CAMERA" />
# <uses-feature android:name="android.hardware.camera" android:required="false" />
# <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
# <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
# <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

# For mobile_scanner, also add inside <application>:
# android:requestLegacyExternalStorage="true"

# ── iOS ──────────────────────────────────────────────────
# Add these to ios/Runner/Info.plist:

# <key>NSCameraUsageDescription</key>
# <string>QRcraft needs camera access to scan QR codes</string>
# <key>NSPhotoLibraryUsageDescription</key>
# <string>QRcraft needs photo library access to scan QR codes from images</string>
