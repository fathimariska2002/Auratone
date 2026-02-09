# PIN + Biometric Offline Flutter App

This minimal Flutter app demonstrates an offline authentication flow using a local PIN and device biometrics (Face ID / Touch ID / Android fingerprint).

Quick start

1. Install Flutter SDK and set up Android/iOS tooling.
2. From project root run:

```bash
flutter pub get
flutter run
```

Platform notes
- Android: No special permissions needed, but ensure your emulator/device supports biometrics.
- iOS: Add `NSFaceIDUsageDescription` to `Info.plist` and enable Keychain & biometric capabilities.
