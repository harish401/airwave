# Airwave 🌊 — Production-Grade Live TV (OTT) Flutter App

**Airwave** is a Netflix / Disney+ Hotstar style live television streaming application built with **Flutter 3 (Dart 3, Null-Safe)** for Android, iOS, and macOS. It uses the public [iptv-org](https://iptv-org.github.io/api/) datasets as its single source of truth without requiring any API keys.

---

## 🏗️ Architecture & Technology Stack

* **Clean Architecture**: Domain / Data / Presentation layer isolation with Repository Pattern.
* **State Management**: [Riverpod 3](https://riverpod.dev) (`Notifier`, `AsyncNotifier`, `ProviderScope`).
* **Routing & Deep Linking**: [GoRouter](https://pub.dev/packages/go_router) supporting `airwave://channel/<id>`.
* **Video Playback**: [media_kit](https://pub.dev/packages/media_kit) (`libmpv` hardware acceleration) with per-stream custom HTTP headers (`Referer`, `User-Agent`) and 8s auto-failover to backup streams.
* **Caching & Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) with 12-hour TTL, stale-while-revalidate strategy, and instant FTS channel search.
* **Networking**: [Dio](https://pub.dev/packages/dio) with concurrent endpoint fetching and backoff retry interceptors.
* **Image Caching & Badging**: [cached_network_image](https://pub.dev/packages/cached_network_image) + [flutter_svg](https://pub.dev/packages/flutter_svg) with fallback initials tiles.

---

## 📱 Screens & Features

1. **Splash & Onboarding**: 3-slide introduction with persistence in `SharedPreferences`. Skippable.
2. **Cinema Home Screen**:
   * Auto-playing Netflix-style Hero Carousel with dark vignette fade, Live tag, category pills, flag, and "Watch Live" CTA.
   * Categorized horizontal rows (60fps smooth scrolling): Continue Watching, My List, Popular Worldwide, Live News, Sports, Movies & Shows, Music, Kids, Documentary, and Regional Languages (Tamil, Hindi, Telugu).
   * Pull-to-refresh & cinematic shimmer skeleton states.
3. **Browse Screen**: Tabs for Categories, Countries (with searchable flags), and Languages with filtered grid view.
4. **Instant Search**: Instant prefix/search across channel names, alternative names, and network owners with recent suggestions.
5. **Comprehensive Filter Sheet**: Combinable filters for country, category, min quality (SD, 480p, 720p, 1080p+), hide geo-blocked, 24/7 channels only, only channels with logo, view mode toggle (Grid/List/Compact), and active badge counter.
6. **Channel Details Sheet**: Stream sources breakdown with resolution badges, website launcher, My List toggle, and native Share.
7. **Production Player**:
   * Portrait (top video + channel details + "More Like This" grid).
   * Fullscreen immersive landscape with auto-rotation and lock toggle.
   * Gestures: tap controls, double-tap mute, vertical swipe on left for brightness and right for volume.
   * Sleep timer (15m, 30m, 45m, 60m), aspect ratio cycle (16:9, fill, 4:3), and channel zapping.
   * 8-second connection timeout with auto-failover notification toast (*"Source X of Y — switching…"*) and friendly error recovery.
8. **Library (My List & History)**: Swipe-to-remove favorites and watch history clearing.
9. **Settings**: Dark/Light/System theme switch, data saver mode, auto-failover toggle, manual catalog sync, and open-source legal disclaimer.

---

## ⚙️ Assumptions & Known Limitations

* **Public Streams Nature**: Channels in this app originate from the public iptv-org directory. Some streams may occasionally experience geo-restrictions or offline periods; the player automatically tries backup sources and fails over gracefully.
* **HTTP Cleartext Traffic**: Several public streams use standard `http://`. Both Android (`usesCleartextTraffic="true"`) and iOS (`NSAllowsArbitraryLoadsInMedia = true`) have been configured accordingly.
* **Hardware Decoding**: Powered by `media_kit` libmpv. Minimum Android SDK is set to 21.

---

## 🚀 How to Run & Build

### Prerequisites
* Flutter 3.22+ / 3.47+
* Xcode (for iOS/macOS) & Android SDK (for Android)

### Run Locally
```bash
# Get dependencies
flutter pub get

# Run on macOS desktop (fastest preview)
flutter run -d macos

# Run on iOS Simulator
open -a Simulator
flutter run -d iPhone

# Run on connected Android Device
flutter run
```

### Build Production Releases
```bash
# Build standalone release APK
flutter build apk --release

# Output path:
# build/app/outputs/flutter-apk/app-release.apk

# Build iOS archive
flutter build ipa --release
```

---

## 🧪 Testing & Code Quality
```bash
# Run analyzer
flutter analyze

# Run unit and repository tests
flutter test
```
