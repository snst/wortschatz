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
- **Text-to-Speech**: Supports speech synthesis for front and back sides with configurable:
    - Language locales (e.g., `es-ES`, `de-DE`)
    - Speech rate (0.1x to 1.5x)

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

```
WortSchatz Application Structure
├── Core Services (Business Logic)
│   ├── DatabaseService      → Drift SQLite CRUD & Session management
│   ├── LearningController   → Spaced repetition algorithm logic
│   └── SettingsService      → SharedPreferences management
├── Models
│   └── Flashcard            → Data class for flashcard representation
├── UI Views (Presentation Layer)
│   ├── main.dart            → App entry point & theme configuration
│   ├── LearningView         → Main learning interface (FSRS interaction)
│   ├── ManageView           → Card management/listing
│   ├── ImportView           → JSON bulk import interface
│   ├── SettingsView         → User preferences
│   └── CardEditorPage       → Add/Edit card full-screen dialog (in card_dialog.dart)
└── Infrastructure
    ├── database.dart        → Drift database schema definition
    └── database_connection/ → Platform-specific database connections
```

### Architectural Pattern: Service-Locator + Reactive Streams
- **Services**: Singleton-like services handle business logic (DB, Settings, Learning).
- **Reactive Queries**: Uses Drift's `watch()` to provide real-time UI updates when the database changes.
- **Stateful Widgets**: UI state management for local UI control (card flip, loading states).

---

## 4. Core Classes & Interactions

### 4.1 `Flashcard` (Model)
**File**: `flashcard.dart`

**Purpose**: Data class representing a single flashcard with its learning state.

**Key Attributes**:
- `id` (int): Unique database primary key.
- `front` (String): Front side content.
- `back` (String): Back side content.
- `note` (String): Optional additional notes.
- `priority` (int): 1 if included in learning, 0 if excluded.
- `stability` (double): Memory stability (time until retrievability falls to 90%).
- `difficulty` (double): Relative difficulty of the card (1-10).
- `reviewCount` (int): Total number of times card has been reviewed.
- `lastReview` (DateTime): Timestamp of the last review.
- `nextReview` (DateTime): Next scheduled review timestamp.

---

### 4.2 `LearningController` (Service)
**File**: `learning_controller.dart`

**Purpose**: Implements the spaced repetition algorithm (FSRS-inspired).

**Key Methods**:
```dart
answer(card, rating)   // Calculates new stability, difficulty, and nextReview
                       // based on the user's Rating (Again, Hard, Good, Easy)
calculateNextInterval(card) // Determines interval in days based on stability
```

**Algorithm Details**:
- **Retrievability**: Probability of recall based on stability and time elapsed.
- **Difficulty Adjustment**: Updates based on rating, clamped between 1.0 and 10.0.
- **Stability Growth**: Increases when successful, decreases (or resets) on failure.
- **Initial Phase**: Fixed steps for first few reviews (10m, 1d, 3d).

---

### 4.3 `DatabaseService` (Service)
**File**: `database_service.dart`

**Purpose**: Central hub for Drift operations with local buffering for performance.

**Key Methods**:

#### Data Streams:
```dart
get allCards         // Stream<List<Flashcard>> - reactive stream of all cards
get reviewableCards  // Stream<List<Flashcard>> - buffered stream of due cards
```

#### CRUD & Batch Operations:
```dart
addCard(front, back, note, learnCard)  // Creates new card
addCards(List<Flashcard>)              // Batch import via Drift batch
updateCard(id, front, back, note, learnCard)
deleteCard(id)
```

#### Learning Progression:
```dart
updateLearningProgress(card) // Updates database with new algorithm parameters
fetchNewCards()              // Forces fetching a new batch of cards
resetLearningProgress()      // Resets stability/difficulty for all cards
```

---

### 4.4 `SettingsService` (Service)
**File**: `settings_service.dart`

**Purpose**: Manages user preferences using `SharedPreferences`.

**Managed Settings**:
- Learning direction (Front→Back or Back→Front).
- TTS enabled/disabled for each side.
- Language locales for TTS and translation.
- Speech rate.

---

### 5. Development & Build

#### Prerequisites
- Flutter SDK
- `build_runner` (for Drift code generation)

#### Generate Database Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Running the App
```bash
flutter run
```

#### Build Release
```bash
# Android
flutter build apk --release

# Web
flutter build web --release

firebase deploy --only hosting
flutter run -d web-server
```
