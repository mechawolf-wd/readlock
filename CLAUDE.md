# Dart/Flutter Style Guide

## Naming Conventions

- Do not use abbreviations in variable or method names
- Do not use \_ underscore prefix for private variables or methods
- Use descriptive names for variables and methods (e.g., userProfile instead of up)
- When using descriptive names, allow longer names if it improves clarity (e.g., fetchUserProfileData instead of fetchData)
- Don't use "build" prefix for methods that build widgets; name them according to what they build (e.g., navigationItems instead of buildNavigationItems)
- Use meaningful names for all parameters, including callback parameters
- Extract hardcoded strings into separate constants and use UPPER_SNAKE_CASE for them

## Code Structure & Organization

- Use new lines to separate logical sections of code
- Use const constructors where possible
- Do not use single line if and other statements without curly braces
- Extract contents of if statements into separate variables for clarity
- Avoid deeply nested ternary operators in UI code
- Extract repeated code into separate methods or widgets
- Do not deeply nest widgets; extract into separate widgets instead
- Do not deeply nest functions inside UI build methods; extract into separate methods instead

## Type System & Best Practices

- Do not use dynamic type unless absolutely necessary
- Prefer using styling constants over hardcoded values

## Documentation & Comments

- From time to time use single line comments to explain non-obvious code sections
- Add simple single line documentation comments for all methods and give them "// Method - " prefix
- Prefix methods returning widgets with "// @Widget: " comment

```

```
