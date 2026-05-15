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
| StoreScreen         | `lib/screens/StoreScreen.dart`                | Tab 1                  |
| BookshelfScreen     | `lib/screens/BookshelfScreen.dart`            | Tab 2                  |
| ProfileScreen       | `lib/screens/profile/ProfileScreen.dart`      | Push from Home         |
| OnboardingScreen    | `lib/screens/OnboardingScreen.dart`           | Post-registration      |
| VerifyEmailScreen   | `lib/screens/VerifyEmailScreen.dart`          | Post-signup            |
| CourseRoadmapScreen | `lib/course_screens/CourseRoadmapScreen.dart` | Push from course card  |
| CourseContentViewer | `lib/course_screens/CourseContentViewer.dart` | Push from roadmap node |

---

## State Management

No Provider, Riverpod, or BLoC. Pure `ValueNotifier` + `ValueListenableBuilder` throughout.

Global notifiers live at module level. Screens subscribe on build, update via async service calls. Purchase and progress notifiers in `lib/services/purchases/PurchaseNotifiers.dart`.

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

---

## Design System & UI

Design tokens, typography, layout primitives, and reusable components. For exact values, see the source files.

### Tokens & Constants

| File                                 | What it contains                                                                                                                  |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `lib/constants/RLDesignSystem.dart`  | Colors, spacing (multiples of 4), border radii, icon sizes, animation durations, glass/blur helpers, sheet/dialog/content padding |
| `lib/constants/RLTypography.dart`    | Three font families: Display (Press Start 2P), UI (JetBrains Mono), Reading (user-selectable). All text styles                    |
| `lib/constants/RLReadingFont.dart`   | Reading font selection (serif, dyslexic, monospace) driven by `selectedReadingFontNotifier`                                       |
| `lib/constants/RLCoursePalette.dart` | 12 course palette colors (hex in Firestore), book cover asset lookup                                                              |
| `lib/constants/RLNightShift.dart`    | 5 warmth levels (0=off to 4=warmest), schedule config                                                                             |

### Layout Primitives

| File                               | What it provides                                                                                                                                      |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/design_system/RLUtility.dart` | `Div.row`/`Div.column` (Container replacement), `Spacing.height`/`Spacing.width` (SizedBox replacement), `RenderIf.condition` (conditional rendering) |

### Components

| File                                        | Component                                                                      |
| ------------------------------------------- | ------------------------------------------------------------------------------ |
| `lib/design_system/RLButton.dart`           | `RLButton.primary` / `.secondary` / `.tertiary` (tap triggers haptic + sound)  |
| `lib/design_system/RLCard.dart`             | `RLCard.elevated` / `.subtle` (frosted glass cards)                            |
| `lib/design_system/RLLunarBlur.dart`        | Frosted glass blur overlay used on cards, nav bar, sheets, buttons             |
| `lib/design_system/RLNightShift.dart`       | Night shift warmth filter widget (ColorFiltered RGB matrix at root)            |
| `lib/design_system/RLFeedbackSnackbar.dart` | Slide-up correct/wrong answer snackbars                                        |
| `lib/bottom_sheets/RLBottomSheet.dart`      | `.show` / `.showFullHeight` modal bottom sheets with grabber and backdrop blur |

### Navigation

| File                      | What it does                                                                                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/MainNavigation.dart` | 3 bottom tabs (Home, Search, Bookshelf). Tabs stay mounted via AnimatedOpacity. Badge dot driven by `bookshelfHasUnseenPurchaseNotifier`. Nav bar uses LunarBlur over starfield |

### Feedback

| File                                        | What it does                                                             |
| ------------------------------------------- | ------------------------------------------------------------------------ |
| `lib/services/feedback/HapticsService.dart` | Light/medium/heavy impact, selection click. Gated by user preference     |
| `lib/services/feedback/SoundService.dart`   | Pooled audio players, text-click variants, master + typing sound toggles |

---

## Firebase Backend

Firestore data model, Cloud Functions, security rules, and data flow. For exact field shapes and rule logic, see the source files.

### Firestore Collections

| Collection                     | Constants in                        | What it stores                                                           |
| ------------------------------ | ----------------------------------- | ------------------------------------------------------------------------ |
| `courses`                      | `lib/constants/FirebaseConfig.dart` | Course metadata (titles, segments, isFree flags)                         |
| `courses/{id}/lessons/{docId}` | same                                | Encrypted lesson content (client reads denied, served by Cloud Function) |
| `users`                        | same                                | User profiles, preferences, wallet, library, progress                    |
| `config`                       | same                                | Remote app config (pricing, feature flags, URLs)                         |
| `referral-codes`               | same                                | Referral codes and redemption tracking                                   |

### Models

| File                                   | What it models                                                                                             |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `lib/models/UserModel.dart`            | User profile: email, preferences, wallet (balance, timeSpentReading), library (purchasedCourses), progress |
| `lib/models/CourseProgressModel.dart`  | Per-course lesson frontier                                                                                 |
| `lib/models/PurchasedCourseModel.dart` | Library entry with courseId, expires (14-day rental), purchasedAt                                          |
| `lib/models/AppConfig.dart`            | Remote config: feather price, legal URLs, feature flags                                                    |

### Cloud Functions (7 total)

All in `functions/src/`. All use AppCheck enforcement and maxInstances caps.

| Function                  | File                                       | What it does                                                                         |
| ------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------ |
| `purchaseCourse`          | `functions/src/purchaseCourse.ts`          | Atomic purchase: check balance, deduct feathers, append 14-day rental, seed progress |
| `resurrectCourse`         | `functions/src/resurrectCourse.ts`         | Re-rent expired course for 3 feathers, extend by 14 days                             |
| `fetchLessonContent`      | `functions/src/fetchLessonContent.ts`      | Gate checks (auth, purchase, expiry, frontier), encrypt + return lesson content      |
| `incrementTimesPurchased` | `functions/src/incrementTimesPurchased.ts` | Bump course purchase counter                                                         |
| `deleteAccount`           | `functions/src/deleteAccount.ts`           | Delete auth record then Firestore user doc                                           |
| `generateReferralCode`    | `functions/src/generateReferralCode.ts`    | Create BIRD-XXXX code (3 per user lifetime)                                          |
| `redeemReferralCode`      | `functions/src/redeemReferralCode.ts`      | Validate + credit redeemer 10, creator 20 feathers                                   |

### Security Rules

File: `firestore.rules`

Courses readable by signed-in users, lessons denied to client. Users readable/writable by owner only with frozen fields (email, createdAt, purchasedCourses). Config readable by signed-in, write denied. Referral codes readable by creator only.

### Services

| File                                             | What it does                                                       |
| ------------------------------------------------ | ------------------------------------------------------------------ |
| `lib/services/auth/UserService.dart`             | Read/write user profiles, advance progress, update preferences     |
| `lib/services/auth/AuthService.dart`             | Apple sign-in, email/password, auth state routing                  |
| `lib/services/purchases/PurchaseService.dart`    | Purchase and resurrect courses via Cloud Functions                 |
| `lib/services/purchases/PurchaseNotifiers.dart`  | Global ValueNotifiers for balance, library, progress, reading time |
| `lib/services/purchases/PurchaseConstants.dart`  | Rental days, resurrect cost, session cap, referral rewards         |
| `lib/services/purchases/StoreKitService.dart`    | App Store IAP products and purchase stream                         |
| `lib/services/AppConfigService.dart`             | Fetch remote config with 30-min TTL cache                          |
| `lib/services/ConnectivityService.dart`          | Network reachability monitor (`isOnlineNotifier`)                  |
| `lib/services/NotificationService.dart`          | FCM push notifications                                             |
| `lib/constants/ContentEncryption.dart`           | AES-256-CBC decrypt for lesson payloads                            |
| `lib/services/auth/UserPreferencesHydrator.dart` | Hydrate global notifiers from user profile after login             |

### State Hydration (post-login)

Sequence: create user doc if needed, fetch profile from server, hydrate purchase notifiers, hydrate preference notifiers, save FCM token, fetch app config. See `lib/services/purchases/PurchaseNotifiers.dart` and `lib/services/auth/UserPreferencesHydrator.dart`.

### Data Patterns

- **Server-fresh reads**: `UserService.getUserProfileById()` always hits Firestore (Source.server)
- **Cache-first reads**: Course catalog uses default source
- **Real-time streams**: `UserService.getCurrentUserProfileStream()` for live updates
- **Optimistic updates**: Local notifier updated before server write, reconcile on response
