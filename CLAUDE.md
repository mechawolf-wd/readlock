# Dart/Flutter Style Guide

## Naming Conventions

1. Do not use abbreviations in variable or method names, same goes for callback parameters and function parameters
2. Do not use \_ underscore prefix for private variables or methods
3. Use descriptive names for variables and methods (e.g., userProfile instead of up)
4. When using descriptive names, allow longer names if it improves clarity (e.g., fetchUserProfileData instead of fetchData)
5. Don't use "build" prefix for methods that return flutter widgets or lists of widgets; name them according to what they build (e.g., NavigationItems instead of buildNavigationItems) using PascalCase
6. Extract hardcoded strings into separate constants and use UPPER_SNAKE_CASE for them
7. Do not use ternary expressions in the UI to call functions - let the function handle the decision logic instead.
8. Use new lines to separate logical sections of code, including between class properties and methods, between methods, and within methods (e.g., between variable declarations, main logic, and return statements).
9. Do not use single line if and other statements without curly braces
10. Extract contents of if statements into separate variables for clarity
11. Avoid deeply nested ternary operators in UI code
12. Extract repeated code into separate methods or widgets
13. Do not deeply nest widgets; extract into separate widgets instead
14. Do not deeply nest functions inside UI build methods; extract into separate methods instead
15. @important: Do not nest anything that is Design System related inside UI code; extract into separate files and classes
16. Use curly brackets with 'case' statements in 'switch' blocks
17. Prefer not using spread operators in widget lists; use explicit list items instead
18. On top of each widget file add a short description of what the file contains and its purpose
19. When using "index" variable in loops or builders, prefer using more descriptive names like "itemIndex" or "widgetIndex"
20. When using if statements always surround them with new lines for better readability - same goes for other curly bracketed code blocks like for, while, switch, etc.
21. Name providers like stores eg. userStore, productStore, and so on.
22. Use Div (Div.row or Div.column) utility widget from utility_widgets.dart for containers instead of Container widget directly unless there is a specific need for Container
23. Use Spacing utility (Spacing.height or Spacing.width) widget from utility_widgets.dart for spacing instead of SizedBox widget directly unless there is a specific need for SizedBox
24. Use typography.dart for text.
