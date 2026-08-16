# WortSchatz - Software Documentation

## 1. Project Overview

**WortSchatz** is a Flutter-based flashcard learning application that implements an advanced spaced repetition algorithm (inspired by FSRS) for effective vocabulary learning. The app supports multi-language learning with text-to-speech capabilities, local data persistence, and customizable learning settings.

**Primary Goal:** Provide an intuitive platform for language learners to study vocabulary using a smart repetition system where card review intervals are dynamically calculated based on user feedback and memory stability.

---

## 2. Key Features

### Learning & Spaced Repetition
- **FSRS-inspired Algorithm**: Cards are scheduled based on Stability, Difficulty, and Retrievability.
- **Rating System**: Users rate their recall as:
    - **Again**: Complete lapse, resets stability.
    - **Hard**: Difficult recall, small stability increase.
    - **Good**: Successful recall, moderate stability increase.
    - **Easy**: effortless recall, significant stability increase.
- **Smart Review Scheduling**: Automatic scheduling based on the learning algorithm's parameters:
    - Initial learning phase (10m, 1d, 3d intervals).
    - Subsequent intervals based on stability and desired retention.
- **Flip Card Interface**: Tap cards to reveal answers; provide feedback with four distinct rating buttons.

### Multi-Language Support
- **Configurable Language Pairs**: Set source/target languages (e.g., Spanish → German) via Settings.
- **Automatic Translation**: Built-in Google Translate integration (via `translator` package) for auto-filling translations in the editor.
- **Enhanced Text-to-Speech**: Supports speech synthesis for front and back sides with:
    - Independent locale configuration (e.g., `es-ES`, `de-DE`).
    - **Dual Speed Support**: Standard playback rate for normal study and a toggleable **slow rate** (triggered by long-press) for better phonetic understanding.
    - Automatic "Read Answer" toggle for hands-free learning.

### Card Management
- **Full CRUD Operations**: Create, read, update, delete flashcards.
- **Search & Filter**: Search cards by text and sort by priority, review count, stability, difficulty, and review dates.
- **Rich Card Fields**:
    - **Front**: Primary content (usually source language word/phrase)
    - **Back**: Target content (usually translation/definition)
    - **Note**: Additional context or mnemonic hints
    - **Priority**: Toggle to include/exclude cards from learning sessions.
    - **Stability / Difficulty**: Internal algorithm parameters.
- **Bulk Operations**:
    - **JSON Import**: Paste JSON arrays directly.
    - **File Import/Export**: Import from or export to `.json` files.
    - **Global Resets**: Reset all review dates or clear entire database.

### Data Persistence
- **Local SQLite Database**: Powered by **Drift** for efficient local storage and reactive queries.
- **Local Preferences**: **SharedPreferences** for user settings persistence (language codes, TTS settings, learning direction).

### User Settings
- **Learning Direction**: Toggle between front→back or back→front display.
- **Audio Settings**: Enable/disable text-to-speech for both sides, adjust speech rate.
- **Language Configuration**: Set language codes for translation and TTS.

---

## 3. Architecture Overview

WortSchatz follows a **Feature-Driven Architecture** combined with **Riverpod** for state management and dependency injection. The codebase is divided into `core` (shared infrastructure) and `features` (user-facing functionality).

```
lib/
├── core/
│   ├── database/     → Drift SQLite schema and platform connections
│   ├── models/       → Shared data entities (Flashcard, AppSettings)
│   ├── providers/    → Global Riverpod providers (DB, SharedPreferences, TTS)
│   └── services/     → Shared business logic (DatabaseService, TtsService, ImportExportService)
├── features/
│   ├── cards/        → Card listing, searching, and basic CRUD
│   ├── learning/     → FSRS learning logic, session management, and UI
│   ├── settings/     → App preferences management
│   └── import_export/→ Bulk data operations UI
└── main.dart         → App entry point and ProviderScope initialization
```

### Architectural Principles
- **State Management (Riverpod)**: Uses `NotifierProvider` and `StateNotifier` to handle UI state reactively.
- **Persistence (Drift + SQLite)**: A reactive persistence layer that provides streams of data for real-time UI updates.
- **Logic Separation**: The spaced repetition algorithm (FSRS) is decoupled into a dedicated `LearningController` for testability and portability.
- **Service Layer**: Asynchronous operations (TTS, File I/O, Database) are encapsulated in services provided via Riverpod.

---

## 4. Core Components

### 4.1 Data Models (`lib/core/models/`)
- **`Flashcard`**: Represents a single vocabulary item with its memory parameters (stability, difficulty, review dates).
- **`AppSettings`**: Immutable representation of user preferences (language, speech rate, learning direction).

### 4.2 State Notifiers (`lib/features/`)
- **`LearningNotifier`**: Manages the current learning session, handles card rotation, and triggers FSRS updates.
- **`SettingsNotifier`**: Bridges `SharedPreferences` and the UI, ensuring settings changes are persisted and propagated.

### 4.3 Core Services (`lib/core/services/`)
- **`DatabaseService`**: Handles all Drift operations, providing reactive streams for cards and reviewable items.
- **`LearningController`**: The functional core implementing the FSRS-inspired algorithm logic.
- **`TtsService`**: Wraps `flutter_tts` for multi-language speech synthesis.
- **`ImportExportService`**: Manages JSON parsing and file system interactions for bulk operations.

---

### 5. Development & Build

#### Prerequisites
- Flutter SDK
- `build_runner` (for Drift code generation)

#### Generate Database Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### Running the App
```bash
flutter run
```

#### Build & Deploy
```bash
# Android
flutter build apk --release

# Web
flutter build web --release
firebase deploy --only hosting
```
