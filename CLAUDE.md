# Dart/Flutter Development Standards

Coding conventions and architectural patterns for the Readlock Flutter application. For content and writing guidelines, see [GUIDELINES.md](GUIDELINES.md).

## Code Architecture

### Naming Conventions

1. **No abbreviations** - use descriptive names (userProfile vs up)
2. **No underscore prefixes** - avoid private variable naming with \_
3. **Clarity over brevity** - longer names acceptable for clarity
4. **Widget methods** - name by function (NavigationItems vs buildNavigationItems), use camelCase for functions (navigateToScreen vs NavigateToScreen), use PascalCase for icon definitions (CloseIcon vs closeIcon)
5. **Constants** - extract hardcoded strings, use UPPER_SNAKE_CASE
6. **Provider naming** - use store pattern (userStore, productStore)
`
### Widget Architecture

7. **Component extraction** - avoid deep nesting, extract separate widgets
8. **Design system separation** - never nest design components in UI code
9. **Function extraction** - never nest functions inside the UI, unless very simple
10. **Utility widgets** - use Div.row/column instead of Container directly
11. **Spacing widgets** - use Spacing.height/width instead of SizedBox
12. **Typography consistency** - use typography.dart for all text
13. **Style extraction** - extract complex styling objects (BoxDecoration, TextStyle, EdgeInsets with multiple properties) to variables above the build method, keep simple one-liners inline. Also extract complete icon widgets above the build method (not just IconData constants). Use a `Style` class at the bottom of the file for organizing extracted styles
14. **Loop extraction** - extract loops, iterations, and ListView builders from widget tree into separate methods with descriptive names

### Code Formatting

15. **Logical separation** - newlines between code sections, methods, properties
16. **Curly braces required** - never single-line if statements
17. **Switch statements** - always use curly brackets with case
18. **Widget lists** - newlines between sibling widgets
19. **Const optimization** - prefix widgets with const where applicable
20. **File documentation** - add purpose description at top of widget files

### Control Flow

21. **Extract conditions** - pull if statement contents into variables
22. **Avoid ternary in UI** - let functions handle decision logic
23. **No nested ternary** - avoid complex conditional operators
24. **Consistent loop syntax** - always use .map().toList() for collections, never spread operators (...) or for loops in widget building
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
- Follow established patterns in the codebase
- Use existing libraries and utilities
- Maintain consistency with project conventions
