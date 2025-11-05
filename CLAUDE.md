# Dart/Flutter Style Guide

## Naming Conventions

1. Do not use abbreviations in variable or method names, same goes for callback parameters and function parameters
2. Do not use \_ underscore prefix for private variables or methods
3. Use descriptive names for variables and methods (e.g., userProfile instead of up)
4. When using descriptive names, allow longer names if it improves clarity (e.g., fetchUserProfileData instead of fetchData)
5. Don't use "build" prefix for methods that return flutter widgets or lists of widgets; name them according to what they build (e.g., navigationItems instead of buildNavigationItems) using PascalCase
6. Extract hardcoded strings into separate constants and use UPPER_SNAKE_CASE for them

## Code Structure & Organization

1. Use new lines to separate logical sections of code

- Between class properties and methods
- Between methods
- Between logical sections inside methods (e.g., variable declarations, main logic, return statement)

2. Do not use single line if and other statements without curly braces
3. Extract contents of if statements into separate variables for clarity
4. Avoid deeply nested ternary operators in UI code
5. Extract repeated code into separate methods or widgets
6. Do not deeply nest widgets; extract into separate widgets instead
7. Do not deeply nest functions inside UI build methods; extract into separate methods instead
8. @important: In UI representation if SizedBox is used for spacing, surround it with new lines
9. Follow analysis_options.yaml linting rules
10. Do not use withOpacity method; use .withValues() instead (Flutter related)
11. @important: Do not nest anything that is Design System related inside UI code; extract into separate files and classes
12. Use curly brackets with 'case' statements in 'switch' blocks
13. Never hardcode colors; always use colors from Design System

14. Prefer not using spread operators in widget lists; use explicit list items instead
15. Prefer not to use ! operator; handle null safety properly
16. Separate sibling widgets used in "children" property with a new line
17. On top of each widget file add a short description of what the file contains and its purpose
18. When using "index" variable in loops or builders, prefer using more descriptive names like "itemIndex" or "widgetIndex"
19. When using if statements always surround them with new lines for better readability - same goes for other curly bracketed code blocks like for, while, switch, etc.
20. Name providers like stores eg. userStore, productStore, and so on.
21. Reference stores like this:

```dart
final UserStore userStore = context.watch<UserStore>();
```

22. Use Div utility widget from utility_widgets.dart for containers instead of Container widget directly unless there is a specific need for Container

## Documentation & Comments

1. From time to time use single line comments to explain non-obvious code sections
2. Add simple single line documentation comments for all methods and give them "/// @Method: " prefix but do not add this type of comment to flutter's build methods; same goes for createState methods
3. Prepend methods returning widgets with "/// @Widget: " comment
4. Prepend classes with "/// @Class: " comment but flutter state classes should not have this comment
5. Prepend enumerations with "/// @Enum: " comment
