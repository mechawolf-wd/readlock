import 'dart:convert';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart' show Digest, sha256;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:readlock/constants/FirebaseConfig.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/services/LoggingService.dart';
import 'package:readlock/services/auth/UserPreferencesHydrator.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/notifications/FirebaseMessagingService.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// * Auth result

class AuthResult {
  final UserCredential? credential;
  final String? errorMessage;

  const AuthResult({this.credential, this.errorMessage});

  bool get isSuccess => credential != null;
  bool get isFailure => credential == null;
}

// * Constants

const int NONCE_LENGTH = 32;
const String NONCE_CHARSET =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

// * Auth service

class AuthService {
  static final ServiceLogger logger = ServiceLogger.forService('AuthService');

  static Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static String? get currentUserId => currentUser?.uid;

  static String? get currentUserEmail => currentUser?.email;

  static bool get isSignedIn => currentUser != null;

  // * Error code to message mapper

  static String getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        {
          return RLUIStrings.ERROR_WEAK_PASSWORD;
        }
      case 'email-already-in-use':
        {
          // Map to the generic unknown-error string so the user-facing
          // message is literally identical to any other unrecognised
          // failure. Distinguishable copy here would still let an
          // attacker enumerate accounts by spotting the "couldn't create"
          // wording, so the answer needs to be the same words every time.
          return RLUIStrings.ERROR_UNKNOWN;
        }
      case 'invalid-email':
        {
          return RLUIStrings.ERROR_INVALID_EMAIL;
        }
      case 'user-disabled':
        {
          return RLUIStrings.ERROR_USER_DISABLED;
        }
      case 'too-many-requests':
        {
          return RLUIStrings.ERROR_TOO_MANY_REQUESTS;
        }
      case 'requires-recent-login':
        {
          return RLUIStrings.ERROR_REQUIRES_RECENT_LOGIN;
        }
      case 'network-request-failed':
        {
          return RLUIStrings.ERROR_NETWORK;
        }
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        {
          return RLUIStrings.ERROR_INVALID_CREDENTIALS;
        }
      default:
        {
          return RLUIStrings.ERROR_UNKNOWN;
        }
    }
  }

  // * Email / password

  static Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    bool sendVerificationEmail = true,
  }) async {
    logger.info('Registration', 'Starting...');

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? createdUser = userCredential.user;
      final bool shouldSendVerification =
          sendVerificationEmail && createdUser != null && !createdUser.emailVerified;

      if (shouldSendVerification) {
        await createdUser.sendEmailVerification();
      }

      final String userId = createdUser?.uid ?? 'unknown';

      logger.success('Registration', 'User ID: $userId, Email: $email');

      return AuthResult(credential: userCredential);
    } on FirebaseAuthException catch (error) {
      final String errorMessage = getErrorMessage(error.code);

      // email-already-in-use must never be surfaced verbatim. Even the
      // dev console can be opened on web, so the specific code is logged
      // as a generic failure to avoid account-enumeration via devtools.
      final bool isEmailInUse = error.code == 'email-already-in-use';
      final String logDetail = isEmailInUse ? 'sign-up rejected' : '${error.code} - $errorMessage';

      logger.failure('Registration', logDetail);

      return AuthResult(errorMessage: errorMessage);
    } on Exception catch (error) {
      logger.failure('Registration', error.toString());

      return const AuthResult(errorMessage: RLUIStrings.ERROR_UNKNOWN);
    }
  }

  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    logger.info('Login', 'Starting...');

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final String userId = userCredential.user?.uid ?? 'unknown';

      logger.success('Login', 'User ID: $userId, Email: $email');

      return AuthResult(credential: userCredential);
    } on FirebaseAuthException catch (error) {
      final String errorMessage = getErrorMessage(error.code);

      logger.failure('Login', '${error.code} - $errorMessage');

      return AuthResult(errorMessage: errorMessage);
    } on Exception catch (error) {
      logger.failure('Login', error.toString());

      return const AuthResult(errorMessage: RLUIStrings.ERROR_UNKNOWN);
    }
  }

  // * Password reset

  static Future<String?> sendPasswordResetEmail({required String email}) async {
    logger.info('Password Reset', 'Starting...');

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      logger.success('Password Reset', 'Email sent to: $email');

      return null;
    } on FirebaseAuthException catch (authError) {
      final String errorMessage = getErrorMessage(authError.code);

      logger.failure('Password Reset', '${authError.code} - $errorMessage');

      return errorMessage;
    } on Exception catch (error) {
      logger.failure('Password Reset', error.toString());

      return RLUIStrings.ERROR_UNKNOWN;
    }
  }

  static Future<bool> updatePassword({required String newPassword}) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool userNotLoggedIn = user == null;

      if (userNotLoggedIn) {
        return false;
      }

      await user.updatePassword(newPassword);

      return true;
    } on FirebaseAuthException catch (error) {
      logger.info('Password update', getErrorMessage(error.code));

      return false;
    } on Exception catch (error) {
      logger.info('Password update', '$error');

      return false;
    }
  }

  // * Re-authentication

  static Future<bool> reauthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool userNotLoggedIn = user == null;

      if (userNotLoggedIn) {
        return false;
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      return true;
    } on FirebaseAuthException catch (authError) {
      logger.info('Re-authentication', getErrorMessage(authError.code));

      return false;
    } on Exception catch (error) {
      logger.info('Re-authentication', '$error');

      return false;
    }
  }

  static Future<bool> reauthenticateWithApple() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool userNotLoggedIn = user == null;

      if (userNotLoggedIn) {
        return false;
      }

      // Web takes the Firebase popup path for the same reason signInWithApple
      // does: sign_in_with_apple_web 3.0 crashes during JS interop.
      if (kIsWeb) {
        final OAuthProvider appleProvider = OAuthProvider('apple.com')
          ..addScope('email')
          ..addScope('name');

        await user.reauthenticateWithPopup(appleProvider);

        return true;
      }

      final String rawNonce = generateNonce();
      final String hashedNonce = sha256ofString(rawNonce);

      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
          );

      final OAuthCredential oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      await user.reauthenticateWithCredential(oAuthCredential);

      return true;
    } on FirebaseAuthException catch (authError) {
      logger.info('Apple re-authentication', getErrorMessage(authError.code));

      return false;
    } on SignInWithAppleAuthorizationException catch (error) {
      logger.info('Apple re-authentication', '$error');

      return false;
    } on Exception catch (error) {
      logger.info('Apple re-authentication', '$error');

      return false;
    } on Object catch (error) {
      logger.info('Apple re-authentication', '$error');

      return false;
    }
  }

  static Future<bool> reauthenticateWithGoogle() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool userNotLoggedIn = user == null;

      if (userNotLoggedIn) {
        return false;
      }

      final GoogleAuthProvider googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      final bool isWebPlatform = kIsWeb;

      if (isWebPlatform) {
        await user.reauthenticateWithPopup(googleProvider);
      } else {
        await user.reauthenticateWithProvider(googleProvider);
      }

      return true;
    } on FirebaseAuthException catch (authError) {
      logger.info('Google re-authentication', getErrorMessage(authError.code));

      return false;
    } on Exception catch (error) {
      logger.info('Google re-authentication', '$error');

      return false;
    }
  }

  // * Email verification

  static Future<bool> sendEmailVerification() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool cannotSendVerification = user == null || user.emailVerified;

      if (cannotSendVerification) {
        return false;
      }

      await user.sendEmailVerification();

      return true;
    } on FirebaseAuthException catch (authError) {
      logger.info('Email verification', getErrorMessage(authError.code));

      return false;
    } on Exception catch (error) {
      logger.info('Email verification', '$error');

      return false;
    }
  }

  static Future<bool> isEmailVerified() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final bool hasNoUser = user == null;

      if (hasNoUser) {
        return false;
      }

      await user.reload();

      final User? updatedUser = FirebaseAuth.instance.currentUser;

      return fallback(updatedUser?.emailVerified, false);
    } on Exception catch (error) {
      logger.info('Check email verification', '$error');

      return false;
    }
  }

  // * Apple sign in

  static String generateNonce([int length = NONCE_LENGTH]) {
    final Random random = Random.secure();

    return List.generate(
      length,
      (index) => NONCE_CHARSET[random.nextInt(NONCE_CHARSET.length)],
    ).join();
  }

  static String sha256ofString(String input) {
    final List<int> bytes = utf8.encode(input);
    final Digest digest = sha256.convert(bytes);

    return digest.toString();
  }

  static Future<AuthResult> signInWithApple() async {
    logger.info('Apple Login', 'Starting...');

    try {
      UserCredential userCredential;

      // sign_in_with_apple_web 3.0 throws a JS interop TypeError on the
      // current web build. Firebase's OAuth popup is the supported web
      // path and matches the Google web flow.
      if (kIsWeb) {
        final OAuthProvider appleProvider = OAuthProvider('apple.com')
          ..addScope('email')
          ..addScope('name');

        userCredential = await FirebaseAuth.instance.signInWithPopup(appleProvider);
      } else {
        final String rawNonce = generateNonce();
        final String hashedNonce = sha256ofString(rawNonce);

        final AuthorizationCredentialAppleID appleCredential =
            await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
              ],
              nonce: hashedNonce,
            );

        final OAuthCredential oAuthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      }

      final String userId = userCredential.user?.uid ?? 'unknown';

      logger.success('Apple Login', 'User ID: $userId');

      return AuthResult(credential: userCredential);
    } on SignInWithAppleAuthorizationException catch (error) {
      final bool isCancelled = error.code == AuthorizationErrorCode.canceled;

      if (isCancelled) {
        logger.info('Apple Login', 'User cancelled');

        return const AuthResult();
      }

      logger.failure('Apple Login', '$error');

      return const AuthResult(errorMessage: RLUIStrings.ERROR_UNKNOWN);
    } on FirebaseAuthException catch (error) {
      final bool userCancelledPopup =
          error.code == 'popup-closed-by-user' || error.code == 'cancelled-popup-request';

      if (userCancelledPopup) {
        logger.info('Apple Login', 'User cancelled popup');

        return const AuthResult();
      }

      final String errorMessage = getErrorMessage(error.code);

      logger.failure('Apple Login', '${error.code} - $errorMessage');

      return AuthResult(errorMessage: errorMessage);
    } on Exception catch (error) {
      logger.failure('Apple Login', '$error');

      return const AuthResult(errorMessage: RLUIStrings.ERROR_UNKNOWN);
    } on Object catch (error) {
      // Catch-all so unexpected non-Exception errors (TypeError from JS
      // interop, etc.) still resolve the future and unfreeze the sheet.
      logger.failure('Apple Login', '$error');

      return const AuthResult(errorMessage: RLUIStrings.ERROR_UNKNOWN);
    }
  }

  // * Google sign in
  // Uses FirebaseAuth's built-in provider flow (popup on web, OAuth redirect on mobile).
  // No google_sign_in package required — fewer moving parts.

  static Future<AuthResult> signInWithGoogle() async {
    logger.info('Google Login', 'Starting...');

    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      final bool isWebPlatform = kIsWeb;

      final UserCredential userCredential = isWebPlatform
          ? await FirebaseAuth.instance.signInWithPopup(googleProvider)
          : await FirebaseAuth.instance.signInWithProvider(googleProvider);

      final String userId = userCredential.user?.uid ?? 'unknown';

      logger.success('Google Login', 'User ID: $userId');

      return AuthResult(credential: userCredential);
    } on FirebaseAuthException catch (error) {
      final bool userCancelledPopup =
          error.code == 'popup-closed-by-user' || error.code == 'cancelled-popup-request';

      if (userCancelledPopup) {
        logger.info('Google Login', 'User cancelled popup');

        return const AuthResult();
      }

      final String errorMessage = getErrorMessage(error.code);

      logger.failure('Google Login', '${error.code} - $errorMessage');

      return AuthResult(errorMessage: errorMessage);
    } on Exception catch (error) {
      logger.failure('Google Login', error.toString());

      return const AuthResult(errorMessage: RLUIStrings.ERROR_UNKNOWN);
    }
  }

  // * Sign out

  static Future<void> signOut() async {
    logger.info('Sign Out', 'Starting...');

    // FCM cleanup writes to Firestore so it must run before
    // FirebaseAuth.signOut, while the user is still authenticated.
    await UserService.clearFcmToken();

    await FirebaseMessagingService.deleteToken();

    // Wipe every user-scoped notifier in one place. Live screens see a
    // clean slate before the auth listener runs.
    wipeLocalUserSessionState();

    await FirebaseAuth.instance.signOut();

    logger.success('Sign Out');
  }

  // * User profile creation

  static Future<bool> checkIfUserProfileExists(String userId) async {
    logger.info('Profile Check', 'Checking if profile exists for: $userId');

    try {
      final bool exists = await UserService.userProfileExists(userId);

      logger.info('Profile Check', 'Profile exists: $exists');

      return exists;
    } on Exception catch (error) {
      logger.failure('Profile Check', error.toString());

      return false;
    }
  }

  static Future<bool> createUserProfile(
    String userId, {
    String? email,
  }) async {
    logger.info('Profile Creation', 'Creating profile for: $userId');

    try {
      final bool success = await UserService.createUser(
        userId: userId,
        email: fallback(email, ''),
      );

      if (success) {
        logger.success('Profile Creation', 'Profile created for: $userId');
      } else {
        logger.failure('Profile Creation', 'UserService.createUser returned false');
      }

      return success;
    } on Exception catch (error) {
      logger.failure('Profile Creation', error.toString());

      return false;
    }
  }

  // Returns true when a new profile document was created during this call —
  // the caller uses that signal to route fresh sign-ups through onboarding
  // instead of dropping them straight onto the home screen.
  static Future<bool> createUserProfileIfNeeded(User user) async {
    logger.info('Profile Ensure', 'Checking profile for user: ${user.uid}');

    try {
      final bool profileExists = await checkIfUserProfileExists(user.uid);
      final bool profileDoesNotExist = !profileExists;

      if (profileDoesNotExist) {
        logger.info('Profile Ensure', 'Profile does not exist, creating...');

        final bool wasCreated = await createUserProfile(
          user.uid,
          email: user.email,
        );

        return wasCreated;
      }

      logger.info('Profile Ensure', 'Profile already exists');

      return false;
    } on Exception catch (error) {
      logger.failure('Profile Ensure', error.toString());
      return false;
    }
  }

  // * Account deletion

  static Future<void> deleteAccount() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool noUserLoggedIn = user == null;

    if (noUserLoggedIn) {
      throw Exception(RLUIStrings.ERROR_NO_USER_LOGGED_IN);
    }

    try {
      logger.info('Account deletion', 'Starting for user: ${user.uid}');

      await UserService.clearFcmToken();

      await FirebaseMessagingService.deleteToken();

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        FirebaseConfig.CLOUD_FUNCTION_DELETE_ACCOUNT,
      );

      await callable.call();

      // Same teardown as signOut so the deleted user's local state can't
      // leak into whichever sign-in happens next.
      wipeLocalUserSessionState();

      try {
        await FirebaseAuth.instance.signOut();
      } on Exception catch (signOutError) {
        logger.info('Account deletion', 'SignOut after deletion: $signOutError');
      }

      logger.success('Account deletion', 'Complete');
    } on FirebaseFunctionsException catch (error) {
      logger.failure('Account deletion', '${error.code} - ${error.message}');

      throw Exception(RLUIStrings.ERROR_ACCOUNT_DELETION_FAILED);
    } on Exception catch (error) {
      logger.failure('Account deletion', '$error');

      throw Exception(RLUIStrings.ERROR_ACCOUNT_DELETION_FAILED);
    }
  }
}
