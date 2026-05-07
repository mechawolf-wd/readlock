// Centralized UI strings for the Readlock application
// All user-facing text: labels, titles, messages, button text
// Access via RLUIStrings.CONSTANT_NAME

class RLUIStrings {
  // * Navigation
  static const String HOME_TAB_LABEL = 'Home';
  static const String SEARCH_TAB_LABEL = 'Store';
  static const String BOOKSHELF_TAB_LABEL = 'Bookshelf';

  // * My Bookshelf Screen
  static const String BOOKSHELF_TITLE = 'Bookshelf';
  static const String BOOKSHELF_OWNED_HEADING = 'Owned';
  static const String BOOKSHELF_READING_TIME_LABEL = 'Total reading time';
  static const String BOOKSHELF_EMPTY_MESSAGE = '*chirp* - read something to see it here';
  static const String BOOKSHELF_FILTER_EMPTY_MESSAGE =
      '*chirp* - no skillbooks match that filter';
  static const String BOOKSHELF_LOAD_MORE_LABEL = 'Load more';
  static const String LOAD_MORE_NOTHING_LEFT = "*chirp* - that's all of them for now";

  // * Empty / loading states
  static const String NO_COURSES_MESSAGE = '';
  static const String STORE_OFFLINE_TITLE = 'Offline';
  static const String STORE_OFFLINE_MESSAGE =
      '*chirp* - the store needs a connection. Reconnect to keep browsing.';

  // * Confirmation dialog — shared
  static const String CANCEL_LABEL = 'Cancel';
  static const String DIALOG_DEFAULT_ACTION_LABEL = 'OK';

  // * Feathers bottom sheet — feather-based monthly subscription. Two
  // plans (Reader / Insider) shown in a horizontal slider, each giving a
  // fixed monthly feather budget the reader spends on books. Every book
  // costs 10 feathers.
  static const String FEATHERS_TITLE = 'Feathers Plan';
  static const String FEATHERS_SUBTITLE = 'Enjoy the skillbooks you want';
  static const String PRICE_PERIOD = '/month';
  static const String FEATHERS_BOOK_PRICING_NOTE = 'Each skillbook costs 10 feathers';

  // Per-plan copy.
  static const String PLAN_BEGINNER_NAME = 'Beginner';
  static const String PLAN_BEGINNER_PRICE = '\$6.99';
  static const String PLAN_BEGINNER_FEATHERS = '100 feathers';
  static const String PLAN_BEGINNER_BOOKS = '10 skillbooks a month';

  static const String PLAN_READER_NAME = 'Reader';
  static const String PLAN_READER_PRICE = '\$12.99';
  static const String PLAN_READER_FEATHERS = '300 feathers';
  static const String PLAN_READER_BOOKS = '30 skillbooks a month';

  // * Feedback Snackbar
  static const String CORRECT_ANSWER_MESSAGE = 'Correct, you read it';
  static const String WRONG_ANSWER_TITLE = 'Pick again';

  // * Login Bottom Sheet
  static const String LOGIN_TITLE = 'Welcome reader!';
  static const String LOGIN_SUBTITLE = 'Login to hop in';
  static const String SIGNUP_TITLE = 'Create account';
  static const String SIGNUP_SUBTITLE = 'Look! One of us!';
  static const String EMAIL_PLACEHOLDER = 'Email...';
  static const String PASSWORD_PLACEHOLDER = 'Password';
  static const String SIGN_IN_BUTTON_LABEL = 'Login';
  static const String SIGN_UP_BUTTON_LABEL = 'Create my nest';
  static const String LOGIN_SUPPORT_LABEL = 'Any help?';
  static const String SIGN_IN_LOADING_LABEL = 'Hopping in...';
  static const String SIGN_UP_LOADING_LABEL = 'Creating...';
  static const String FORGOT_PASSWORD_LABEL = 'Reset password';
  static const String SIGN_UP_LABEL = 'Sign up';
  static const String SWITCH_TO_SIGN_IN_LABEL = 'Login';
  static const String SWITCH_TO_SIGN_UP_LABEL = 'Create account';
  static const String DEV_SKIP_LOGIN_LABEL = 'Skip for now (dev)';

  // * Support bottom sheet (opened from the login sheet)
  static const String SUPPORT_OPTIONS_TITLE = 'Support';
  static const String SUPPORT_RESET_PASSWORD_LABEL = 'Reset password';
  static const String SUPPORT_RESET_PASSWORD_DESCRIPTION = 'Enter your email and reset it';
  static const String SUPPORT_SEND_RESET_LINK_LABEL = 'Reset password';
  static const String SUPPORT_RESEND_VERIFICATION_LABEL = 'Resend verification link';
  static const String SUPPORT_RESEND_VERIFICATION_DESCRIPTION =
      'We will resend the link for you';
  static const String SUPPORT_RESEND_VERIFICATION_BUTTON_LABEL = 'Resend link';
  static const String SUPPORT_SEND_RESET_LINK_LOADING_LABEL = 'Resetting...';
  static const String SUPPORT_RESEND_VERIFICATION_LOADING_LABEL = 'Resending...';
  static const String SUPPORT_EMAIL_LABEL = 'Email support';
  static const String SUPPORT_EMAIL_DESCRIPTION = 'Reach us directly at the address below.';
  static const String SUPPORT_COPY_EMAIL_BUTTON_LABEL = 'Copy';
  static const String SUPPORT_EMAIL_ADDRESS = 'support@readlock.org';
  static const String SUPPORT_EMAIL_COPIED_MESSAGE = 'Support email copied to clipboard.';
  static const String RESEND_VERIFICATION_ALREADY_VERIFIED = 'Your email is already verified.';
  static const String RESEND_VERIFICATION_FAILED =
      'That verification email didn\'t go through. Try again in a moment.';
  static const String RESEND_VERIFICATION_REQUIRES_SIGN_IN =
      'Sign in first, then we can resend the verification link.';
  static const String RESET_PASSWORD_SENT_MESSAGE = 'Reset link sent. Check your inbox.';
  static const String RESET_PASSWORD_EMAIL_REQUIRED = 'We need your email to send the link.';
  static const String LOGIN_EMAIL_REQUIRED = 'Your email, please.';
  static const String LOGIN_PASSWORD_REQUIRED = 'Your password, please.';
  static const String VERIFICATION_EMAIL_SENT = 'Verification email sent. Check your inbox.';
  static const String OR_DIVIDER_LABEL = 'or';
  static const String APPLE_LOGIN_LABEL = 'Apple';
  static const String GOOGLE_LOGIN_LABEL = 'Google';

  // * Account Bottom Sheet
  static const String ACCOUNT_TITLE = 'Account';
  static const String ACCOUNT_DONE_LABEL = 'Done';
  static const String ACCOUNT_DEACTIVATE_LABEL = 'Deactivate Account';
  static const String ACCOUNT_DELETE_LABEL = 'Delete Account';

  // * Logout confirmation
  static const String LOGOUT_CONFIRMATION_TITLE = 'Logout?';
  static const String LOGOUT_CONFIRMATION_MESSAGE =
      'You will need to sign back in to continue reading.';
  static const String LOGOUT_CONFIRMATION_CONFIRM = 'Logout';
  static const String LOGOUT_IN_PROGRESS_LABEL = 'Signing out...';

  // * Feedback Bottom Sheet
  static const String FEEDBACK_DIALOG_TITLE = 'Explanation';
  static const String HINT_DIALOG_TITLE = 'Hint';

  // * Course Loading Screen
  static const String LOADING_MESSAGE = 'Birds are indexing the skillbook';

  // * Shared loading indicator (dots are animated in the widget)
  static const String LOADING_LABEL = 'Chirping';

  // * Lesson Finish Screen
  static const String LESSON_FINISH_TITLE = 'Lesson done';
  static const String LESSON_FINISH_TIME_LABEL = 'Time on this lesson';
  static const String LESSON_FINISH_BUTTON_LABEL = 'Finish';

  // * Course Content Viewer
  static const String NO_CONTENT_AVAILABLE_MESSAGE =
      'Pigeons are still gathering content for this lesson. Please check back a bit !';
  static const String ERROR_LOADING_COURSE_DATA =
      'Couldn\'t load the skillbook. Please try again.';
  static const String QUIT_CONFIRMATION_TITLE = 'Wait';
  static const String QUIT_CONFIRMATION_MESSAGE = 'If you quit you will lose your progress.';
  static const String QUIT_CONFIRMATION_PAUSE_BUTTON = 'Pause';

  // * Night Shift (eye-strain overlay)
  static const String NIGHT_SHIFT_TITLE = 'Night Session';
  static const String NIGHT_SHIFT_DESCRIPTION =
      'Warm the screen for easier reading before sleep.';
  static const String NIGHT_SHIFT_LESS_WARM_LABEL = 'Day';
  static const String NIGHT_SHIFT_MORE_WARM_LABEL = 'Nocturnal';
  static const String NIGHT_SHIFT_SCHEDULE_LABEL = 'Scheduled';
  static const String NIGHT_SHIFT_SCHEDULE_FROM_LABEL = 'From';
  static const String NIGHT_SHIFT_SCHEDULE_TO_LABEL = 'To';

  // * Course Content Factory
  static const String UNKNOWN_CONTENT_TYPE_MESSAGE = 'Unknown content type: ';

  // * Progressive Text image fallback
  static const String IMAGE_NOT_FOUND_PREFIX = 'Image not found: ';

  // * Reflection Question
  static const String REFLECTION_ASPECTS_LABEL = 'Consider these aspects:';
  static const String REFLECTION_SWIPE_HINT = 'Swipe right to confirm';
  static const String REFLECT_TITLE = 'Take a Moment to Reflect';

  // * Text Content
  static const String TEXT_CONTENT_CONTINUE_LABEL = 'Continue';

  // * Home Screen Sections
  static const String CONTINUE_READING_TITLE = 'Latest read';
  static const String CONTINUE_READING_SUBTITLE = 'Continue the latest title';
  static const String CONTINUE_BUTTON_LABEL = 'Continue';
  static const String FOR_YOUR_PERSONALITY_TITLE = 'Top 3 (most purchased)';
  static const String FOR_YOUR_PERSONALITY_SUBTITLE = 'Read these only if you want';
  static const String SURPRISE_ME_LABEL = 'Try out something new';
  static const String SURPRISE_ME_NO_RESULTS_TOAST = 'No new skillbook to try right now.';

  // * Courses Screen
  static const String SEARCH_PLACEHOLDER = 'Title';
  static const String GENRES_LABEL = 'Genres';
  static const String OTHERS_READING_TITLE = 'Others are reading';
  static const String OTHERS_READING_SUBTITLE = 'Popular titles this week';
  static const String LOAD_NEXT_LABEL = 'Load next';
  static const String SEARCH_RESULTS_TITLE = 'Search Results';

  // * My Bookshelf Screen Sections
  static const String BOOKSHELF_SUBTITLE = '12 titles';
  static const String READING_SECTION_TITLE = 'Reading';
  static const String TITLES_AND_HISTORY_LABEL = 'Titles and history';
  static const String READING_HISTORY_TITLE = 'Reading history';

  // * Course Roadmap
  static const String ROADMAP_DEFAULT_TITLE = 'Course Roadmap';
  static const String ROADMAP_DEFAULT_AUTHOR = 'Unknown Author';
  static const String ROADMAP_SUBTITLE = 'Master design psychology fundamentals';
  static const String ROADMAP_CONTINUE_LABEL = 'Continue';
  static const String ROADMAP_DEFAULT_LESSON_LABEL = 'Lesson';
  static const String ROADMAP_PURCHASE_LABEL = 'Buy for';
  static const String ROADMAP_PURCHASE_LOADING_LABEL = 'Payment in progress...';
  static const String ROADMAP_PURCHASE_SUCCESS = 'Skillbook purchased';
  static const String ROADMAP_PURCHASE_INSUFFICIENT = 'Not enough feathers';

  // * Feedback Snackbar Buttons
  static const String WHY_BUTTON_LABEL = 'Why?';
  static const String HINT_BUTTON_LABEL = 'Hint';

  // * True/False Question
  static const String TRUE_LABEL = 'True';
  static const String FALSE_LABEL = 'False';
  static const String DEFAULT_WRONG_ANSWER_HINT =
      'Think about the design principle and try again.';
  static const String QUESTION_DEFAULT_WRONG_ANSWER_HINT =
      'Try again and think about the design principle.';

  // * Explanation
  static const String EXPLANATION_LABEL = 'Explanation';

  // * Estimate Percentage Question
  static const String ESTIMATE_YOUR_LABEL = 'Your estimate:';
  static const String ESTIMATE_SUBMIT_LABEL = 'Submit Estimate';
  static const String ESTIMATE_EXCELLENT_LABEL = 'Excellent estimate!';
  static const String ESTIMATE_KEEP_LEARNING_LABEL = 'Keep learning!';
  static const String ESTIMATE_GETTING_CLOSER_LABEL = 'Getting closer!';
  static const String ESTIMATE_LARGE_DIFF_HINT =
      'Tip: Consider the context and real-world factors that might influence this statistic.';
  static const String ESTIMATE_CLOSE_HINT =
      'Close! Think about the specific details mentioned in the text.';
  static const String ESTIMATE_EXPERIENCE_REWARD = '+8 experience';
  static const String ESTIMATE_MIN_LABEL = '0%';
  static const String ESTIMATE_MAX_LABEL = '100%';
  static const String ESTIMATE_COMPARISON_YOUR_LABEL = 'YOUR ESTIMATE';
  static const String ESTIMATE_COMPARISON_ACTUAL_LABEL = 'ACTUAL';

  // * Design Examples Showcase
  static const String DESIGN_EXAMPLES_TITLE = 'Design Examples';
  static const String DESIGN_EXAMPLES_SUBTITLE =
      'Tap cards to reveal examples of good and bad design';
  static const String DESIGN_EXAMPLES_COMPLETE = 'Complete!';
  static const String DESIGN_EXAMPLES_TAP_REVEAL = 'Tap to reveal';

  // * Course Outro
  static const String OUTRO_BUTTON_LABEL = 'Fin';

  // * Learning Statistics
  static const String LEARNING_STATS_TITLE = 'Reading';
  static const String LEARNING_STATS_DAYS_UNIT = 'days';
  static const String LEARNING_STATS_DAYS_LABEL = 'at 10 minutes/day';
  static const String LEARNING_STATS_LESSONS_UNIT = 'lessons';
  static const String LEARNING_STATS_LESSONS_LABEL = 'completed';

  // * Profile / Settings Menu
  static const String MENU_ACCOUNT = 'Account';
  static const String MENU_FEATHERS = 'Feathers';
  static const String MENU_TYPING_SOUND = 'Typing sound';
  static const String MENU_SOUNDS = 'Sounds';
  static const String MENU_HAPTICS = 'Haptics (clicks)';
  // "Progressive" is the user-facing label for what the code still refers
  // to internally as "reveal" — same bool, inverted meaning. ON = text
  // types in progressively; OFF = text appears all at once. The switch
  // value is flipped at the menu layer (see SwitchMenuItem usage in
  // MenuWidgets) so the stored preference doesn't need migration.
  static const String MENU_REVEAL = 'Progressive';
  static const String MENU_BLUR = 'Focus';
  static const String MENU_COLORED_TEXT = 'Accent';
  static const String MENU_BIONIC = 'Bionic';
  static const String MENU_RSVP = 'RSVP';
  static const String MENU_NOTIFICATIONS = 'Notifications';
  static const String MENU_SUPPORT = 'Support';
  static const String MENU_PRIVACY_POLICY = 'Privacy Policy';
  static const String MENU_TERMS_AND_CONDITIONS = 'Terms & Conditions';
  static const String MENU_EULA = 'EULA';
  static const String MENU_LOG_OUT = 'Logout';
  static const String MENU_VERSION = 'Sowa 1.0.0';

  // Section labels rendered to the left of each MenuDivider so the
  // settings list reads as grouped chapters instead of an undifferentiated
  // run of rows.
  static const String MENU_SECTION_SOUND = 'Sound';
  static const String MENU_SECTION_READING = 'Reading';
  static const String MENU_SECTION_LEGAL = 'Legal';
  static const String MENU_SECTION_SESSION = 'Session';

  // * Bird Picker
  static const String MENU_PROFILE_BIRD = 'Profile bird';
  static const String BIRD_PICKER_TITLE = 'Pick your bird';
  static const String BIRD_COLLARED_DOVE = 'Collared Dove';
  static const String BIRD_CROW = 'Crow';
  static const String BIRD_PIGEON = 'Pigeon';
  static const String BIRD_SPARROW = 'Sparrow';
  static const String BIRD_BLUE_MACAW = 'Blue Macaw';
  static const String BIRD_FLAMINGO = 'Flamingo';
  static const String BIRD_KIWI = 'Kiwi';
  static const String BIRD_SHOEBILL = 'Shoebill';
  static const String BIRD_TOUCAN = 'Toucan';

  // * Reading Font Picker
  static const String MENU_READING_FONT = 'Typeface';
  static const String FONT_PICKER_TITLE = 'Typography';
  static const String FONT_DEMO_SAMPLE_TEXT =
      'Trees in a forest pass sugar through fungal threads under the soil.';

  // * Reading Column Width
  static const String MENU_READING_COLUMN = 'Column style';
  static const String MENU_JUSTIFIED_READING = 'Justified text';
  static const String DEMO_READING_COLUMN_TEXT =
      'Voyager 1 left the heliosphere in 2012 and is still calling home, with '
      'a golden record bolted to its hull.';
  static const String DEMO_JUSTIFIED_TEXT =
      'Airbnb started on an air mattress in a San Francisco loft after the '
      'founders missed rent, and they kept the lights on for months by selling '
      'Obama O\'s cereal at the 2008 conventions.';

  // * Settings Demos
  static const String DEMO_REVEAL_TEXT = 'The human brain runs on twenty watts.';
  static const String DEMO_BLUR_PREVIOUS = 'Octopuses taste with their arms.';
  static const String DEMO_BLUR_CURRENT = 'Each sucker is its own tongue.';
  static const String DEMO_COLORED_HIGHLIGHT = 'Black holes';
  static const String DEMO_COLORED_SUFFIX = ' spin almost at the speed of light.';
  static const String DEMO_BIONIC_TEXT =
      'A honeybee back at the hive waggles out where the flowers are and how '
      'far to fly, and the others head straight there.';
  static const String DEMO_RSVP_TEXT =
      'Lightning hits Earth about a hundred times every second.';
  static const String RSVP_WPM_SUFFIX = ' wpm';

  // * Settings Bottom Sheet
  static const String SETTINGS_TITLE = 'Settings';

  // * Onboarding (dev-only menu entries; the user-visible flow is
  // navigated entirely with chevrons, no labelled CTAs)
  static const String DEV_TRIGGER_ONBOARDING_LABEL = 'Trigger onboarding (mock)';

  // * Verify email screen. Gate shown after onboarding (or after any
  // returning sign-in) when the user's email is still unconfirmed.
  static const String VERIFY_EMAIL_TITLE = 'Verify your email';
  static const String VERIFY_EMAIL_DESCRIPTION =
      'We sent a confirmation link. Open it from your inbox, then tap the button below.';
  static const String VERIFY_EMAIL_CONFIRM_LABEL = 'I have verified';
  static const String VERIFY_EMAIL_CHECKING_LABEL = 'Checking...';
  static const String VERIFY_EMAIL_RESEND_LABEL = 'Resend verification link';
  static const String VERIFY_EMAIL_RESENDING_LABEL = 'Resending...';
  static const String VERIFY_EMAIL_NOT_YET_MESSAGE = 'Still not verified. Check your inbox.';

  // * Account Dialogs
  static const String ACCOUNT_DEACTIVATE_MESSAGE =
      'Your account will be deactivated. You can reactivate it later.';
  static const String ACCOUNT_DEACTIVATE_CONFIRM = 'Deactivate';
  static const String ACCOUNT_DELETE_MESSAGE =
      'This action is permanent. All your data will be lost.';
  static const String ACCOUNT_DELETE_CONFIRM = 'Delete';
  static const String ACCOUNT_DELETE_FOREVER_LABEL = 'Delete forever';
  static const String ACCOUNT_DELETE_REAUTH_SUBTITLE = 'Sign in again to confirm.';
  static const String ACCOUNT_DELETE_IN_PROGRESS_LABEL = 'Removing account...';

  // * Auth Error Messages. Loose, dry, never accusatory. The originals
  // were already on tone, so the trim here is mostly cutting "give it
  // another try" filler from the tails.
  static const String ERROR_INVALID_CREDENTIALS = "Couldn't match that email and password.";
  static const String ERROR_WEAK_PASSWORD =
      'That password is a little short. A longer one will do.';
  static const String ERROR_INVALID_EMAIL = "That email doesn't look quite right.";

  // Surfaced when the sign-up email's domain is on the disposable / temp
  // mail blocklist (DisposableEmailDomains.dart).
  static const String ERROR_DISPOSABLE_EMAIL =
      "We wouldn't do that to you. Use a real address.";
  static const String ERROR_NETWORK = 'The connection is a little shaky.';
  static const String ERROR_TOO_MANY_REQUESTS = "Let's take a short breather.";
  static const String ERROR_REQUIRES_RECENT_LOGIN = 'Login again to continue.';
  static const String ERROR_USER_DISABLED = "This account isn't active anymore.";
  static const String ERROR_UNKNOWN = 'Something went wrong on our end.';
  static const String ERROR_NO_USER_LOGGED_IN = 'No one is signed in yet.';
  static const String ERROR_ACCOUNT_DELETION_FAILED = "Couldn't delete the account just now.";
}
