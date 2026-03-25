// Centralized string and value constants for the Readlock application
// Organized by feature area per CLAUDE.md rule @39

// * Navigation
const String HOME_TAB_LABEL = 'Home';
const String SEARCH_TAB_LABEL = 'Search';
const String BOOKSHELF_TAB_LABEL = 'My Bookshelf';
const String SANDBOX_TAB_LABEL = 'Sandbox';
const double FLOATING_NAV_HEIGHT = 56.0;
const double FLOATING_NAV_MARGIN = 16.0;
const double FLOATING_NAV_BOTTOM_OFFSET =
    FLOATING_NAV_HEIGHT + FLOATING_NAV_MARGIN + 16.0;

// * Home Screen
const String HOME_TITLE = 'Home';

// * Profile Screen
const String TYPEWRITER_SOUND = 'Typewriter';
const String SWITCHES_SOUND = 'Switches';
const String OIIA_SOUND = 'OIIA';

// * My Bookshelf Screen
const String BOOKSHELF_TITLE = 'My Bookshelf';

// * Reader Pass Screen
const String READER_PASS_TITLE = 'Reader Pass';
const String READER_PASS_SUBTITLE = 'Unlock unlimited learning';
const String DISCOUNT_TEXT = '25% OFF';
const String ORIGINAL_PRICE = '\$39.99';
const String DISCOUNTED_PRICE = '\$29.99';
const String PRICE_PERIOD = '/month';
const String SUBSCRIBE_BUTTON_TEXT = 'Get Reader Pass';
const String READER_PASS_FEATURES_TITLE = 'What you get';

// * Streakplier Reward Screen
const String CONGRATULATIONS_MESSAGE = 'Reader time';
const String LESSON_COMPLETE_MESSAGE = 'Lesson Complete';
const String EXPERIENCE_POINTS_LABEL = 'Collected';
const String STREAKPLIER_LABEL = 'Streakplier';
const String LESSON_TIME_LABEL = 'Lesson Time';
const String REWARD_CONTINUE_BUTTON_TEXT = 'Continue';
const double REWARD_CARD_PADDING = 24.0;
const double REWARD_ITEM_SPACING = 20.0;
const double REWARD_ICON_SIZE = 32.0;
const double CELEBRATION_ICON_SIZE = 48.0;
const double REWARD_CARD_BORDER_RADIUS = 16.0;
const Duration ITEM_REVEAL_DELAY = Duration(milliseconds: 600);
const Duration COUNTING_ANIMATION_DURATION = Duration(milliseconds: 800);
const Duration REWARD_INITIAL_DELAY = Duration(milliseconds: 500);

// * Sandbox Screen
const String SANDBOX_TITLE = 'Widget Sandbox';

// * Feedback Snackbar
const String CORRECT_ANSWER_MESSAGE = '+5 experience';
const String WRONG_ANSWER_TITLE = 'Common thought';
const Duration SNACKBAR_ANIMATION_DURATION = Duration(milliseconds: 250);
const Duration DEFAULT_SNACKBAR_DURATION = Duration(milliseconds: 3000);
const Duration HINT_SNACKBAR_DURATION = Duration(seconds: 5);
const double SNACKBAR_VERTICAL_PADDING = 16.0;
const double SNACKBAR_HORIZONTAL_PADDING = 20.0;
const double SNACKBAR_BOTTOM_SAFE_AREA_EXTRA = 8.0;

// * Login Bottom Sheet
const String LOGIN_TITLE = 'Welcome Reader';
const String LOGIN_SUBTITLE = 'Sign in to continue reading';
const String EMAIL_PLACEHOLDER = 'Email';
const String PASSWORD_PLACEHOLDER = 'Password';
const String SIGN_IN_BUTTON_LABEL = 'Sign In';
const String FORGOT_PASSWORD_LABEL = 'Reset password';
const String SIGN_UP_LABEL = 'Sign up';
const String OR_DIVIDER_LABEL = 'or';
const String APPLE_LOGIN_LABEL = 'Apple';
const String GOOGLE_LOGIN_LABEL = 'Google';
const double BLUR_SIGMA = 10.0;
const double LOGIN_MODAL_BORDER_RADIUS = 24.0;
const double SOCIAL_BUTTON_HEIGHT = 48.0;

// * Account Bottom Sheet
const String ACCOUNT_TITLE = 'Account';
const String ACCOUNT_DONE_LABEL = 'Done';

// * Feedback Bottom Sheet
const String FEEDBACK_DIALOG_TITLE = 'Explanation';
const String HINT_DIALOG_TITLE = 'Hint';
const String FEEDBACK_GOT_IT_LABEL = 'Got it';
const double FEEDBACK_SHEET_BORDER_RADIUS = 12.0;

// * Shared Modal Constants
const double MODAL_PADDING = 24.0;

// * Course Loading Screen
const String LOADING_MESSAGE = 'Birds are indexing the course';
const double PIGEON_IMAGE_SIZE = 240.0;

// * Text Field
const double TEXT_FIELD_BORDER_RADIUS = 12.0;
const double TEXT_FIELD_HORIZONTAL_PADDING = 16.0;

// * Sound Service
const String CONTINUE_CLICK_AUDIO_PATH = 'audio/continue_click.mp3';
const String CORRECT_ANSWER_AUDIO_PATH = 'audio/correct_answer.wav';
const String TYPEWRITER_AUDIO_PATH = 'audio/typewriter.mp3';

// * Expandable Card
const double CARD_BORDER_RADIUS = 16.0;
const double HEADER_PADDING = 20.0;
const double ICON_SIZE_MAIN = 24.0;
const double ICON_SIZE_ARROW = 20.0;
const double DIVIDER_HEIGHT = 1.0;
const double CONTENT_PADDING_HORIZONTAL = 20.0;
const double CONTENT_PADDING_TOP = 16.0;
const double CONTENT_PADDING_BOTTOM = 20.0;

// * Course Content Viewer
const String NO_CONTENT_AVAILABLE_MESSAGE =
    'Pigeons are still gathering content for this lesson. Please check back a bit !';
const String ERROR_LOADING_COURSE_DATA = 'Error loading course data';
const String QUIT_CONFIRMATION_TITLE = 'Wait';
const String QUIT_CONFIRMATION_MESSAGE =
    'If you quit you will lose your progress.';
const String QUIT_CONFIRMATION_LEARN_BUTTON = 'Learn';
const String QUIT_CONFIRMATION_QUIT_BUTTON = 'Quit';
const double COURSE_TOP_BAR_PADDING = 16.0;
const double COURSE_BACK_ICON_SIZE = 20.0;
const double COURSE_PROGRESS_BAR_RADIUS = 8.0;
const double COURSE_PROGRESS_BAR_HEIGHT = 12.0;
const double COURSE_NAVIGATION_SPACING = 12.0;
const int COURSE_PAGE_ANIMATION_DURATION_MS = 300;

// * Course Roadmap Screen
const double ROADMAP_NODE_SIZE = 72.0;
const double ROADMAP_PATH_HORIZONTAL_OFFSET = 60.0;
const double ROADMAP_NODE_VERTICAL_SPACING = 96.0;
const double ROADMAP_MASTERY_DOT_SIZE = 8.0;
const double ROADMAP_MASTERY_DOT_SPACING = 4.0;
const int ROADMAP_MASTERY_DOTS_PER_LESSON = 3;
const double ROADMAP_STICKY_HEADER_PADDING = 8.0;
const double ROADMAP_STICKY_HEADER_CONTENT_PADDING = 12.0;
const double ROADMAP_STICKY_HEADER_LETTER_SIZE = 40.0;
const double ROADMAP_STICKY_HEADER_HEIGHT =
    (ROADMAP_STICKY_HEADER_PADDING * 2) +
    (ROADMAP_STICKY_HEADER_CONTENT_PADDING * 2) +
    ROADMAP_STICKY_HEADER_LETTER_SIZE;
const double ROADMAP_SEGMENT_CONTENT_TOP_SPACING = 16.0;

// * Course Content Factory
const String UNKNOWN_CONTENT_TYPE_MESSAGE = 'Unknown content type: ';
const String QUESTION_TYPE_MULTIPLE_CHOICE = 'multiple-choice';
const String QUESTION_TYPE_TRUE_OR_FALSE = 'true-or-false';
const String QUESTION_TYPE_SCENARIO = 'scenario';
const String QUESTION_TYPE_REFLECTION = 'reflection';
const String QUESTION_TYPE_FILL_GAP = 'fill-gap';
const String QUESTION_TYPE_INCORRECT_STATEMENT = 'incorrect-statement';
const String QUESTION_TYPE_ESTIMATE_PERCENTAGE = 'estimate-percentage';

// * Course Outro
const double COURSE_OUTRO_CONTENT_SPACING = 20.0;

// * Course Skill Check
const String SKILL_CHECK_TITLE = 'Skill Check';
const String SKILL_CHECK_SUBTITLE = 'Test Your Understanding';
const String SKILL_CHECK_DESCRIPTION =
    'You\'ve completed the lesson! Now let\'s check your understanding with a few questions.';
const String SKILL_CHECK_READY_BUTTON_TEXT = 'I\'m Ready';
const double SKILL_CHECK_CONTENT_SPACING = 24.0;

// * True/False Question
const double TRUE_FALSE_BUTTON_HEIGHT = 60.0;
const double TRUE_FALSE_BUTTON_SPACING = 16.0;
const double TRUE_FALSE_SECTION_SPACING = 24.0;
const double TRUE_FALSE_ICON_SIZE = 24.0;

// * Single Choice Question
const double SINGLE_CHOICE_OPTION_SPACING = 16.0;
const double SINGLE_CHOICE_SECTION_SPACING = 32.0;

// * Multiple Choice Question
const double MULTIPLE_CHOICE_OPTION_BUTTON_SPACING = 16.0;
const double MULTIPLE_CHOICE_QUESTION_SECTION_SPACING = 24.0;

// * Fill Gap Question
const double FILL_GAP_OPTION_SPACING = 12.0;
const double FILL_GAP_SECTION_SPACING = 24.0;
const double FILL_GAP_MIN_BLANK_WIDTH = 96.0;
const double FILL_GAP_MAX_BLANK_WIDTH = 200.0;
const double FILL_GAP_BLANK_HEIGHT = 40.0;
const int FILL_GAP_SHAKE_DURATION_MS = 500;
const double FILL_GAP_QUESTION_TEXT_SIZE = 18.0;
const double FILL_GAP_OPTION_TEXT_SIZE = 14.0;
const double FILL_GAP_LABEL_TEXT_SIZE = 14.0;
const double FILL_GAP_BUTTON_TEXT_SIZE = 16.0;
const double FILL_GAP_ICON_SPACING = 8.0;
const double FILL_GAP_CONTENT_PADDING = 20.0;
const double FILL_GAP_OPTION_CHIP_PADDING_H = 16.0;
const double FILL_GAP_OPTION_CHIP_PADDING_V = 10.0;
const double FILL_GAP_GAP_PADDING_H = 12.0;
const double FILL_GAP_GAP_PADDING_V = 8.0;
const double FILL_GAP_BORDER_WIDTH = 1.5;
const double FILL_GAP_CHIP_RADIUS = 20.0;
const double FILL_GAP_GAP_RADIUS = 8.0;
const double FILL_GAP_BUTTON_RADIUS = 12.0;

// * Incorrect Statement Question
const String INCORRECT_STATEMENT_PROMPT = 'Which statement is incorrect?';
const double INCORRECT_STATEMENT_SECTION_SPACING = 24.0;

// * Reflection Question
const String REFLECTION_ASPECTS_LABEL = 'Consider these aspects:';
const String REFLECTION_SWIPE_HINT = 'Swipe right to confirm';
const double REFLECTION_QUESTION_SECTION_SPACING = 28.0;

// * Quote
const String NOTABLE_QUOTE_TITLE = 'Notable Quote';

// * Text Content
const String TEXT_CONTENT_CONTINUE_LABEL = 'Continue';

// * Progressive Text
const double PROGRESSIVE_TEXT_DEFAULT_BOTTOM_SPACING = 8.0;
const Duration PROGRESSIVE_TEXT_AUTO_REVEAL_DELAY =
    Duration(milliseconds: 7);
const Duration PROGRESSIVE_TEXT_DOUBLE_TAP_TIMEOUT =
    Duration(milliseconds: 500);

// * Emotional Slide
const double EMOTIONAL_SLIDE_ICON_SIZE = 32.0;
const double EMOTIONAL_SLIDE_SPACING = 16.0;
const double EMOTIONAL_SLIDE_VERTICAL_PADDING = 40.0;

// * Utility Div Widget
const String DIRECTION_VERTICAL = 'vertical';
const String DIRECTION_HORIZONTAL = 'horizontal';
const String ALIGNMENT_START = 'start';
const String ALIGNMENT_END = 'end';
const String ALIGNMENT_CENTER = 'center';
const String ALIGNMENT_SPACE_BETWEEN = 'spaceBetween';
const String ALIGNMENT_SPACE_AROUND = 'spaceAround';
const String ALIGNMENT_SPACE_EVENLY = 'spaceEvenly';
const String ALIGNMENT_STRETCH = 'stretch';
const String ALIGNMENT_BASELINE = 'baseline';
