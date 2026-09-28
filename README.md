# Computer Engineering Companion

An offline-first Flutter learning platform for Computer Engineering students — a digital textbook, engineering calculator, quiz platform, programming reference, and study tracker in one mobile-first app.

## Project Overview

Everything runs locally on the device. No account, no network, no cloud. SQLite is the primary store; the curriculum, quizzes, formulas, and programming references are seeded on first launch, and all user data (progress, notes, bookmarks, quiz history) persists across restarts.

## Features

- **Full curriculum** — 15 subjects, 340 lessons, each with concept, definition, formula, explanation, worked example, engineering example, and common mistakes
- **Quizzes** — 665 questions across all subjects, 7 question types, per-lesson and per-subject modes, quick quiz, timed exam mode, and mistake review
- **Calculators** — number systems, binary, bitwise, electronics, physics, calculus, networking
- **Simulator** — CPU scheduling (FCFS, SJF, SRTF, Round Robin, Priority) with Gantt chart and full metrics
- **Formula library** — 39 searchable, bookmarkable, copyable formulas with variables and applications
- **Programming reference** — 39 code snippets across C, C++, Python, Java, and Dart/Flutter
- **Study tools** — notes, bookmarks, real progress tracking, study streaks, dark/light/system themes

## Curriculum

| Subject | Lessons | Subject | Lessons |
|---|---|---|---|
| C Programming | 20 | Digital Logic | 31 |
| C++ | 18 | Electronics | 26 |
| Python | 20 | Embedded Systems | 22 |
| Java | 16 | Data Communications | 24 |
| Dart / Flutter | 16 | Calculus | 25 |
| Computer Architecture | 23 | Physics | 37 |
| Operating Systems | 22 | Engineering Mathematics | 15 |
| Computer Networks | 25 | **Total** | **340** |

## Architecture

```
UI (features/)
   ↓
Riverpod Providers (app/app_providers.dart)
   ↓
Domain Services (domain/services/)
   ↓
Repositories (data/repositories/)
   ↓
SQLite (data/local/database/)
```

UI never touches SQL or SharedPreferences directly. All calculation and scheduling logic lives in pure Dart services with no Flutter dependency, so it is directly unit-testable.

## Riverpod State Management

Riverpod is the single application-level state framework:

- `Provider` — repository, services
- `FutureProvider` / `FutureProvider.family` — subjects, lessons, notes, formulas
- `AsyncNotifierProvider` — theme, profile name, notes, bookmarks (persist on write)
- `setState()` only for ephemeral widget-local state (text controllers, selected tab)

## Offline-First

All core functionality works with no internet, authentication, or AI API. `SharedPreferences` stores simple preferences (theme, profile name); SQLite stores everything else. Future cloud/AI integration points are isolated behind the repository interface.

## Database & Migrations

Database: `engineering_companion.db` (version 2), with 14 tables:

`subjects`, `lessons`, `topics`, `quiz_questions`, `quiz_options`, `quiz_attempts`, `quiz_answers`, `progress`, `bookmarks`, `notes`, `recent_activity`, `study_sessions`, `programming_references`, `formulas`

Migrations are additive and data-preserving (`lib/data/local/database/database_migrations.dart`). Seeding runs **outside** the `onCreate` transaction in a single batch, so it is fast and does not deadlock. Reset is an explicit user action in Settings.

## Responsive Design

Verified on the Pixel 8 emulator (1080×2400). Below 600dp the app uses a bottom `NavigationBar`; at 600dp+ it switches to a `NavigationRail` (extended above 1024dp). Content is width-constrained to a readable measure and scrolls vertically, so there is no horizontal overflow at 320px and above.

## Testing

```bash
flutter analyze   # 0 errors
flutter test      # 152 tests passing
```

Unit tests cover number-base conversion, binary and bitwise arithmetic, Ohm's law and circuit analysis, physics formulas, calculus (parsing, derivative, integrals, limits, Riemann sums, Newton–Raphson), subnetting/CIDR/data-rate maths, all five CPU scheduling algorithms, and quiz scoring.

## Development Setup

```bash
flutter pub get
flutter run -d <device-id>
```

## Android Emulator Setup

```bash
flutter emulators                     # list AVDs
flutter emulators --launch Pixel_8    # start it
adb devices                           # expect: emulator-5554  device
flutter devices                       # expect the emulator listed
flutter run -d emulator-5554
```

## Build

```bash
flutter build apk --debug     # build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release
```

## Regenerating the Curriculum

The curriculum seed is generated, not hand-written:

```bash
python3 tool/generate_curriculum.py
```

Source lives in `tool/curriculum_*.py`; output is `lib/data/local/database/curriculum_data.dart`. Edit the Python files, not the generated Dart.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `no devices/emulators found` | `adb kill-server && adb start-server`, then `flutter emulators --launch Pixel_8` |
| Blank screen on first launch | First launch seeds 340 lessons; wait a few seconds |
| `main has not been registered` | Check `lib/main.dart` for a valid `main()` and pre-`runApp` exceptions |
| Gradle plugin not found | Verify `google()`, `mavenCentral()`, `gradlePluginPortal()` in `android/settings.gradle.kts` |
| Want a clean database | Settings → Data → Reset all data |

## Known Limitations

- The calculus calculator handles polynomial expressions (e.g. `3x^2 + 2x - 5`), not arbitrary symbolic input; unsupported input returns a clear validation message rather than a wrong answer.
- The app window may letterbox on some emulator window sizes; layout itself is responsive.
- Notes support title, body, and subject linking; no rich text or attachments.

## Future AI Architecture

Domain services are pure functions, so AI-assisted features (explain-a-formula, generate practice problems, spaced-repetition scheduling) can be added behind the same repository/service interfaces without touching the UI layer — preserving offline operation with optional online augmentation.
