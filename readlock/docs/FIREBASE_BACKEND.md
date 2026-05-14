# Firebase Backend Reference

This content has been merged into [APP.md](APP.md) under "Firebase Backend".

For exact field shapes, rule logic, and constants, see the source files directly:

| What | Source file |
|------|------------|
| Firestore collection constants | `lib/constants/FirebaseConfig.dart` |
| User document shape | `lib/models/UserModel.dart` |
| Course progress model | `lib/models/CourseProgressModel.dart` |
| Purchased course model | `lib/models/PurchasedCourseModel.dart` |
| App config model | `lib/models/AppConfig.dart` |
| User service (read/write profiles) | `lib/services/auth/UserService.dart` |
| Auth service (sign-in, deletion) | `lib/services/auth/AuthService.dart` |
| Purchase service | `lib/services/purchases/PurchaseService.dart` |
| Purchase notifiers (balance, library, progress) | `lib/services/purchases/PurchaseNotifiers.dart` |
| Purchase constants (costs, caps, rewards) | `lib/services/purchases/PurchaseConstants.dart` |
| StoreKit (IAP) | `lib/services/purchases/StoreKitService.dart` |
| App config service (30-min TTL) | `lib/services/AppConfigService.dart` |
| Connectivity | `lib/services/ConnectivityService.dart` |
| FCM notifications | `lib/services/NotificationService.dart` |
| Content encryption | `lib/constants/ContentEncryption.dart` |
| Preference hydration | `lib/services/auth/UserPreferencesHydrator.dart` |
| Firestore rules | `firestore.rules` |
| Cloud Functions (all 7) | `functions/src/*.ts` |
