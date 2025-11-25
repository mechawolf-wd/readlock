# Dart/Flutter Development Standards

Coding conventions and architectural patterns for the Readlock Flutter application. For content and writing guidelines, see [GUIDELINES.md](GUIDELINES.md).

## Code Architecture

### @0 File Naming Convention - MANDATORY

**ALL DART FILES MUST USE PASCALCASE. NO EXCEPTIONS WHATSOEVER.**

Examples:
- ✅ CORRECT: `FeedbackSnackbar.dart`
- ✅ CORRECT: `BottomNavigationBar.dart` 
- ✅ CORRECT: `CourseLoadingScreen.dart`
- ✅ CORRECT: `ProgressiveText.dart`
- ✅ CORRECT: `Utility.dart`
- ❌ WRONG: `feedback_snackbar.dart`
- ❌ WRONG: `bottom_navigation_bar.dart`
- ❌ WRONG: `course_loading_screen.dart`
- ❌ WRONG: `progressive_text.dart`
- ❌ WRONG: `utility.dart`

This applies to ALL Dart files in the project - widgets, models, services, utilities, constants - everything. No exceptions.

### @1 Naming Conventions

1. **No abbreviations** - use descriptive names (userProfile vs up). Be specific with loading states (isCourseDataLoading vs isLoading)
2. **No underscore prefixes** - never prefix any declaration with \_
3. **Clarity over brevity** - longer names acceptable for clarity
4. **Widget methods** - name by function (eg. NavigationItems), use PascalCase, no "build" prefix
5. **Functional methods** - use camelCase for non-widget returning functions (eg. navigateToScreen)
6. **Getter methods** - use "get" prefix for methods that compute and return values (eg. getButtonColors, getThemeColor, getCardDecoration)
7. **Icon definitions** - use PascalCase for icon widgets (CloseIcon vs closeIcon)
8. **Constants** - extract hardcoded strings, use UPPER_SNAKE_CASE

### @2 Widget Architecture

9. **Component extraction** - avoid deep nesting, extract separate widgets
10. **Design system separation** - never nest design components in UI code
11. **Function extraction** - never nest functions inside the UI, unless very simple. NO logic (lambdas, functions, ternary operators) directly in widget tree
12. **Utility widgets** - use Div.row/column instead of Container. Avoid Padding, SizedBox, and other widgets that Div can handle. Never use Container when Div is sufficient
13. **Spacing widgets** - use Spacing.height/width instead of SizedBox
14. **Typography consistency** - use Typography widgets for all text, never raw Text() widget
15. **Style and icon extraction** - extract complex styling objects (BoxDecoration, TextStyle, EdgeInsets with multiple properties) to variables above the build method, keep simple one-liners inline. Extract complete icon widgets above the build method with PascalCase naming (CloseIcon). Only icon variable names should appear in UI tree, never inline Icon() constructors
16. **Loop extraction** - extract loops, iterations, and ListView builders from widget tree into separate methods with descriptive names
17. **Data transformation extraction** - extract complex data operations (.from(), .map(), nested property access) into intermediate variables for clarity
18. **Interaction widgets** - prefer to use onTap as a Div class parameter or GestureDetector instead of InkWell unless ripple effect is specifically needed

### @3 Code Formatting

19. **Logical separation** - newlines between code sections, methods, properties (readability)
20. **Curly braces required** - never single-line if statements
21. **Switch statements** - always use curly brackets with switch instructions
22. **Widget lists** - newlines between sibling widgets in Div.row([]) and Div.column([]) arrays
23. **UI section comments** - use single-line comments to describe UI sections (eg. // Header, // Body content, // Looping over items, // Footer)

### @4 Control Flow

24. **Function action separation** - actions within functions should be separated with newlines for clarity and readability
25. **Extract conditions** - pull if statement contents into variables
26. **Avoid ternary in UI** - let functions handle decision logic
27. **No nested ternary** - avoid complex conditional operators, extract
28. **Consistent loop syntax** - Never use spread operators (...) or for loops in widget building
29. **Explicit over spread** - prefer explicit list items vs spread operators
30. **Descriptive indices** - use itemIndex/widgetIndex vs index
31. **Whitespace around blocks** - surround if/for/while with newlines

### @5 Performance

32. **4-pixel rule** - use multiples of 4 for spacing values
33. **Avoid overengineering** - don't optimize before inspection
34. **Code reuse** - extract repeated code into methods/widgets

@important: After aligning the code with the above rules, please write down what was changed for each point in the list, if applicable.
