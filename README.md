# SciCalc Pro – Flutter Scientific Calculator

A production-ready, full-featured scientific calculator app built with Flutter.  
Clean Architecture · Riverpod · Hive · fl_chart · Custom Math Engine

## 🏗 Architecture

```
lib/
├── main.dart                          # App entry point, Hive init
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Dark/Light Material 3 themes
│   ├── utils/
│   │   └── math_engine.dart           # Custom Shunting-Yard evaluator
│   └── constants/
│       └── calculator_constants.dart  # Button types, math constants
├── features/
│   ├── calculator/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── main_shell.dart        # Bottom nav shell
│   │   │   │   ├── calculator_screen.dart # Main calculator UI
│   │   │   │   └── history_screen.dart    # Swipe-to-delete history
│   │   │   ├── widgets/
│   │   │   │   ├── calc_button.dart       # Animated button widget
│   │   │   │   ├── button_grid.dart       # Portrait + Landscape grids
│   │   │   │   └── display_widget.dart    # Animated display
│   │   │   └── providers/
│   │   │       └── calculator_provider.dart # Riverpod StateNotifier
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── calculator_state.dart  # Immutable state model
│   │   │       └── history_entry.dart     # Hive model
│   │   └── data/
│   │       └── repositories/
│   │           └── history_repository.dart # Hive CRUD operations
│   ├── graph/
│   │   └── presentation/
│   │       └── screens/
│   │           └── graph_screen.dart      # fl_chart graph plotter
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart   # Settings + constants page
└── test/
    ├── unit/
    │   └── math_engine_test.dart          # 40+ math engine tests
    └── widget/
        └── calculator_screen_test.dart    # Widget smoke tests
```

---

## ✨ Features

### Calculator Tab

- **All basic operations**: +, −, ×, ÷, %, decimal, negative
- **Scientific functions**: sin/cos/tan, arcsin/arccos/arctan, log, ln, √, x², xʸ, π, e, n!, abs()
- **Hyperbolic**: sinh, cosh, tanh
- **2nd mode** toggle: switches to inverse trig (sin⁻¹, cos⁻¹, tan⁻¹)
- **Degree/Radian toggle** with RAD/DEG badge on display
- **Live preview**: see result as you type before pressing =
- **Memory operations**: MC, MR, M+, M−, MS
- **Backspace** (hold to clear all)
- **Toggle sign** (+/−)
- **Copy result** by long-pressing the display
- **Landscape mode** reveals extra functions (sinh/cosh/tanh, exp, log₂, etc.)
- **Tablet-optimized** with max width constraints
- Smooth **60fps animations** on buttons and result display

### History Tab

- All calculations saved automatically with Hive
- **Swipe to delete** individual entries
- **Tap to reuse** any result in the calculator
- **Copy** individual results to clipboard
- **Export as CSV** (copies to clipboard)
- **Clear all** with confirmation dialog
- Relative timestamps ("2m ago", "Yesterday")

### Graph Tab

- Plot any function **y = f(x)**
- **Two simultaneous functions** (toggle second function)
- Adjustable **x-range** with real-time replot
- **RAD/DEG toggle** for trig functions
- Grid lines with axis labels
- **Touch tooltip** showing exact x, y coordinates
- Supports: sin, cos, tan, log, ln, sqrt, abs, x², and all engine functions

### Settings Tab

- **Dark / Light theme** toggle
- **Scientific constants reference** (π, e, φ, c, g, h, Nₐ)
- **Keyboard tips** panel
- App version and architecture info

---

## 🧮 Math Engine

The custom `MathEngine` uses the **Shunting-Yard algorithm** to parse and evaluate mathematical expressions:

- Correct **operator precedence**: `2+3*4 = 14` ✓
- **Parentheses** support: `(2+3)*4 = 20` ✓
- **Unary negation**: `-5*2 = -10` ✓
- **Scientific notation**: `1.5e10 + 1` ✓
- **Implicit multiplication**: `2(3+4) = 14` ✓
- **Error safety**: division by zero, √ of negative, invalid syntax → returns null (no crashes)
- **40+ unit tests** covering arithmetic, trig, logs, factorial, edge cases

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code with Flutter extension

### 1. Create Flutter project

```bash
flutter create scicalc_pro
cd scicalc_pro
```

### 2. Replace files

Copy all files from this package into the `scicalc_pro/` folder, replacing the default `lib/` directory.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
# Debug mode
flutter run

# Specific device
flutter run -d chrome      # Web
flutter run -d emulator    # Android emulator
flutter run -d "iPhone 15" # iOS simulator
```

### 5. Run tests

```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Verbose output
flutter test --reporter=expanded
```

---

## 📦 Building for Production

### Android APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (optimized)
flutter build apk --release

# Split APKs by ABI (smaller file size)
flutter build apk --split-per-abi --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS + Xcode)

```bash
flutter build ios --release
# Then archive and upload via Xcode Organizer
```

### Web

```bash
flutter build web --release
# Output: build/web/
```

---

## 🏪 Publishing to Google Play Store

### Step 1: Generate signing key

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### Step 2: Configure signing in `android/key.properties`

```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=upload
storeFile=<path-to>/upload-keystore.jks
```

### Step 3: Update `android/app/build.gradle`

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Step 4: Build and upload

```bash
flutter build appbundle --release
# Upload build/app/outputs/bundle/release/app-release.aab to Play Console
```

### Step 5: Play Console Setup

1. Go to [play.google.com/console](https://play.google.com/console)
2. Create new app → Enter details
3. Complete Store Listing (screenshots, description, icon)
4. Upload AAB to Internal Testing track
5. Review → Release to production

---

## 📋 Dependencies

| Package          | Version | Purpose               |
| ---------------- | ------- | --------------------- |
| flutter_riverpod | ^2.4.9  | State management      |
| hive_flutter     | ^1.1.0  | Local history storage |
| fl_chart         | ^0.66.0 | Graph plotting        |
| intl             | ^0.18.1 | Date formatting       |

---

## 🎨 Design System

- **Dark theme**: Deep `#0D0D0F` background with `#1A1A1F` surface
- **Light theme**: `#F5F5F7` background with white cards
- **Accent**: `#4F7BFF` blue (buttons, badges, highlights)
- **Typography**: Lightweight (w300) large numerals, w600 operator buttons
- **Animations**: Scale bounce on tap, slide + fade on result update, pulse on equals

---

## 🧪 Testing

The test suite covers:

- **40+ unit tests** for the math engine (arithmetic, trig, logs, power, factorial, error cases)
- **Widget tests** for screen rendering and button interactions
- **Edge cases**: division by zero, empty input, invalid syntax, very large numbers

Run with:

```bash
flutter test --coverage
```

---

## 📈 Performance Notes

- **Optimized rebuilds**: Riverpod `select` prevents unnecessary widget rebuilds
- **Hive vs SQLite**: Hive provides ~10x faster reads for simple key-value history
- **60fps animations**: All animations use `AnimationController` with `vsync`, no `Future.delayed`
- **Memory**: History capped at 200 entries to prevent unbounded growth

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/graph-3d`
3. Run tests: `flutter test`
4. Submit a PR with description of changes

---

_Built with ❤️ using Flutter — SciCalc Pro v1.0.0_
