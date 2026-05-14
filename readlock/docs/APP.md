# App Architecture Reference

Structure, screens, services, and content rendering for the Readlock Flutter app.

## Folder Structure

```
lib/
  bottom_sheets/      Modal sheets (login, settings, purchases, feathers)
  constants/          Firebase config, design tokens, typography, encryption, course colors
  course_screens/     Reading experience, roadmaps, content widgets (CC*), course services
  design_system/      Reusable components (buttons, cards, blur, icons, animations)
  models/             Data models (UserModel, CourseProgressModel, PurchasedCourseModel, AppConfig)
  screens/            Main screens (Home, Courses, Bookshelf, Profile, Onboarding)
  services/           Business logic (auth, purchases, notifications, haptics, sounds, logging)
  utility_widgets/    Text animation widgets (RSVP, progressive text, bionic reading)
  main.dart           Entry point
  MainNavigation.dart Bottom tab navigation
```

---

## Initialization Sequence (main.dart)

```
1. WidgetsFlutterBinding.ensureInitialized()
2. silenceEngineWindowAssertionSpam()          // Filter platform noise
3. Firebase.initializeApp()
4. FirebaseAppCheck.activate()                 // DeviceCheck (prod) / debug (dev)
5. NightShiftBrightnessService.initialize()    // Screen brightness control
6. NightShiftScheduleService.initialize()      // Sunrise/sunset auto-warmth
7. ConnectivityService.initialize()            // Network reachability monitor
8. StoreKitService.initialize()                // App Store products + purchase stream
9. ScreenProtectionService.enableProtection()  // Block screenshots, blur in switcher
10. runApp(ReadlockApp())
```

---

## Screens

| Screen              | Path                                          | Tab                    |
| ------------------- | --------------------------------------------- | ---------------------- |
| HomeScreen          | `lib/screens/HomeScreen.dart`                 | Tab 0                  |
| CoursesScreen       | `lib/screens/CoursesScreen.dart`              | Tab 1                  |
| MyBookshelfScreen   | `lib/screens/MyBookshelfScreen.dart`          | Tab 2                  |
| ProfileScreen       | `lib/screens/profile/ProfileScreen.dart`      | Push from Home         |
| OnboardingScreen    | `lib/screens/OnboardingScreen.dart`           | Post-registration      |
| VerifyEmailScreen   | `lib/screens/VerifyEmailScreen.dart`          | Post-signup            |
| CourseRoadmapScreen | `lib/course_screens/CourseRoadmapScreen.dart` | Push from course card  |
| CourseContentViewer | `lib/course_screens/CourseContentViewer.dart` | Push from roadmap node |

---

## State Management

No Provider, Riverpod, or BLoC. Pure `ValueNotifier` + `ValueListenableBuilder` throughout.

Global notifiers live at module level. Screens subscribe on build, update via async service calls. See `FIREBASE_BACKEND.md` for the notifier list.

---

## Reading Experience Flow

### Roadmap (CourseRoadmapScreen)

1. Displays vertical list of lesson nodes connected by path lines
2. Nodes show lesson number + lock/unlock state
3. Unlock rule: `lessonIndex <= courseProgressNotifier.value[courseId].currentLessonIndex`
4. Purchase gate: course must be in `purchasedCoursesNotifier`
5. Tapping an unlocked node pushes CourseContentViewer

### Content Viewer (CourseContentViewer)

1. Receives courseId, lessonIndex, accent color
2. Fetches encrypted content via `fetchLessonContent` Cloud Function
3. Decrypts via `ContentEncryption.decryptLessonPayload()`
4. Renders content items in vertical PageView (one swipe = one item)
5. Content types: text, question, true-false-question, estimate, reflect, quote, pause
6. Per-session Stopwatch tracks reading time
7. Finish page shows bird + animated time readout
8. Finish CTA calls `UserService.advanceCourseProgress(nextLessonIndex)`
9. On dispose, `commitReadingTime()` bumps `timeSpentReading` (capped at 10 min)

### Content Rendering (CC\* widgets)

Factory: `lib/course_screens/widgets/CCJSONContentFactory.dart`

Each content type maps to a CC-prefixed widget. Text content renders via either:

- **ProgressiveText** (default): typewriter reveal, one segment at a time
- **RSVPText** (toggle): one word at a time, Spritz-style ORP highlighting

Selection driven by `rsvpEnabledNotifier`.

---

## Content Types

All content items are JSON objects with a `type` field. Factory switches on type:

| Type                | Widget             | Interaction                        |
| ------------------- | ------------------ | ---------------------------------- |
| text                | CCTextContent      | Progressive reveal or RSVP         |
| question            | CCQuestionContent  | Multiple choice, feedback snackbar |
| true-false-question | CCTrueFalseContent | Binary choice                      |
| estimate            | CCEstimateContent  | Numeric guess                      |
| reflect             | CCReflectContent   | Open-ended prompt                  |
| quote               | CCQuoteContent     | Styled quote block                 |
| pause               | CCPauseContent     | Breathing pause between sections   |

---

## Onboarding Flow

File: `lib/screens/OnboardingScreen.dart`

PageView with 8 steps (chevron navigation, not swipeable):

1. Bird picker (3 free starters)
2. Reading font toggle (serif / dyslexic / monospace)
3. Reading column toggle (narrow / wide)
4. Progressive reveal toggle
5. Blur toggle
6. Colored text toggle
7. Bionic reading toggle
8. Referral code step

Each toggle fires `UserService.update*()` immediately (fire-and-forget). Closing mid-flow preserves choices.

---

## Bird System

Config: `lib/constants/BirdOptions.dart`
Rendering: Flame sprite sheet animation

- Sprite sheets in `assets/birds/`
- Common birds: 64x64 cells, exotic birds: variable
- Unlock economy: cumulative reading time gates (unit: 45 min)
- Free starters: Sparrow, Pigeon (unlockSeconds = 0)
- Selection stored in `selectedBirdNotifier`
- Bird displayed on: finish page (128pt), profile menu (96pt)

---

## Text Rendering Modes

### Progressive Text (default)

File: `lib/utility_widgets/ProgressiveText.dart`

Typewriter-style reveal. One segment at a time. Tap to fast-forward current segment, tap again to advance. Completed segments stay visible above (with optional blur).

### RSVP (rapid serial visual presentation)

File: `lib/utility_widgets/RSVPText.dart`

One word at a time. ORP (Optimal Recognition Point) highlighted in red + bold. Word display rate driven by `rsvpWordsPerMinuteNotifier` (default 300). Tap to settle current segment.

### Bionic Reading

File: `lib/utility_widgets/BionicText.dart`

Bold word prefixes for faster scanning. Fixation length: words <= 3 chars bold 1 char, <= 5 bold 2, <= 7 bold 3, longer bold ~40%. Toggle: `bionicEnabledNotifier`.

---

## Services

### Auth

File: `lib/services/auth/AuthService.dart`

Sign in with Apple (iOS native), email/password. Auth state drives MainNavigation routing. Account deletion via `deleteAccount` Cloud Function. Disposable email blocking via `DisposableEmailDomains.dart`.

### Haptics

File: `lib/services/feedback/HapticsService.dart`

`lightImpact()`, `mediumImpact()`, `heavyImpact()`, `selectionClick()`. Gated by `userHapticsEnabledNotifier`. Latches off on platform error.

### Sounds

File: `lib/services/feedback/SoundService.dart`

Pooled AudioPlayers per sound family. Master switch: `soundsEnabledNotifier`. Typing sounds: separate `typingSoundEnabledNotifier`. 3 random text-click variants for typewriter cadence.

Sound files: `assets/audio/ui_sounds/*.wav`

### Logging

File: `lib/services/LoggingService.dart`

```dart
final logger = ServiceLogger.forService('ServiceName');
logger.info('operation', 'message');
logger.success('operation', 'details');
logger.failure('operation', 'error');
```

Debug-only (silent in release builds).

### Screen Protection

File: `lib/services/ScreenProtectionService.dart`

`enableProtection()` / `disableProtection()`. iOS: blocks screenshots + blurs in app switcher. Called once at startup.

### Connectivity

File: `lib/services/ConnectivityService.dart`

`isOnlineNotifier` (ValueNotifier<bool>). Drives "don't even try" UI gating. Default true so cold-start doesn't flash offline.

---

## Type Aliases

File: `lib/constants/DartAliases.dart`

```dart
typedef JSONMap = Map<String, dynamic>;
typedef JSONList = List<JSONMap>;
```

Used everywhere instead of raw Map/List types.

---

## Navigation Transitions

Defined in `RLDesignSystem.dart`:

- `fadeTransition(page)` - 300ms fade (standard)
- `slowFadeTransition(page)` - 450ms fade (emphasis)

---

## Key Architectural Patterns

1. **ValueNotifier everywhere** - no state management library, just notifiers + builders
2. **Optimistic updates** - local notifier updated before server write
3. **Server authority** - purchases, content, account deletion go through Cloud Functions
4. **CC prefix** - all course content widgets start with CC (CCTextContent, CCQuestionContent, etc.)
5. **RL prefix** - all design system components start with RL (RLButton, RLCard, RLLunarBlur, etc.)
6. **Fire-and-forget preferences** - toggle writes don't block UI, failures logged silently
7. **Monotonic progress** - lesson frontier only moves forward, never backwards
8. **Dark mode only** - surface #1C1C1E, no light theme
9. **Starfield + LunarBlur** - every screen has pixel starfield background with frosted glass overlays
