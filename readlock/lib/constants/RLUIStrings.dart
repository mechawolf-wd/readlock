// Centralized UI strings for the Readlock application
// All user-facing text: labels, titles, messages, button text
// Access via RLUIStrings.CONSTANT_NAME

class RLUIStrings {
  // * Navigation
  static const String HOME_TAB_LABEL = 'Home';
  static const String SEARCH_TAB_LABEL = 'Search';
  static const String BOOKSHELF_TAB_LABEL = 'Bookshelf';

  // * My Bookshelf Screen
  static const String BOOKSHELF_TITLE = 'Bookshelf';
  static const String BOOKSHELF_EMPTY_MESSAGE = 'Read something to see it here';
  static const String BOOKSHELF_LOAD_MORE_LABEL = 'Load more';

  // * Empty / loading states
  static const String NO_COURSES_MESSAGE = '';

  // * Confirmation dialog — shared
  static const String CANCEL_LABEL = 'Cancel';

  // * Reader Pass Screen
  static const String READER_PASS_TITLE = 'Reader Pass';
  static const String READER_PASS_SUBTITLE = 'Unlock unlimited learning';
  static const String DISCOUNT_TEXT = '25% OFF';
  static const String ORIGINAL_PRICE = '\$39.99';
  static const String DISCOUNTED_PRICE = '\$29.99';
  static const String PRICE_PERIOD = '/month';
  static const String SUBSCRIBE_BUTTON_TEXT = 'Get Reader Pass';
  static const String READER_PASS_FEATURES_TITLE = 'What you get';

  // * Feedback Snackbar
  static const String CORRECT_ANSWER_MESSAGE = 'Correct, you read it';
  static const String WRONG_ANSWER_TITLE = 'Pick again';

  // * Login Bottom Sheet
  static const String LOGIN_TITLE = 'Welcome reader!';
  static const String LOGIN_SUBTITLE = 'Sign in to hop in';
  static const String SIGNUP_TITLE = 'Create account';
  static const String SIGNUP_SUBTITLE = 'Look! They’re joining us!';
  static const String EMAIL_PLACEHOLDER = 'Email';
  static const String PASSWORD_PLACEHOLDER = 'Password';
  static const String SIGN_IN_BUTTON_LABEL = 'Sign In';
  static const String SIGN_UP_BUTTON_LABEL = 'New account';
  static const String LOGIN_SUPPORT_LABEL = 'Support';
  static const String SIGN_IN_LOADING_LABEL = 'Signing in...';
  static const String SIGN_UP_LOADING_LABEL = 'Creating account...';
  static const String FORGOT_PASSWORD_LABEL = 'Reset password';
  static const String SIGN_UP_LABEL = 'Sign up';
  static const String SWITCH_TO_SIGN_IN_LABEL = 'Sign in';
  static const String SWITCH_TO_SIGN_UP_LABEL = 'New account';
  static const String DEV_SKIP_LOGIN_LABEL = 'Skip for now (dev)';

  // * Support bottom sheet (opened from the login sheet)
  static const String SUPPORT_OPTIONS_TITLE = 'Support';
  static const String SUPPORT_RESET_PASSWORD_LABEL = 'Reset password';
  static const String SUPPORT_RESET_PASSWORD_DESCRIPTION = 'Enter your email and reset it';
  static const String SUPPORT_SEND_RESET_LINK_LABEL = 'Reset password';
  static const String SUPPORT_RESEND_VERIFICATION_LABEL = 'Resend verification link';
  static const String SUPPORT_RESEND_VERIFICATION_DESCRIPTION =
      'We will resend the link for you';
  static const String SUPPORT_RESEND_VERIFICATION_BUTTON_LABEL = 'Resend verification';
  static const String SUPPORT_EMAIL_LABEL = 'Email support';
  static const String SUPPORT_EMAIL_DESCRIPTION = 'Reach us directly at the address below.';
  static const String SUPPORT_COPY_EMAIL_BUTTON_LABEL = 'Copy support email';
  static const String SUPPORT_EMAIL_ADDRESS = 'support@readlock.app';
  static const String SUPPORT_EMAIL_COPIED_MESSAGE = 'Support email copied to clipboard.';
  static const String RESEND_VERIFICATION_SIGN_IN_REQUIRED =
      'Sign in and we can resend that for you.';
  static const String RESEND_VERIFICATION_ALREADY_VERIFIED = 'Your email is already verified.';
  static const String RESEND_VERIFICATION_FAILED =
      'That verification email didn\'t go through. Try again in a moment.';
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
  static const String LOGOUT_CONFIRMATION_TITLE = 'Sign out?';
  static const String LOGOUT_CONFIRMATION_MESSAGE =
      'You will need to sign back in to continue reading.';
  static const String LOGOUT_CONFIRMATION_CONFIRM = 'Sign out';
  static const String LOGOUT_IN_PROGRESS_LABEL = 'Signing out...';

  // * Feedback Bottom Sheet
  static const String FEEDBACK_DIALOG_TITLE = 'Explanation';
  static const String HINT_DIALOG_TITLE = 'Hint';
  static const String FEEDBACK_GOT_IT_LABEL = 'Read';

  // * Course Loading Screen
  static const String LOADING_MESSAGE = 'Birds are indexing the course';

  // * Shared loading indicator (dots are animated in the widget)
  static const String LOADING_LABEL = 'Chirping';

  // * Course Content Viewer
  static const String NO_CONTENT_AVAILABLE_MESSAGE =
      'Pigeons are still gathering content for this lesson. Please check back a bit !';
  static const String ERROR_LOADING_COURSE_DATA =
      'Couldn\'t load the course. Please try again.';
  static const String QUIT_CONFIRMATION_TITLE = 'Wait';
  static const String QUIT_CONFIRMATION_MESSAGE = 'If you quit you will lose your progress.';
  static const String QUIT_CONFIRMATION_LEARN_BUTTON = 'Learn';
  static const String QUIT_CONFIRMATION_QUIT_BUTTON = 'Quit';
  static const String BOOKMARK_FEEDBACK_MESSAGE = 'Swipe saved to your nest.';

  // * Course Content Factory
  static const String UNKNOWN_CONTENT_TYPE_MESSAGE = 'Unknown content type: ';

  // * Reflection Question
  static const String REFLECTION_ASPECTS_LABEL = 'Consider these aspects:';
  static const String REFLECTION_SWIPE_HINT = 'Swipe right to confirm';
  static const String REFLECT_TITLE = 'Take a Moment to Reflect';

  // * Quote
  static const String NOTABLE_QUOTE_TITLE = 'Notable Quote';
  static const String QUOTE_BOOKMARKED_LABEL = 'Bookmarked ✓';

  // * Text Content
  static const String TEXT_CONTENT_CONTINUE_LABEL = 'Continue';

  // * Home Screen Sections
  static const String CONTINUE_READING_TITLE = 'Reading now...';
  static const String CONTINUE_READING_SUBTITLE = 'Continue the latest title';
  static const String CONTINUE_BUTTON_LABEL = 'Continue';
  static const String FOR_YOUR_PERSONALITY_TITLE = 'How about these?';
  static const String FOR_YOUR_PERSONALITY_SUBTITLE = 'Read these only if you want';
  static const String SURPRISE_ME_LABEL = 'Try out something new';

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

  // * Feedback Snackbar Buttons
  static const String WHY_BUTTON_LABEL = 'Why?';
  static const String HINT_BUTTON_LABEL = 'Hint';

  // * True/False Question
  static const String TRUE_LABEL = 'True';
  static const String FALSE_LABEL = 'False';
  static const String DEFAULT_WRONG_ANSWER_HINT =
      'Think about the design principle and try again.';

  // * Explanation
  static const String EXPLANATION_LABEL = 'Explanation';

  // * Estimate Percentage Question
  static const String ESTIMATE_YOUR_LABEL = 'Your estimate:';
  static const String ESTIMATE_SUBMIT_LABEL = 'Submit Estimate';
  static const String ESTIMATE_EXCELLENT_LABEL = 'Excellent estimate!';
  static const String ESTIMATE_KEEP_LEARNING_LABEL = 'Keep learning!';
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
  static const String MENU_READER_PASS = 'Reader Pass';
  static const String MENU_TYPING_SOUND = 'Typing sound';
  static const String MENU_SOUNDS = 'Sounds';
  static const String MENU_HAPTICS = 'Haptics';
  // "Progressive" is the user-facing label for what the code still refers
  // to internally as "reveal" — same bool, inverted meaning. ON = text
  // types in progressively; OFF = text appears all at once. The switch
  // value is flipped at the menu layer (see SwitchMenuItem usage in
  // MenuWidgets) so the stored preference doesn't need migration.
  static const String MENU_REVEAL = 'Progressive';
  static const String MENU_BLUR = 'Focus';
  static const String MENU_COLORED_TEXT = 'Accent';
  static const String MENU_BIONIC = 'Bionic';
  static const String MENU_NOTIFICATIONS = 'Notifications';
  static const String MENU_SUPPORT = 'Support';
  static const String MENU_PRIVACY_POLICY = 'Privacy Policy';
  static const String MENU_TERMS_AND_CONDITIONS = 'Terms & Conditions';
  static const String MENU_EULA = 'EULA';
  static const String MENU_LOG_OUT = 'Sign out';
  static const String MENU_VERSION = 'Version 1.0.0';

  // * Bird Picker
  static const String MENU_PROFILE_BIRD = 'Profile bird';
  static const String BIRD_PICKER_TITLE = 'Pick your bird';
  static const String BIRD_COLLARED_DOVE = 'Collared Dove';
  static const String BIRD_CROW = 'Crow';
  static const String BIRD_PIGEON = 'Pigeon';
  static const String BIRD_SPARROW = 'Sparrow';

  // * Reading Font Picker
  static const String MENU_READING_FONT = 'Typography';
  static const String FONT_PICKER_TITLE = 'Typography';
  static const String FONT_DEMO_SAMPLE_TEXT =
      'Good design is honest. It reveals the product and its function.';

  // * Settings Demos
  static const String DEMO_REVEAL_TEXT = 'Design is not just what it looks like.';
  static const String DEMO_BLUR_PREVIOUS = 'Previous sentence fades away.';
  static const String DEMO_BLUR_CURRENT = 'Current sentence stays clear.';
  static const String DEMO_COLORED_HIGHLIGHT = 'Key terms';
  static const String DEMO_COLORED_SUFFIX = ' are highlighted in text.';
  static const String DEMO_BIONIC_TEXT =
      'Bionic reading bolds the first few letters of each word so your eye '
      'catches the shape before you finish reading it.';

  // * Settings Bottom Sheet
  static const String SETTINGS_TITLE = 'Settings';

  // * Account Dialogs
  static const String ACCOUNT_DEACTIVATE_MESSAGE =
      'Your account will be deactivated. You can reactivate it later.';
  static const String ACCOUNT_DEACTIVATE_CONFIRM = 'Deactivate';
  static const String ACCOUNT_DELETE_MESSAGE =
      'This action is permanent. All your data will be lost.';
  static const String ACCOUNT_DELETE_CONFIRM = 'Delete';

  // * Auth Error Messages
  static const String ERROR_INVALID_CREDENTIALS =
      'That email and password don\'t match. Give it another try.';
  static const String ERROR_EMAIL_IN_USE = 'An account with this email already exists.';
  static const String ERROR_WEAK_PASSWORD = 'That password needs a little more strength.';
  static const String ERROR_INVALID_EMAIL = 'Please enter a valid email address.';
  static const String ERROR_NETWORK = 'Something\'s off with the connection. Please try again.';
  static const String ERROR_TOO_MANY_REQUESTS =
      'A few too many tries. Give it a moment, then try again.';
  static const String ERROR_REQUIRES_RECENT_LOGIN = 'Please sign in again to continue.';
  static const String ERROR_USER_DISABLED = 'This account is no longer active.';
  static const String ERROR_UNKNOWN = 'Something went wrong on our end. Please try again.';
  static const String ERROR_NO_USER_LOGGED_IN = 'No one is signed in yet.';
  static const String ERROR_ACCOUNT_DELETION_FAILED =
      'Couldn\'t delete the account just now. Please try again.';
}
