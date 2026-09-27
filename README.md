# Computer Engineering Companion

An offline-first Flutter study and engineering toolkit for Computer Engineering students. The redesigned product unifies learning, quizzes, engineering tools, CPU scheduling, progress, notes, and settings in one Material 3 experience.

## Features

- Adaptive Home, Learn, Practice, Tools, and Settings navigation: `NavigationBar` on phones and `NavigationRail` on tablets and desktops.
- Subject-driven learning library for programming, architecture, operating systems, networks, logic, electronics, embedded systems, communications, signals, and mathematics.
- Riverpod-backed quiz sessions with multiple-choice, true/false, and multiple-answer seed questions.
- Engineering tool catalogue and CPU scheduling workspace.
- Local notes, bookmarks-ready data model, progress and recent activity.
- Material 3 light, dark, and system appearance modes.

## Screens and wireframe

```
Home → study progress → continue learning → quick tools → activity
Learn → search/filter → subjects → lessons/topics
Practice → quiz modes → simulators
Tools → Electronics | Logic | Networking | Computer Systems
Settings → Profile | Appearance | Learning | Data | About
```

## Architecture

```
Widgets → Riverpod providers → CompanionRepository → SQLite schema / offline seed data
```

The project has one presentation architecture and one state-management system: Riverpod. Quiz, subject, profile, note, and theme state stay outside widgets. The repository is the data boundary.

## Folder structure

```
lib/
  app/                 application root and Riverpod providers
  core/                theme, constants, shared UI
  data/local/database/ versioned schema, migrations, seed data
  data/repositories/   offline repository boundary
  domain/entities/     immutable product entities
  features/            home, learning, practice, tools, simulators, settings, navigation
```

## SQLite and migrations

The database is `engineering_companion.db`. The schema includes subjects, lessons, topics, quiz questions/options/attempts/answers, progress, bookmarks, notes, recent activity, study sessions, programming references, and formulas. Migrations are additive by design: never reset a production database during an upgrade.

## Responsive design

Mobile is below 600 px, tablet is 600–1024 px, and desktop is above 1024 px. Content is constrained on wide screens and navigation changes to a rail at tablet size.

## Development and testing

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

Android keeps the existing AGP 8.11.1, Gradle 9.1.0, Kotlin 2.2.20, Java 17 compile target, and Flutter-provided SDK values; no random upgrades are needed.

## Troubleshooting

- If Flutter reports SDK-cache permissions, repair the local Flutter installation/cache rather than modifying `.pub-cache`.
- SQLite requires a supported platform implementation; seed data keeps the UI usable during development.

## Technical debt and future AI

The calculator catalogue is structured before every individual calculator is implemented. Future work should extend repository CRUD to every entity and add additive migrations. AI/cloud sync is intentionally absent; a future optional service must sit behind the repository and never block offline use.
# computer_engineering_companion
