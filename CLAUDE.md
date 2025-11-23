# Dart/Flutter Development Standards

Coding conventions and architectural patterns for the Readlock Flutter application. For content and writing guidelines, see [GUIDELINES.md](GUIDELINES.md).

## Code Architecture

### Naming Conventions

1. **No abbreviations** - use descriptive names (userProfile vs up). Be specific with loading states (isCourseDataLoading vs isLoading)
2. **No underscore prefixes** - avoid private variable naming with \_
3. **Clarity over brevity** - longer names acceptable for clarity
4. **Widget methods** - name by function (NavigationItems), use camelCase for functions (navigateToScreen vs NavigateToScreen), use PascalCase for icon definitions (CloseIcon vs closeIcon) - don't use "build" prefix for method building widgets.
5. **Constants** - extract hardcoded strings, use UPPER_SNAKE_CASE

### Widget Architecture

7. **Component extraction** - avoid deep nesting, extract separate widgets
8. **Design system separation** - never nest design components in UI code
9. **Function extraction** - never nest functions inside the UI, unless very simple. NO logic (lambdas, functions, ternary operators) directly in widget tree
10. **Utility widgets** - use Div.row/column instead of Container. Avoid Padding, SizedBox, and other widgets that Div can handle. Never use Container when Div is sufficient
11. **Spacing widgets** - use Spacing.height/width instead of SizedBox
12. **Typography consistency** - use Typography widgets for all text, never raw Text() widget
13. **Style and icon extraction** - extract complex styling objects (BoxDecoration, TextStyle, EdgeInsets with multiple properties) to variables above the build method, keep simple one-liners inline. Extract complete icon widgets above the build method with PascalCase naming (CloseIcon). Only icon variable names should appear in UI tree, never inline Icon() constructors
14. **Loop extraction** - extract loops, iterations, and ListView builders from widget tree into separate methods with descriptive names
15. **Data transformation extraction** - extract complex data operations (.from(), .map(), nested property access) into intermediate variables for clarity
16. **Interaction widgets** - use GestureDetector instead of InkWell unless ripple effect is specifically needed

### Code Formatting

17. **Logical separation** - newlines between code sections, methods, properties (readability)
18. **Curly braces required** - never single-line if statements
19. **Switch statements** - always use curly brackets with switch instructions
20. **Widget lists** - newlines between sibling widgets

### Control Flow

21. **Extract conditions** - pull if statement contents into variables
22. **Avoid ternary in UI** - let functions handle decision logic
23. **No nested ternary** - avoid complex conditional operators
24. **Consistent loop syntax** - Never use spread operators (...) or for loops in widget building
25. **Explicit over spread** - prefer explicit list items vs spread operators
26. **Descriptive indices** - use itemIndex/widgetIndex vs index
27. **Whitespace around blocks** - surround if/for/while with newlines

### Performance

28. **4-pixel rule** - use multiples of 4 for spacing values
29. **Avoid overengineering** - don't optimize before inspection
30. **Code reuse** - extract repeated code into methods/widgets

## Development Principles

### Task Focus

- Execute exactly what's requested - nothing more, nothing less
- Prefer editing existing files over creating new ones
- Only create documentation when explicitly requested

### Code Quality

- Prioritize readability and maintainability
- Follow established patterns in this file
