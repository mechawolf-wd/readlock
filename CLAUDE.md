# Dart/Flutter Development Standards

Coding conventions and architectural patterns for the Readlock Flutter application. For content and writing guidelines, see [GUIDELINES.md](GUIDELINES.md).

## Code Architecture

### Naming Conventions

1. **No abbreviations** - use descriptive names (userProfile vs up). Be specific with loading states (isCourseDataLoading vs isLoading)
2. **No underscore prefixes** - never prefix any declaration with \_
3. **Clarity over brevity** - longer names acceptable for clarity
4. **Widget methods** - name by function (eg. NavigationItems), use PascalCase, no "build" prefix
5. **Functional methods** - use camelCase for non-widget returning functions (eg. navigateToScreen)
6. **Icon definitions** - use PascalCase for icon widgets (CloseIcon vs closeIcon)
7. **Constants** - extract hardcoded strings, use UPPER_SNAKE_CASE

### Widget Architecture

8. **Component extraction** - avoid deep nesting, extract separate widgets
9. **Design system separation** - never nest design components in UI code
10. **Function extraction** - never nest functions inside the UI, unless very simple. NO logic (lambdas, functions, ternary operators) directly in widget tree
11. **Utility widgets** - use Div.row/column instead of Container. Avoid Padding, SizedBox, and other widgets that Div can handle. Never use Container when Div is sufficient
12. **Spacing widgets** - use Spacing.height/width instead of SizedBox
13. **Typography consistency** - use Typography widgets for all text, never raw Text() widget
14. **Style and icon extraction** - extract complex styling objects (BoxDecoration, TextStyle, EdgeInsets with multiple properties) to variables above the build method, keep simple one-liners inline. Extract complete icon widgets above the build method with PascalCase naming (CloseIcon). Only icon variable names should appear in UI tree, never inline Icon() constructors
15. **Loop extraction** - extract loops, iterations, and ListView builders from widget tree into separate methods with descriptive names
16. **Data transformation extraction** - extract complex data operations (.from(), .map(), nested property access) into intermediate variables for clarity
17. **Interaction widgets** - use GestureDetector instead of InkWell unless ripple effect is specifically needed

### Code Formatting

18. **Logical separation** - newlines between code sections, methods, properties (readability)
19. **Curly braces required** - never single-line if statements
20. **Switch statements** - always use curly brackets with switch instructions
21. **Widget lists** - newlines between sibling widgets in Div.row([]) and Div.column([]) arrays
22. **UI section comments** - use single-line comments to describe UI sections (eg. // Header, // Body content, // Looping over items, // Footer)

### Control Flow

23. **Extract conditions** - pull if statement contents into variables
24. **Avoid ternary in UI** - let functions handle decision logic
25. **No nested ternary** - avoid complex conditional operators
26. **Consistent loop syntax** - Never use spread operators (...) or for loops in widget building
27. **Explicit over spread** - prefer explicit list items vs spread operators
28. **Descriptive indices** - use itemIndex/widgetIndex vs index
29. **Whitespace around blocks** - surround if/for/while with newlines

### Performance

30. **4-pixel rule** - use multiples of 4 for spacing values
31. **Avoid overengineering** - don't optimize before inspection
32. **Code reuse** - extract repeated code into methods/widgets

## Development Principles

### Task Focus

- Execute exactly what's requested - nothing more, nothing less
- Prefer editing existing files over creating new ones
- Only create documentation when explicitly requested

### Code Quality

- Prioritize readability and maintainability
- Follow established patterns in this file
