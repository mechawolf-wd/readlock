// Centralized UI strings for the Readlock application.
// All user-facing text: labels, titles, messages, button text.
//
// Each getter resolves through TranslationService so the app can
// serve non-English translations loaded from Firestore at runtime
// without redeployment. English defaults are always inline as
// fallbacks, so the app works even when Firestore is unreachable.
//
// Access via RLUIStrings.CONSTANT_NAME (same API as before).

import 'package:readlock/services/TranslationService.dart';

class RLUIStrings {
  // Resolves a translated string for the current locale.
  // Falls back to the English default if no translation exists.
  static String translated(String key, String fallback) {
    return TranslationService.translate(key, fallback);
  }

  // * Navigation
  static String get HOME_TAB_LABEL => translated('HOME_TAB_LABEL', 'Home');
  static String get SEARCH_TAB_LABEL => translated('SEARCH_TAB_LABEL', 'Store');
  static String get BOOKSHELF_TAB_LABEL => translated('BOOKSHELF_TAB_LABEL', 'Bookshelf');

  // * My Bookshelf Screen
  static String get BOOKSHELF_TITLE => translated('BOOKSHELF_TITLE', 'Bookshelf');
  static String get BOOKSHELF_OWNED_HEADING => translated('BOOKSHELF_OWNED_HEADING', 'Owned');
  static String get BOOKSHELF_READING_TIME_LABEL =>
      translated('BOOKSHELF_READING_TIME_LABEL', 'Total reading time');
  static String get BOOKSHELF_EMPTY_MESSAGE =>
      translated('BOOKSHELF_EMPTY_MESSAGE', '*chirp* - everyone starts somewhere');
  static String get BOOKSHELF_FILTER_EMPTY_MESSAGE =>
      translated('BOOKSHELF_FILTER_EMPTY_MESSAGE', '*chirp* - no skillbooks match that filter');
  static String get BOOKSHELF_LOAD_MORE_LABEL =>
      translated('BOOKSHELF_LOAD_MORE_LABEL', 'Load more');
  static String get BOOKSHELF_NEW_BADGE_LABEL => translated('BOOKSHELF_NEW_BADGE_LABEL', 'New');
  static String get LOAD_MORE_NOTHING_LEFT =>
      translated('LOAD_MORE_NOTHING_LEFT', "*chirp* - that's all of them for now");

  // * Empty / loading states
  static String get NO_COURSES_MESSAGE => translated('NO_COURSES_MESSAGE', '');
  static String get STORE_OFFLINE_TITLE => translated('STORE_OFFLINE_TITLE', 'Offline');
  static String get STORE_OFFLINE_MESSAGE => translated(
    'STORE_OFFLINE_MESSAGE',
    '*chirp* - the store needs a connection. Reconnect to keep browsing.',
  );

  // * Confirmation dialog (shared)
  static String get CANCEL_LABEL => translated('CANCEL_LABEL', 'Cancel');
  static String get DIALOG_DEFAULT_ACTION_LABEL =>
      translated('DIALOG_DEFAULT_ACTION_LABEL', 'OK');

  // * Feathers bottom sheet. Two plans (Reader / Insider) shown in a
  // horizontal slider, each giving a fixed monthly feather budget the
  // reader spends on books. Every book costs 10 feathers.
  static String get FEATHERS_TITLE => translated('FEATHERS_TITLE', 'Feathers');
  static String get FEATHERS_SUBTITLE => translated('FEATHERS_SUBTITLE', 'Own the skillbooks');
  static String get PRICE_PERIOD => translated('PRICE_PERIOD', '/month');
  static String get FEATHERS_BOOK_PRICING_NOTE =>
      translated('FEATHERS_BOOK_PRICING_NOTE', 'Each skillbook costs 10 feathers');
  static String get FEATHERS_RESTORE_LABEL =>
      translated('FEATHERS_RESTORE_LABEL', 'Restore purchases');
  static String get FEATHERS_RESTORE_SUCCESS =>
      translated('FEATHERS_RESTORE_SUCCESS', 'Purchases restored');
  static String get FEATHERS_PURCHASE_SUCCESS_SUFFIX =>
      translated('FEATHERS_PURCHASE_SUCCESS_SUFFIX', ' feathers');

  // Per-plan copy.
  static String get PLAN_BEGINNER_NAME => translated('PLAN_BEGINNER_NAME', 'Beginner');
  static String get PLAN_BEGINNER_PRICE => translated('PLAN_BEGINNER_PRICE', '\$6.99');
  static String get PLAN_BEGINNER_FEATHERS =>
      translated('PLAN_BEGINNER_FEATHERS', '100 feathers');
  static String get PLAN_BEGINNER_BOOKS =>
      translated('PLAN_BEGINNER_BOOKS', '10 skillbooks a month');

  static String get PLAN_READER_NAME => translated('PLAN_READER_NAME', 'Reader');
  static String get PLAN_READER_PRICE => translated('PLAN_READER_PRICE', '\$12.99');
  static String get PLAN_READER_FEATHERS => translated('PLAN_READER_FEATHERS', '300 feathers');
  static String get PLAN_READER_BOOKS =>
      translated('PLAN_READER_BOOKS', '30 skillbooks a month');

  // * Feedback Snackbar
  static String get CORRECT_ANSWER_MESSAGE =>
      translated('CORRECT_ANSWER_MESSAGE', 'Correct answer');
  static String get WRONG_ANSWER_TITLE => translated('WRONG_ANSWER_TITLE', 'Pick again');

  // * Login Bottom Sheet
  static String get LOGIN_TITLE => translated('LOGIN_TITLE', 'Welcome reader!');
  static String get LOGIN_SUBTITLE => translated('LOGIN_SUBTITLE', 'Login to hop in');
  static String get SIGNUP_TITLE => translated('SIGNUP_TITLE', 'Create account');
  static String get SIGNUP_SUBTITLE => translated('SIGNUP_SUBTITLE', 'Look! One of us!');
  static String get EMAIL_PLACEHOLDER => translated('EMAIL_PLACEHOLDER', 'Email...');
  static String get PASSWORD_PLACEHOLDER => translated('PASSWORD_PLACEHOLDER', 'Password');
  static String get SIGN_IN_BUTTON_LABEL => translated('SIGN_IN_BUTTON_LABEL', 'Login');
  static String get SIGN_UP_BUTTON_LABEL =>
      translated('SIGN_UP_BUTTON_LABEL', 'Create my nest');
  static String get LOGIN_SUPPORT_LABEL => translated('LOGIN_SUPPORT_LABEL', 'Any help?');
  static String get SIGN_IN_LOADING_LABEL =>
      translated('SIGN_IN_LOADING_LABEL', 'Hopping in...');
  static String get SIGN_UP_LOADING_LABEL => translated('SIGN_UP_LOADING_LABEL', 'Creating...');
  static String get SIGN_UP_LABEL => translated('SIGN_UP_LABEL', 'Sign up');
  static String get SWITCH_TO_SIGN_IN_LABEL => translated('SWITCH_TO_SIGN_IN_LABEL', 'Login');
  static String get SWITCH_TO_SIGN_UP_LABEL =>
      translated('SWITCH_TO_SIGN_UP_LABEL', 'Create account');
  static String get DEV_SKIP_LOGIN_LABEL =>
      translated('DEV_SKIP_LOGIN_LABEL', 'Skip for now (dev)');

  // * Support bottom sheet (opened from the login sheet)
  static String get SUPPORT_OPTIONS_TITLE => translated('SUPPORT_OPTIONS_TITLE', 'Support');
  static String get SUPPORT_RESET_PASSWORD_LABEL =>
      translated('SUPPORT_RESET_PASSWORD_LABEL', 'Reset password');
  static String get SUPPORT_RESET_PASSWORD_DESCRIPTION =>
      translated('SUPPORT_RESET_PASSWORD_DESCRIPTION', 'Enter your email and reset it');
  static String get SUPPORT_SEND_RESET_LINK_LABEL =>
      translated('SUPPORT_SEND_RESET_LINK_LABEL', 'Reset password');
  static String get SUPPORT_RESEND_VERIFICATION_LABEL =>
      translated('SUPPORT_RESEND_VERIFICATION_LABEL', 'Resend verification link');
  static String get SUPPORT_RESEND_VERIFICATION_DESCRIPTION =>
      translated('SUPPORT_RESEND_VERIFICATION_DESCRIPTION', 'We will resend the link for you');
  static String get SUPPORT_RESEND_VERIFICATION_BUTTON_LABEL =>
      translated('SUPPORT_RESEND_VERIFICATION_BUTTON_LABEL', 'Resend link');
  static String get SUPPORT_SEND_RESET_LINK_LOADING_LABEL =>
      translated('SUPPORT_SEND_RESET_LINK_LOADING_LABEL', 'Resetting...');
  static String get SUPPORT_RESEND_VERIFICATION_LOADING_LABEL =>
      translated('SUPPORT_RESEND_VERIFICATION_LOADING_LABEL', 'Resending...');
  static String get SUPPORT_EMAIL_LABEL => translated('SUPPORT_EMAIL_LABEL', 'Email support');
  static String get SUPPORT_EMAIL_DESCRIPTION =>
      translated('SUPPORT_EMAIL_DESCRIPTION', 'Reach us directly at the address below.');
  static String get SUPPORT_COPY_EMAIL_BUTTON_LABEL =>
      translated('SUPPORT_COPY_EMAIL_BUTTON_LABEL', 'Copy');
  static String get SUPPORT_EMAIL_ADDRESS =>
      translated('SUPPORT_EMAIL_ADDRESS', 'support@readlock.org');
  static String get SUPPORT_EMAIL_COPIED_MESSAGE =>
      translated('SUPPORT_EMAIL_COPIED_MESSAGE', 'Support email copied to clipboard.');
  static String get RESEND_VERIFICATION_ALREADY_VERIFIED =>
      translated('RESEND_VERIFICATION_ALREADY_VERIFIED', 'Your email is already verified.');
  static String get RESEND_VERIFICATION_FAILED => translated(
    'RESEND_VERIFICATION_FAILED',
    "That verification email didn't go through. Try again in a moment.",
  );
  static String get RESEND_VERIFICATION_REQUIRES_SIGN_IN => translated(
    'RESEND_VERIFICATION_REQUIRES_SIGN_IN',
    'Sign in first, then we can resend the verification link.',
  );
  static String get RESET_PASSWORD_SENT_MESSAGE =>
      translated('RESET_PASSWORD_SENT_MESSAGE', 'Reset link sent. Check your inbox.');
  static String get RESET_PASSWORD_EMAIL_REQUIRED =>
      translated('RESET_PASSWORD_EMAIL_REQUIRED', 'We need your email to send the link.');
  static String get LOGIN_EMAIL_REQUIRED =>
      translated('LOGIN_EMAIL_REQUIRED', 'Your email, please.');
  static String get LOGIN_PASSWORD_REQUIRED =>
      translated('LOGIN_PASSWORD_REQUIRED', 'Your password, please.');
  static String get VERIFICATION_EMAIL_SENT =>
      translated('VERIFICATION_EMAIL_SENT', 'Verification email sent. Check your inbox.');
  static String get OR_DIVIDER_LABEL => translated('OR_DIVIDER_LABEL', 'or');
  static String get APPLE_LOGIN_LABEL => translated('APPLE_LOGIN_LABEL', 'Apple');
  static String get GOOGLE_LOGIN_LABEL => translated('GOOGLE_LOGIN_LABEL', 'Google');

  // * Account Bottom Sheet
  static String get ACCOUNT_TITLE => translated('ACCOUNT_TITLE', 'Account');
  static String get ACCOUNT_DELETE_LABEL =>
      translated('ACCOUNT_DELETE_LABEL', 'Delete Account');

  // * Logout confirmation
  static String get LOGOUT_CONFIRMATION_TITLE =>
      translated('LOGOUT_CONFIRMATION_TITLE', 'Logout?');
  static String get LOGOUT_CONFIRMATION_MESSAGE => translated(
    'LOGOUT_CONFIRMATION_MESSAGE',
    'You will need to sign back in to continue reading.',
  );
  static String get LOGOUT_CONFIRMATION_CONFIRM =>
      translated('LOGOUT_CONFIRMATION_CONFIRM', 'Logout');

  // * Course Loading Screen
  static String get PREPARING_LABEL => translated('PREPARING_LABEL', 'Nesting');

  // * Shared loading indicator (dots are animated in the widget)
  static String get LOADING_LABEL => translated('LOADING_LABEL', 'Chirping');

  // * Lesson Finish Screen
  static String get LESSON_FINISH_TITLE => translated('LESSON_FINISH_TITLE', 'Package read');
  static String get LESSON_FINISH_TIME_LABEL =>
      translated('LESSON_FINISH_TIME_LABEL', 'Session Time');
  static String get LESSON_FINISH_BUTTON_LABEL =>
      translated('LESSON_FINISH_BUTTON_LABEL', 'Fin');

  // * Course Content Viewer
  static String get NO_CONTENT_AVAILABLE_MESSAGE => translated(
    'NO_CONTENT_AVAILABLE_MESSAGE',
    "We're very sorry that\nthe package didn't load.\nTry again now or in a bit.",
  );
  static String get ERROR_LOADING_COURSE_DATA =>
      translated('ERROR_LOADING_COURSE_DATA', "Couldn't load the skillbook. Please try again.");
  static String get QUIT_CONFIRMATION_TITLE => translated('QUIT_CONFIRMATION_TITLE', 'Wait');
  static String get QUIT_CONFIRMATION_MESSAGE =>
      translated('QUIT_CONFIRMATION_MESSAGE', 'If you quit you will lose your progress.');
  static String get QUIT_CONFIRMATION_PAUSE_BUTTON =>
      translated('QUIT_CONFIRMATION_PAUSE_BUTTON', 'Pause');

  // * Night Shift (eye-strain overlay)
  static String get NIGHT_SHIFT_TITLE => translated('NIGHT_SHIFT_TITLE', 'Night Session');
  static String get NIGHT_SHIFT_DESCRIPTION =>
      translated('NIGHT_SHIFT_DESCRIPTION', 'Warm the screen for easier reading before sleep.');
  static String get NIGHT_SHIFT_LESS_WARM_LABEL =>
      translated('NIGHT_SHIFT_LESS_WARM_LABEL', 'Daily');
  static String get NIGHT_SHIFT_MORE_WARM_LABEL =>
      translated('NIGHT_SHIFT_MORE_WARM_LABEL', 'Nocturnal');
  static String get NIGHT_SHIFT_SCHEDULE_LABEL =>
      translated('NIGHT_SHIFT_SCHEDULE_LABEL', 'Scheduled');
  static String get NIGHT_SHIFT_SCHEDULE_FROM_LABEL =>
      translated('NIGHT_SHIFT_SCHEDULE_FROM_LABEL', 'From');
  static String get NIGHT_SHIFT_SCHEDULE_TO_LABEL =>
      translated('NIGHT_SHIFT_SCHEDULE_TO_LABEL', 'To');

  // * Course Content Factory
  static String get UNKNOWN_CONTENT_TYPE_MESSAGE =>
      translated('UNKNOWN_CONTENT_TYPE_MESSAGE', 'Unknown content type: ');

  // * Text Content
  static String get TEXT_CONTENT_CONTINUE_LABEL =>
      translated('TEXT_CONTENT_CONTINUE_LABEL', 'Continue');

  // * Home Screen Sections
  static String get CONTINUE_READING_TITLE =>
      translated('CONTINUE_READING_TITLE', 'Latest read');
  static String get CONTINUE_BUTTON_LABEL => translated('CONTINUE_BUTTON_LABEL', 'Continue');
  static String get FOR_YOUR_PERSONALITY_TITLE =>
      translated('FOR_YOUR_PERSONALITY_TITLE', 'Top 3 (most purchased)');
  static String get SURPRISE_ME_LABEL =>
      translated('SURPRISE_ME_LABEL', 'Try out something new');
  static String get SURPRISE_ME_NO_RESULTS_TOAST =>
      translated('SURPRISE_ME_NO_RESULTS_TOAST', 'No new skillbook to try right now.');

  // * Courses Screen
  static String get SEARCH_PLACEHOLDER => translated('SEARCH_PLACEHOLDER', 'Title');

  // * Course Roadmap
  static String get ROADMAP_DEFAULT_TITLE => translated('ROADMAP_DEFAULT_TITLE', 'Roadmap');
  static String get ROADMAP_DEFAULT_AUTHOR =>
      translated('ROADMAP_DEFAULT_AUTHOR', 'Unknown Author');
  static String get ROADMAP_DEFAULT_LESSON_LABEL =>
      translated('ROADMAP_DEFAULT_LESSON_LABEL', 'Lesson');
  static String get ROADMAP_PURCHASE_LABEL => translated('ROADMAP_PURCHASE_LABEL', 'Purchase:');
  static String get ROADMAP_PURCHASE_LOADING_LABEL =>
      translated('ROADMAP_PURCHASE_LOADING_LABEL', 'Payment in progress...');
  static String get ROADMAP_PURCHASE_SUCCESS =>
      translated('ROADMAP_PURCHASE_SUCCESS', 'Skillbook purchased');

  // Skillbook charge mechanic. Every purchase grants a 14-day rental;
  // when the timer runs out the book "discharges" and the reader spends
  // 3 feathers to charge it again for another window.
  static String get ROADMAP_DISCHARGED_LABEL =>
      translated('ROADMAP_DISCHARGED_LABEL', 'Recharge');
  static String get ROADMAP_CHARGE_LABEL => translated('ROADMAP_CHARGE_LABEL', 'Recharge:');
  static String get ROADMAP_CHARGE_LOADING_LABEL =>
      translated('ROADMAP_CHARGE_LOADING_LABEL', 'Charging...');
  static String get ROADMAP_CHARGE_SUCCESS =>
      translated('ROADMAP_CHARGE_SUCCESS', 'Skillbook charged');
  static String get ROADMAP_DAYS_LEFT_SUFFIX =>
      translated('ROADMAP_DAYS_LEFT_SUFFIX', 'days of reading');
  static String get ROADMAP_DAY_LEFT_SUFFIX =>
      translated('ROADMAP_DAY_LEFT_SUFFIX', 'day of reading');
  static String get ROADMAP_HOURS_LEFT_SUFFIX =>
      translated('ROADMAP_HOURS_LEFT_SUFFIX', 'hours of reading');

  // * Feedback Snackbar Buttons
  static String get WHY_BUTTON_LABEL => translated('WHY_BUTTON_LABEL', 'Why?');
  static String get HINT_BUTTON_LABEL => translated('HINT_BUTTON_LABEL', 'Hint');

  // * True/False Question
  static String get TRUE_LABEL => translated('TRUE_LABEL', 'True');
  static String get FALSE_LABEL => translated('FALSE_LABEL', 'False');
  static String get DEFAULT_WRONG_ANSWER_HINT => translated(
    'DEFAULT_WRONG_ANSWER_HINT',
    'Think about the design principle and try again.',
  );
  static String get QUESTION_DEFAULT_WRONG_ANSWER_HINT => translated(
    'QUESTION_DEFAULT_WRONG_ANSWER_HINT',
    'Try again and think about the design principle.',
  );

  // * Estimate Percentage Question
  static String get ESTIMATE_YOUR_LABEL => translated('ESTIMATE_YOUR_LABEL', 'Your estimate:');
  static String get ESTIMATE_SUBMIT_LABEL =>
      translated('ESTIMATE_SUBMIT_LABEL', 'Submit Estimate');
  static String get ESTIMATE_EXCELLENT_LABEL =>
      translated('ESTIMATE_EXCELLENT_LABEL', 'Excellent estimate!');
  static String get ESTIMATE_KEEP_LEARNING_LABEL =>
      translated('ESTIMATE_KEEP_LEARNING_LABEL', 'Keep learning!');
  static String get ESTIMATE_GETTING_CLOSER_LABEL =>
      translated('ESTIMATE_GETTING_CLOSER_LABEL', 'Getting closer!');
  static String get ESTIMATE_LARGE_DIFF_HINT => translated(
    'ESTIMATE_LARGE_DIFF_HINT',
    'Tip: Consider the context and real-world factors that might influence this statistic.',
  );
  static String get ESTIMATE_CLOSE_HINT => translated(
    'ESTIMATE_CLOSE_HINT',
    'Close! Think about the specific details mentioned in the text.',
  );
  static String get ESTIMATE_EXPERIENCE_REWARD =>
      translated('ESTIMATE_EXPERIENCE_REWARD', '+8 experience');
  static String get ESTIMATE_MIN_LABEL => translated('ESTIMATE_MIN_LABEL', '0%');
  static String get ESTIMATE_MAX_LABEL => translated('ESTIMATE_MAX_LABEL', '100%');
  static String get ESTIMATE_COMPARISON_YOUR_LABEL =>
      translated('ESTIMATE_COMPARISON_YOUR_LABEL', 'YOUR ESTIMATE');
  static String get ESTIMATE_COMPARISON_ACTUAL_LABEL =>
      translated('ESTIMATE_COMPARISON_ACTUAL_LABEL', 'ACTUAL');

  // * Profile / Settings Menu
  static String get MENU_ACCOUNT => translated('MENU_ACCOUNT', 'Account');
  static String get MENU_FEATHERS => translated('MENU_FEATHERS', 'Feathers');
  static String get MENU_TYPING_SOUND => translated('MENU_TYPING_SOUND', 'Typing sound');
  static String get MENU_SOUNDS => translated('MENU_SOUNDS', 'Sounds');
  static String get MENU_HAPTICS => translated('MENU_HAPTICS', 'Haptics (clicks)');
  // "Progressive" is the user-facing label for what the code still refers
  // to internally as "reveal", same bool, inverted meaning. ON = text
  // types in progressively; OFF = text appears all at once. The switch
  // value is flipped at the menu layer (see SwitchMenuItem usage in
  // MenuWidgets) so the stored preference doesn't need migration.
  static String get MENU_REVEAL => translated('MENU_REVEAL', 'Progressive');
  static String get MENU_BLUR => translated('MENU_BLUR', 'Focus');
  static String get MENU_COLORED_TEXT => translated('MENU_COLORED_TEXT', 'Accent');
  static String get MENU_BIONIC => translated('MENU_BIONIC', 'Bionic');
  static String get MENU_RSVP => translated('MENU_RSVP', 'RSVP');
  static String get MENU_SUPPORT => translated('MENU_SUPPORT', 'Support');
  static String get MENU_PRIVACY_POLICY => translated('MENU_PRIVACY_POLICY', 'Privacy Policy');
  static String get MENU_TERMS_AND_CONDITIONS =>
      translated('MENU_TERMS_AND_CONDITIONS', 'Terms & Conditions');
  static String get MENU_EULA => translated('MENU_EULA', 'EULA');
  static String get MENU_LOG_OUT => translated('MENU_LOG_OUT', 'Logout');
  static String get MENU_VERSION => translated('MENU_VERSION', 'Sowa 1.0.0');

  // Section labels rendered to the left of each MenuDivider so the
  // settings list reads as grouped chapters instead of an undifferentiated
  // run of rows.
  static String get MENU_SECTION_SOUND => translated('MENU_SECTION_SOUND', 'Sound');
  static String get MENU_SECTION_READING => translated('MENU_SECTION_READING', 'Reading');
  static String get MENU_SECTION_LEGAL => translated('MENU_SECTION_LEGAL', 'Legal');
  static String get MENU_SECTION_SESSION => translated('MENU_SECTION_SESSION', 'Session');

  // * Bird Picker
  static String get MENU_PROFILE_BIRD => translated('MENU_PROFILE_BIRD', 'Profile bird');
  static String get BIRD_PICKER_TITLE => translated('BIRD_PICKER_TITLE', 'Pick your bird');
  static String get BIRD_COLLARED_DOVE => translated('BIRD_COLLARED_DOVE', 'Collared Dove');
  static String get BIRD_CROW => translated('BIRD_CROW', 'Crow');
  static String get BIRD_PIGEON => translated('BIRD_PIGEON', 'Pigeon');
  static String get BIRD_SPARROW => translated('BIRD_SPARROW', 'Sparrow');
  static String get BIRD_BLUE_MACAW => translated('BIRD_BLUE_MACAW', 'Blue Macaw');
  static String get BIRD_FLAMINGO => translated('BIRD_FLAMINGO', 'Flamingo');
  static String get BIRD_KIWI => translated('BIRD_KIWI', 'Kiwi');
  static String get BIRD_SHOEBILL => translated('BIRD_SHOEBILL', 'Shoebill');
  static String get BIRD_TOUCAN => translated('BIRD_TOUCAN', 'Toucan');

  // * Reading Font Picker
  static String get MENU_READING_FONT => translated('MENU_READING_FONT', 'Typeface');
  static String get FONT_PICKER_TITLE => translated('FONT_PICKER_TITLE', 'Typography');
  static String get FONT_DEMO_SAMPLE_TEXT => translated(
    'FONT_DEMO_SAMPLE_TEXT',
    'Trees in a forest pass sugar through fungal threads under the soil.',
  );

  // * Reading Column Width
  static String get MENU_READING_COLUMN => translated('MENU_READING_COLUMN', 'Column style');
  static String get MENU_JUSTIFIED_READING =>
      translated('MENU_JUSTIFIED_READING', 'Justified text');
  static String get DEMO_READING_COLUMN_TEXT => translated(
    'DEMO_READING_COLUMN_TEXT',
    'Voyager 1 left the heliosphere in 2012 and is still calling home, with a golden record bolted to its hull.',
  );
  static String get DEMO_JUSTIFIED_TEXT => translated(
    'DEMO_JUSTIFIED_TEXT',
    "Airbnb started on an air mattress in a San Francisco loft after the founders missed rent, and they kept the lights on for months by selling Obama O's cereal at the 2008 conventions.",
  );

  // * Settings Demos
  static String get DEMO_REVEAL_TEXT =>
      translated('DEMO_REVEAL_TEXT', 'The human brain runs on twenty watts.');
  static String get DEMO_BLUR_PREVIOUS =>
      translated('DEMO_BLUR_PREVIOUS', 'Octopuses taste with their arms.');
  static String get DEMO_BLUR_CURRENT =>
      translated('DEMO_BLUR_CURRENT', 'Each sucker is its own tongue.');
  static String get DEMO_COLORED_HIGHLIGHT =>
      translated('DEMO_COLORED_HIGHLIGHT', 'Black holes');
  static String get DEMO_COLORED_SUFFIX =>
      translated('DEMO_COLORED_SUFFIX', ' spin almost at the speed of light.');
  static String get DEMO_BIONIC_TEXT => translated(
    'DEMO_BIONIC_TEXT',
    'A honeybee back at the hive waggles out where the flowers are and how far to fly, and the others head straight there.',
  );
  static String get DEMO_RSVP_TEXT =>
      translated('DEMO_RSVP_TEXT', 'Lightning hits Earth about a hundred times every second.');
  static String get RSVP_WPM_SUFFIX => translated('RSVP_WPM_SUFFIX', ' wpm');

  // * Demo explanations (opened via "What's this?" under each demo box)
  static String get DEMO_EXPLAIN_LABEL => translated('DEMO_EXPLAIN_LABEL', "What's this?");
  static String get DEMO_EXPLAIN_REVEAL => translated(
    'DEMO_EXPLAIN_REVEAL',
    'Text types in one character at a time to slow skimming.',
  );
  static String get DEMO_EXPLAIN_BLUR => translated(
    'DEMO_EXPLAIN_BLUR',
    'Already-read sentences blur so your eyes stay on the current line.',
  );
  static String get DEMO_EXPLAIN_COLORED_TEXT => translated(
    'DEMO_EXPLAIN_COLORED_TEXT',
    'Key terms appear in color so the main idea stands out.',
  );
  static String get DEMO_EXPLAIN_FONT =>
      translated('DEMO_EXPLAIN_FONT', 'Changes the typeface used across all reading content.');
  static String get DEMO_EXPLAIN_COLUMN =>
      translated('DEMO_EXPLAIN_COLUMN', 'Controls how wide the text runs across the screen.');
  static String get DEMO_EXPLAIN_JUSTIFIED => translated(
    'DEMO_EXPLAIN_JUSTIFIED',
    'Stretches lines to fill the column for a clean block shape.',
  );
  static String get DEMO_EXPLAIN_BIONIC => translated(
    'DEMO_EXPLAIN_BIONIC',
    'Bolds the start of each word so your eye moves faster.',
  );

  // * Settings Bottom Sheet
  static String get SETTINGS_TITLE => translated('SETTINGS_TITLE', 'Settings');

  // * Language Picker
  static String get MENU_LANGUAGE => translated('MENU_LANGUAGE', 'Language');
  static String get LANGUAGE_PICKER_TITLE => translated('LANGUAGE_PICKER_TITLE', 'Language');

  // * Onboarding (dev-only menu entries; the user-visible flow is
  // navigated entirely with chevrons, no labelled CTAs)
  static String get DEV_TRIGGER_ONBOARDING_LABEL =>
      translated('DEV_TRIGGER_ONBOARDING_LABEL', 'Trigger onboarding (mock)');

  // * Verify email screen. Gate shown after onboarding (or after any
  // returning sign-in) when the user's email is still unconfirmed.
  static String get VERIFY_EMAIL_TITLE => translated('VERIFY_EMAIL_TITLE', 'Verify your email');
  static String get VERIFY_EMAIL_DESCRIPTION => translated(
    'VERIFY_EMAIL_DESCRIPTION',
    'We sent a confirmation link. Open it from your inbox, then tap the button below.',
  );
  static String get VERIFY_EMAIL_CONFIRM_LABEL =>
      translated('VERIFY_EMAIL_CONFIRM_LABEL', 'I have verified');
  static String get VERIFY_EMAIL_CHECKING_LABEL =>
      translated('VERIFY_EMAIL_CHECKING_LABEL', 'Checking...');
  static String get VERIFY_EMAIL_RESEND_LABEL =>
      translated('VERIFY_EMAIL_RESEND_LABEL', 'Resend verification link');
  static String get VERIFY_EMAIL_RESENDING_LABEL =>
      translated('VERIFY_EMAIL_RESENDING_LABEL', 'Resending...');
  static String get VERIFY_EMAIL_NOT_YET_MESSAGE =>
      translated('VERIFY_EMAIL_NOT_YET_MESSAGE', 'Still not verified. Check your inbox.');

  // * Account Dialogs
  static String get ACCOUNT_DELETE_MESSAGE => translated(
    'ACCOUNT_DELETE_MESSAGE',
    'This action is permanent. All your data will be lost.',
  );
  static String get ACCOUNT_DELETE_FOREVER_LABEL =>
      translated('ACCOUNT_DELETE_FOREVER_LABEL', 'Delete forever :(');
  static String get ACCOUNT_DELETE_REAUTH_SUBTITLE =>
      translated('ACCOUNT_DELETE_REAUTH_SUBTITLE', 'Sign in again to confirm.');

  // * Auth Error Messages. Loose, dry, never accusatory.
  static String get ERROR_INVALID_CREDENTIALS =>
      translated('ERROR_INVALID_CREDENTIALS', "Couldn't match that email and password.");
  static String get ERROR_WEAK_PASSWORD => translated(
    'ERROR_WEAK_PASSWORD',
    'That password is a little short. A longer one will do.',
  );
  static String get ERROR_INVALID_EMAIL =>
      translated('ERROR_INVALID_EMAIL', "That email doesn't look quite right.");

  // Surfaced when the sign-up email's domain is on the disposable / temp
  // mail blocklist (DisposableEmailDomains.dart).
  static String get ERROR_DISPOSABLE_EMAIL => translated(
    'ERROR_DISPOSABLE_EMAIL',
    "We wouldn't do that to you. Please, use a real address.",
  );
  static String get ERROR_NETWORK =>
      translated('ERROR_NETWORK', 'The connection is a little shaky.');
  static String get ERROR_TOO_MANY_REQUESTS =>
      translated('ERROR_TOO_MANY_REQUESTS', "Let's take a short breather.");
  static String get ERROR_REQUIRES_RECENT_LOGIN =>
      translated('ERROR_REQUIRES_RECENT_LOGIN', 'Login again to continue.');
  static String get ERROR_USER_DISABLED =>
      translated('ERROR_USER_DISABLED', "This account isn't active anymore.");
  static String get ERROR_UNKNOWN =>
      translated('ERROR_UNKNOWN', 'Something went wrong on our end.');
  static String get ERROR_NO_USER_LOGGED_IN =>
      translated('ERROR_NO_USER_LOGGED_IN', 'No one is signed in yet.');
  static String get ERROR_ACCOUNT_DELETION_FAILED =>
      translated('ERROR_ACCOUNT_DELETION_FAILED', "Couldn't delete the account just now.");

  // * Referral System

  // Bottom sheet
  static String get REFERRAL_TITLE => translated('REFERRAL_TITLE', 'Invite a reader');
  static String get REFERRAL_SUBTITLE_THEY_GET =>
      translated('REFERRAL_SUBTITLE_THEY_GET', 'They get 10 ');
  static String get REFERRAL_SUBTITLE_YOU_GET =>
      translated('REFERRAL_SUBTITLE_YOU_GET', ', you get 20 ');
  static String get REFERRAL_GENERATE_LABEL =>
      translated('REFERRAL_GENERATE_LABEL', 'Generate code');
  static String get REFERRAL_GENERATING_LABEL =>
      translated('REFERRAL_GENERATING_LABEL', 'Generating...');
  static String get REFERRAL_CODE_LIMIT_REACHED =>
      translated('REFERRAL_CODE_LIMIT_REACHED', 'All 3 codes generated');
  static String get REFERRAL_CODE_COPIED => translated('REFERRAL_CODE_COPIED', 'Code copied');
  static String get REFERRAL_CODE_GENERATED =>
      translated('REFERRAL_CODE_GENERATED', 'New code created');
  static String get REFERRAL_CODE_GENERATE_FAILED =>
      translated('REFERRAL_CODE_GENERATE_FAILED', 'Could not generate code. Try again.');
  static String get REFERRAL_CODE_USED_LABEL => translated('REFERRAL_CODE_USED_LABEL', 'Used');
  static String get REFERRAL_CODE_AVAILABLE_LABEL =>
      translated('REFERRAL_CODE_AVAILABLE_LABEL', 'Available');

  // Onboarding step
  static String get REFERRAL_ONBOARDING_TITLE =>
      translated('REFERRAL_ONBOARDING_TITLE', 'Redeem code');
  static String get REFERRAL_ONBOARDING_PLACEHOLDER =>
      translated('REFERRAL_ONBOARDING_PLACEHOLDER', 'ROBIN-7K3X');
  static String get REFERRAL_ONBOARDING_SUBMIT_LABEL =>
      translated('REFERRAL_ONBOARDING_SUBMIT_LABEL', 'Apply');
  static String get REFERRAL_ONBOARDING_SUBMITTING_LABEL =>
      translated('REFERRAL_ONBOARDING_SUBMITTING_LABEL', 'Applying...');
  static String get REFERRAL_ONBOARDING_SUCCESS =>
      translated('REFERRAL_ONBOARDING_SUCCESS', '+10 feathers added');
  static String get REFERRAL_CODE_INVALID =>
      translated('REFERRAL_CODE_INVALID', 'That code is not valid.');
  static String get REFERRAL_CODE_REDEEM_FAILED =>
      translated('REFERRAL_CODE_REDEEM_FAILED', 'Could not redeem code. Try again.');
  static String get REFERRAL_CODE_OWN =>
      translated('REFERRAL_CODE_OWN', 'You cannot use your own code.');

  // Settings menu
  static String get MENU_INVITE_FRIENDS => translated('MENU_INVITE_FRIENDS', 'Invite friends');
  static String get MENU_REDEEM_CODE => translated('MENU_REDEEM_CODE', 'Redeem code');

  // * Content format version tag (NOT translatable, used for encryption)
  static const String CONTENT_VERSION = 'accelerator-content-v2';
}
