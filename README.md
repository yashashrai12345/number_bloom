# Number Bloom: Merge Puzzle

An original, polished, relaxing offline-first 4×4 number merging puzzle for Android built with Flutter.

---

## 🌸 Overview

**Number Bloom** is a clean, tranquil number puzzle inspired by the merge mechanic. Slide tiles across a 4×4 garden-styled board to merge equal numbers and cultivate a **2048** bloom.

- **Offline-First**: Play anywhere, anytime without internet connection or account requirements.
- **Save & Resume**: Game state is persistently committed after every valid move.
- **Haptic & Sound Toggles**: Customizable sensory feedback and reduced-motion options.
- **AdMob Integration**: Clean banner and non-intrusive interstitial ads with strict frequency cooldowns (180s) that never interrupt gameplay.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter 3.47+ (Dart ^3.13)
- **Target Platform**: Android (minSdk 21+, targetSdk 34+)
- **State Management**: `flutter_riverpod` (v3)
- **Local Persistence**: `shared_preferences` with validated JSON schema snapshots
- **Monetization**: `google_mobile_ads` (Google Mobile Ads SDK)

### Architecture Layers
```
lib/
├── core/                  # Design tokens, theme, constants, accessibility
├── features/
│   ├── game/
│   │   ├── domain/        # Pure Dart engine (board, move logic, scoring, RNG)
│   │   ├── application/   # Game controller, Riverpod state notifiers
│   │   ├── data/          # Game repository & local serialization
│   │   └── presentation/  # Game screen, 4x4 board, tiles, overlays
│   ├── home/              # Home screen, start/continue flow
│   ├── settings/          # Player settings (theme, haptics, reduced motion)
│   └── stats/             # Local statistics (games played, highest tile)
├── services/
│   ├── ads/               # Centralized AdMob service with cooldown & test IDs
│   └── persistence/       # Local key-value & save migration store
└── main.dart              # Entrypoint
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.24+ (tested on Flutter 3.47.1)
- Android SDK (API 34/35/36)
- Java 17+

### Setup Commands
```bash
# Clone the repository and navigate to root
cd number_bloom

# Fetch dependencies
flutter pub get

# Verify code analysis
flutter analyze

# Run unit and widget tests
flutter test
```

### Running Locally
```bash
# Run on connected Android emulator or physical device
flutter run -d emulator-5554

# Or target Windows/Web for UI iteration
flutter run -d chrome
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run game engine domain unit tests specifically
flutter test test/unit/game_rules_test.dart
flutter test test/unit/spawn_test.dart
flutter test test/unit/game_over_test.dart
flutter test test/unit/persistence_test.dart
```

### Building for Release
```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Google Play)
flutter build appbundle --release
```

---

## 🛡️ Monetization & Test Ad Configuration
This project is configured with official Google AdMob test IDs:
- **Test App ID**: `ca-app-pub-3940256099942544~3347511713`
- **Test Banner ID**: `ca-app-pub-3940256099942544/6300978111`
- **Test Interstitial ID**: `ca-app-pub-3940256099942544/1033173712`

For production deployment, provide publisher ad unit IDs via `AdConfig` and replace the application metadata in `AndroidManifest.xml`.
