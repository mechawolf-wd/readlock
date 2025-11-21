# Dart/Flutter Development Standards

Coding conventions and architectural patterns for the Readlock Flutter application. For content and writing guidelines, see [GUIDELINES.md](GUIDELINES.md).

## Code Architecture

### Naming Conventions

1. **No abbreviations** - use descriptive names (userProfile vs up)
2. **No underscore prefixes** - avoid private variable naming with \_
3. **Clarity over brevity** - longer names acceptable for clarity
4. **Widget methods** - name by function (NavigationItems vs buildNavigationItems)
5. **Constants** - extract hardcoded strings, use UPPER_SNAKE_CASE
6. **Provider naming** - use store pattern (userStore, productStore)

### Widget Architecture

7. **Component extraction** - avoid deep nesting, extract separate widgets
8. **Design system separation** - never nest design components in UI code
9. **Function extraction** - avoid deep nesting in build methods
10. **Utility widgets** - use Div.row/column instead of Container directly
11. **Spacing widgets** - use Spacing.height/width instead of SizedBox
12. **Typography consistency** - use typography.dart for all text

### Code Formatting

13. **Logical separation** - newlines between code sections, methods, properties
14. **Curly braces required** - never single-line if statements
15. **Switch statements** - always use curly brackets with case
16. **Widget lists** - newlines between sibling widgets
17. **Const optimization** - prefix widgets with const where applicable
18. **File documentation** - add purpose description at top of widget files

### Control Flow

19. **Extract conditions** - pull if statement contents into variables
20. **Avoid ternary in UI** - let functions handle decision logic
21. **No nested ternary** - avoid complex conditional operators
22. **Explicit over spread** - prefer explicit list items vs spread operators
23. **Descriptive indices** - use itemIndex/widgetIndex vs index
24. **Whitespace around blocks** - surround if/for/while with newlines

### Performance

25. **4-pixel rule** - use multiples of 4 for spacing values
26. **Avoid overengineering** - don't optimize before inspection
27. **Code reuse** - extract repeated code into methods/widgets

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
