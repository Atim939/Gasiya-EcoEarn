# Gasiya – Flutter app

## Paste into your project
1. Replace your project's `lib/` folder with this `lib/` folder (or copy the contents in).
2. Add the three packages in `pubspec_additions.yaml` to your `pubspec.yaml`, then run `flutter pub get`.
3. Android: in `android/app/src/main/AndroidManifest.xml`
   - inside `<manifest>` (above `<application>`) add:
     `<uses-permission android:name="android.permission.INTERNET"/>`
   - also inside `<manifest>` add (so maps/call links open):
     ```xml
     <queries>
       <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
       <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
     </queries>
     ```
4. iOS (`ios/Runner/Info.plist`), add inside `<dict>`:
   ```xml
   <key>NSCameraUsageDescription</key><string>Take photos of your waste and products</string>
   <key>NSPhotoLibraryUsageDescription</key><string>Choose photos of your waste and products</string>
   <key>LSApplicationQueriesSchemes</key><array><string>https</string><string>tel</string></array>
   ```
5. Run: `flutter run`   |   APK: `flutter build apk --release`

## Demo login
Phone `0770000000`, password `Gasiya@123`. Every OTP code is `123456`.

## What is demo / placeholder
- All data lives in memory (resets on restart): `providers/app_data.dart`, `providers/auth_provider.dart`.
- Sample products, collection points, stories, reviews: `data/mock_data.dart`.
- Rates per kg, categories and photo URLs: `config/waste_config.dart`.
- USSD code, About text, documents: marked with `TODO`.
