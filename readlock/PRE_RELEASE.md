# Pre-Release Checklist

## Deploy order: functions, then app, then rules

### 1. Deploy functions

```
cd readlock/functions && firebase deploy --only functions
```

All 8 should go green: fetchLessonContent, purchaseCourse, resurrectCourse, incrementTimesPurchased, generateReferralCode, redeemReferralCode, deleteAccount, uploadTranslations.

### 2. Deploy Firestore rules

```
firebase deploy --only firestore:rules
```

Only do this after the new app build is live, otherwise old clients that write purchasedCourses directly will break.

### 3. Smoke test

- Sign in
- Purchase a course, open it, read a lesson
- Open a free lesson (should work without purchase)
- Let a course expire, resurrect it
- Settings: language picker shows up, font picker works, bird picker works
- Generate and redeem a referral code
- Sign out and back in (preferences should stick)

### 4. Check Firestore after purchase

- User doc: purchasedCourses has entry with expires and purchasedAt
- User doc: courseProgress has entry for the course
- User doc: balance went down by bookFeatherPrice
- Course doc: timesPurchased went up by 1

### 5. Error cases

- Purchase with not enough feathers (should show error, not crash)
- Purchase a course you already own (should show error, not crash)

### 6. App Check (before App Store submission)

Right now App Check is disabled (enforceAppCheck: false on all functions). Before shipping:

1. Go to Firebase Console, App Check, register DeviceCheck for your iOS app
2. Add a debug token for local testing
3. In all 8 function files: uncomment the IS_EMULATOR line, change enforceAppCheck back to !IS_EMULATOR
4. Redeploy functions
5. Test on a real device (not simulator) to make sure it works

### 7. Flutter Web (when shipping web version)

- Build with `flutter build web --dart2js-optimization O4` to strip symbol names and make the compiled JS harder to reverse-engineer
- Consider per-user rate limiting on Cloud Functions (e.g. max 10 lesson fetches per minute per UID)
- Consider content watermarking (invisible user ID embedded in content to trace leaks)
