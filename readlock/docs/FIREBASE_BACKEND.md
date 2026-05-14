# Firebase Backend Reference

Data model, Cloud Functions, security rules, and data flow patterns.

## Firestore Collections

Constants in `lib/constants/FirebaseConfig.dart`.

| Collection | Constant | Purpose |
|-----------|----------|---------|
| courses | COURSES_COLLECTION | Course metadata (titles, segments, isFree flags) |
| courses/{id}/lessons/{docId} | LESSONS_SUBCOLLECTION | Encrypted lesson content (client reads denied) |
| users | USERS_COLLECTION | User profiles, preferences, wallet, library |
| config | CONFIG_COLLECTION | Remote app config (pricing, feature flags, URLs) |
| referral-codes | REFERRAL_CODES_COLLECTION | Referral codes and redemption tracking |

---

## User Document Shape

Model: `lib/models/UserModel.dart`
Service: `lib/services/auth/UserService.dart`

```
/users/{userId}
  email: string              (frozen after creation)
  createdAt: timestamp       (frozen after creation)
  language: string           (default 'en')
  hasCompletedOnboarding: bool
  fcmToken: string?

  // Preferences (all client-writable)
  typingSound, sounds, haptics: bool
  reveal, blur, coloredText, bionic, rsvp: bool
  justifiedReading: bool
  readingFont: string        ('serif' | 'dyslexic' | 'monospace')
  readingColumn: string      ('narrow' | 'wide')
  rsvpWordsPerMinute: int    (default 300)
  nightShiftLevel: int       (0-4)
  nightShiftScheduleEnabled: bool
  nightShiftScheduleFromMinutes: int  (default 1140 = 19:00)
  nightShiftScheduleToMinutes: int    (default 360 = 06:00)
  birdName: string           (default 'Sparrow')
  lastOpenedCourseId: string?

  // Wallet (client writes via FieldValue.increment)
  balance: int               (default 10 for new users)
  timeSpentReading: int      (cumulative seconds, seeded 210)

  // Library (server-managed, client writes blocked by rules)
  purchasedCourses: [{ courseId, expires, purchasedAt }]

  // Progress (client-writable via dotted-path updates)
  courseProgress: { [courseId]: { courseId, currentLessonIndex } }
```

---

## Cloud Functions (7 total)

All in `functions/src/`. All use `enforceAppCheck: !IS_EMULATOR` and `maxInstances`.

### purchaseCourse

File: `functions/src/purchaseCourse.ts` | maxInstances: 50

Input: `{ courseId }` | Output: `{ ok, balance }`

Atomic transaction: reads price from /config/app, checks course exists, checks no duplicate purchase, checks balance >= price, deducts balance, appends library entry (14-day rental), seeds courseProgress, bumps course.timesPurchased.

### resurrectCourse

File: `functions/src/resurrectCourse.ts` | maxInstances: 50

Input: `{ courseId }` | Output: `{ ok, balance }`

Transaction: finds course in library, verifies rental expired, checks balance >= 3, deducts 3 feathers, extends expires by 14 days.

### fetchLessonContent

File: `functions/src/fetchLessonContent.ts` | maxInstances: 100

Input: `{ courseId, lessonIndex }` | Output: `{ payload }` (AES-256-CBC encrypted)

Gates in order: auth, input validation, course exists, lesson in bounds, free-lesson shortcut (skips 6-9), user exists, purchase gate, discharge gate (rental not expired), frontier gate (lessonIndex <= currentLessonIndex). Reads from /courses/{id}/lessons/{docId}, encrypts, returns.

### incrementTimesPurchased

File: `functions/src/incrementTimesPurchased.ts` | maxInstances: 50

Input: `{ courseId }` | Output: `{ ok }`

Verifies course exists and caller purchased it, then bumps course.timesPurchased by 1.

### deleteAccount

File: `functions/src/deleteAccount.ts` | maxInstances: 10

Input: none | Output: `{ ok }`

Deletes auth record first (prevents re-login on partial failure), then deletes Firestore user doc.

### generateReferralCode

File: `functions/src/generateReferralCode.ts` | maxInstances: 25

Input: none | Output: `{ code }` (format: BIRD-XXXX)

Transaction: checks lifetime limit (3 per user), generates unique code, writes to referral-codes collection. Retries up to 5 times on collision.

### redeemReferralCode

File: `functions/src/redeemReferralCode.ts` | maxInstances: 25

Input: `{ code }` | Output: `{ ok }`

Transaction: validates code exists, not redeemed, not self-referral. Credits redeemer 10 feathers, creator 20 feathers (if account exists).

---

## Firestore Rules

File: `firestore.rules`

| Path | Read | Write | Notes |
|------|------|-------|-------|
| /courses/{id} | signed-in | admin only | Metadata. Counter bumps via Cloud Functions |
| /courses/{id}/lessons/{} | denied | admin only | Content hidden from client, served by fetchLessonContent |
| /users/{id} | owner only | owner (guards) | email + createdAt + purchasedCourses frozen on update |
| /config/{doc} | signed-in | denied | Admin writes via Console/Admin SDK |
| /referral-codes/{id} | creator only | denied | Created/redeemed via Cloud Functions |

User create guards: email must match auth token, createdAt must equal request.time, balance capped at 10.

User update guards: `fieldUnchanged('email')`, `fieldUnchanged('createdAt')`, `fieldUnchanged('purchasedCourses')`.

---

## Data Reading Patterns

**Server-fresh reads:**
- `UserService.getUserProfileById()` uses `Source.server` (always hits Firestore, never cache)

**Cache-first reads:**
- Course catalog fetches use default source (cache-first)

**Real-time streams:**
- `UserService.getCurrentUserProfileStream()` for live user profile updates

**Cloud Function callables:**
- All purchase/resurrect/content operations go through callables (never direct writes for server-managed fields)

---

## State Hydration (post-login)

File: `lib/services/purchases/PurchaseNotifiers.dart`

```
1. AuthService.createUserProfileIfNeeded()     // Create doc if first signup
2. UserService.getCurrentUserProfile()          // Fetch from server
3. hydratePurchaseStateFromUser(user)           // Push to global notifiers
4. hydrateUserPreferenceNotifiersFromUser(user) // Push prefs to notifiers
5. FirebaseMessagingService.saveTokenAfterLogin()
6. AppConfigService.fetchConfig()               // 30-min TTL cache
```

### Global ValueNotifiers

```dart
userBalanceNotifier              // int, feather count
purchasedCoursesNotifier         // List<PurchasedCourseModel>, library
courseProgressNotifier            // Map<String, CourseProgressModel>, per-course frontier
timeSpentReadingNotifier         // int, cumulative seconds
bookshelfHasUnseenPurchaseNotifier // bool, red badge dot
```

UI subscribes via `ValueListenableBuilder`. Notifiers updated optimistically before Firestore writes.

---

## Optimistic Update Pattern

Used for all write operations:

1. Update local ValueNotifier immediately (UI reacts in same frame)
2. Fire Firestore write / Cloud Function call
3. On success: reconcile with server value (e.g., balance from callable response)
4. On failure: log error (monotonic fields like progress are not rolled back)

---

## Content Encryption

Files: `lib/constants/ContentEncryption.dart`, `functions/src/fetchLessonContent.ts`

- Algorithm: AES-256-CBC
- Key: SHA-256 hash of 3 concatenated seed strings (scattered across client/server)
- Payload format: `ivHex:ciphertextHex`
- Server encrypts before returning, client decrypts on arrival
- Content never stored unencrypted in Firestore

---

## App Config

Files: `lib/services/AppConfigService.dart`, `lib/models/AppConfig.dart`

Reads from `/config/app`. Cached for 30 minutes. Fields: `bookFeatherPrice` (int), `privacyPolicyUrl`, `termsOfServiceUrl`, `eulaUrl`, `featureFlags` (Map).

`AppConfigService.fetchConfigIfStale()` called before price-sensitive operations.

---

## Purchase Constants

File: `lib/services/purchases/PurchaseConstants.dart`

| Constant | Value |
|----------|-------|
| COURSE_PURCHASE_COST | from AppConfig (default 10) |
| COURSE_RENTAL_DAYS | 14 |
| COURSE_RESURRECT_COST | 3 |
| MAX_SESSION_CREDITED_SECONDS | 600 (10 min cap) |
| REFERRAL_REDEEMER_REWARD | 10 |
| REFERRAL_CREATOR_REWARD | 20 |
| MAX_REFERRAL_CODES | 3 |
| NEW_USER_STARTING_BALANCE | 10 |

---

## Key File Paths

| What | Path |
|------|------|
| Firebase config constants | `lib/constants/FirebaseConfig.dart` |
| User service | `lib/services/auth/UserService.dart` |
| Auth service | `lib/services/auth/AuthService.dart` |
| Purchase notifiers | `lib/services/purchases/PurchaseNotifiers.dart` |
| Purchase service | `lib/services/purchases/PurchaseService.dart` |
| Purchase constants | `lib/services/purchases/PurchaseConstants.dart` |
| StoreKit (IAP) | `lib/services/purchases/StoreKitService.dart` |
| App config | `lib/services/AppConfigService.dart` |
| Connectivity | `lib/services/ConnectivityService.dart` |
| FCM notifications | `lib/services/NotificationService.dart` |
| Content encryption | `lib/constants/ContentEncryption.dart` |
| User model | `lib/models/UserModel.dart` |
| Course progress model | `lib/models/CourseProgressModel.dart` |
| Purchased course model | `lib/models/PurchasedCourseModel.dart` |
| App config model | `lib/models/AppConfig.dart` |
| Firestore rules | `firestore.rules` |
| Cloud Functions index | `functions/src/index.ts` |
| Preference hydrator | `lib/services/auth/UserPreferencesHydrator.dart` |
