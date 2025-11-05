# Flutter Linting Setup Guide

This guide will help you set up the most common and useful Flutter linters for your project to maintain code quality and consistency.

## Table of Contents

1. [Basic Flutter Lints](#basic-flutter-lints)
2. [Very Good Analysis](#very-good-analysis)
3. [Custom Lint Rules](#custom-lint-rules)
4. [IDE Integration](#ide-integration)
5. [CI/CD Integration](#cicd-integration)

## Basic Flutter Lints

Flutter comes with built-in linting through `flutter_lints`. This is already included in your project.

### Current Setup

Your project already has:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_lints: ^5.0.0
```

### Enhancing analysis_options.yaml

Update your `analysis_options.yaml` file for stricter linting:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"

  strong-mode:
    implicit-casts: false
    implicit-dynamic: false

  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
    dead_code: warning

linter:
  rules:
    # Error Rules
    avoid_empty_else: true
    avoid_returning_null_for_future: true
    avoid_slow_async_io: true
    cancel_subscriptions: true
    close_sinks: true
    comment_references: true
    control_flow_in_finally: true
    empty_statements: true
    hash_and_equals: true
    invariant_booleans: true
    iterable_contains_unrelated_type: true
    list_remove_unrelated_type: true
    literal_only_boolean_expressions: true
    no_adjacent_strings_in_list: true
    no_duplicate_case_values: true
    no_logic_in_create_state: true
    prefer_void_to_null: true
    test_types_in_equals: true
    throw_in_finally: true
    unnecessary_statements: true
    unrelated_type_equality_checks: true
    valid_regexps: true

    # Style Rules
    always_declare_return_types: true
    always_put_control_body_on_new_line: true
    always_put_required_named_parameters_first: true
    always_specify_types: false # Can be overwhelming, set to true if preferred
    annotate_overrides: true
    avoid_bool_literals_in_conditional_expressions: true
    avoid_catches_without_on_clauses: true
    avoid_catching_errors: true
    avoid_double_and_int_checks: true
    avoid_field_initializers_in_const_classes: true
    avoid_function_literals_in_foreach_calls: true
    avoid_implementing_value_types: true
    avoid_init_to_null: true
    avoid_null_checks_in_equality_operators: true
    avoid_positional_boolean_parameters: true
    avoid_print: true
    avoid_private_typedef_functions: true
    avoid_redundant_argument_values: true
    avoid_relative_lib_imports: true
    avoid_renaming_method_parameters: true
    avoid_return_types_on_setters: true
    avoid_returning_null: true
    avoid_returning_null_for_void: true
    avoid_returning_this: true
    avoid_setters_without_getters: true
    avoid_shadowing_type_parameters: true
    avoid_single_cascade_in_expression_statements: true
    avoid_types_as_parameter_names: true
    avoid_types_on_closure_parameters: true
    avoid_unnecessary_containers: true
    avoid_unused_constructor_parameters: true
    avoid_void_async: true
    await_only_futures: true
    camel_case_extensions: true
    camel_case_types: true
    cascade_invocations: true
    cast_nullable_to_non_nullable: true
    constant_identifier_names: true
    curly_braces_in_flow_control_structures: true
    directives_ordering: true
    empty_catches: true
    empty_constructor_bodies: true
    exhaustive_cases: true
    file_names: true
    flutter_style_todos: true
    implementation_imports: true
    join_return_with_assignment: true
    leading_newlines_in_multiline_strings: true
    library_names: true
    library_prefixes: true
    lines_longer_than_80_chars: false # Set to true if you want 80 char limit
    missing_whitespace_between_adjacent_strings: true
    no_runtimeType_toString: true
    non_constant_identifier_names: true
    null_closures: true
    omit_local_variable_types: true
    one_member_abstracts: true
    only_throw_errors: true
    overridden_fields: true
    package_api_docs: true
    package_names: true
    package_prefixed_library_names: true
    parameter_assignments: true
    prefer_adjacent_string_concatenation: true
    prefer_asserts_in_initializer_lists: true
    prefer_asserts_with_message: true
    prefer_collection_literals: true
    prefer_conditional_assignment: true
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    prefer_constructors_over_static_methods: true
    prefer_contains: true
    prefer_equal_for_default_values: true
    prefer_expression_function_bodies: true
    prefer_final_fields: true
    prefer_final_in_for_each: true
    prefer_final_locals: true
    prefer_for_elements_to_map_fromIterable: true
    prefer_foreach: true
    prefer_function_declarations_over_variables: true
    prefer_generic_function_type_aliases: true
    prefer_if_elements_to_conditional_expressions: true
    prefer_if_null_operators: true
    prefer_initializing_formals: true
    prefer_inlined_adds: true
    prefer_int_literals: true
    prefer_interpolation_to_compose_strings: true
    prefer_is_empty: true
    prefer_is_not_empty: true
    prefer_is_not_operator: true
    prefer_iterable_whereType: true
    prefer_null_aware_operators: true
    prefer_relative_imports: true
    prefer_single_quotes: true
    prefer_spread_collections: true
    prefer_typing_uninitialized_variables: true
    provide_deprecation_message: true
    public_member_api_docs: false # Set to true for libraries
    recursive_getters: true
    slash_for_doc_comments: true
    sort_child_properties_last: true
    sort_constructors_first: true
    sort_pub_dependencies: true
    sort_unnamed_constructors_first: true
    type_annotate_public_apis: true
    type_init_formals: true
    unawaited_futures: true
    unnecessary_await_in_return: true
    unnecessary_brace_in_string_interps: true
    unnecessary_const: true
    unnecessary_getters_setters: true
    unnecessary_lambdas: true
    unnecessary_new: true
    unnecessary_null_aware_assignments: true
    unnecessary_null_checks: true
    unnecessary_null_in_if_null_operators: true
    unnecessary_overrides: true
    unnecessary_parenthesis: true
    unnecessary_raw_strings: true
    unnecessary_string_escapes: true
    unnecessary_string_interpolations: true
    unnecessary_this: true
    unrelated_type_equality_checks: true
    unsafe_html: true
    use_build_context_synchronously: true
    use_full_hex_values_for_flutter_colors: true
    use_function_type_syntax_for_parameters: true
    use_if_null_to_convert_nulls_to_bools: true
    use_is_even_rather_than_modulo: true
    use_key_in_widget_constructors: true
    use_late_for_private_fields_and_variables: true
    use_named_constants: true
    use_raw_strings: true
    use_rethrow_when_possible: true
    use_setters_to_change_properties: true
    use_string_buffers: true
    use_test_throws_matchers: true
    use_to_and_as_if_applicable: true
    void_checks: true
```

## Very Good Analysis

Very Good Analysis provides an even more comprehensive set of lint rules used by the Very Good Ventures team.

### Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  very_good_analysis: ^6.0.0
```

### Setup

Replace your `analysis_options.yaml` with:

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - build/**
    - lib/generated/**

linter:
  rules:
    # Override any rules you don't want
    public_member_api_docs: false
    lines_longer_than_80_chars: false
    always_specify_types: false
```

### Run Analysis

```bash
# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

## Custom Lint Rules

For project-specific rules, you can create custom lint rules using the `custom_lint` package.

### Installation

```yaml
dev_dependencies:
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10 # Example: Riverpod-specific lints
```

### Configuration

Create `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

## IDE Integration

### VS Code

Install the **Dart** and **Flutter** extensions. Add to your `.vscode/settings.json`:

```json
{
  "dart.analysisServerArgs": ["--enable-experiment=enhanced-enums"],
  "dart.lineLength": 120,
  "dart.flutterCreateAndroidLanguage": "kotlin",
  "dart.flutterCreateIOSLanguage": "swift",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.showInspectorNotificationsForWidgetErrors": true,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true
}
```

### Android Studio / IntelliJ

1. Install **Dart** and **Flutter** plugins
2. Go to `File > Settings > Editor > Code Style > Dart`
3. Set line length to 120
4. Enable "Format code on save"
5. Go to `File > Settings > Editor > Inspections > Dart`
6. Enable all relevant inspections

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/analysis.yml`:

```yaml
name: Code Analysis

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analysis:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.0"
          channel: "stable"

      - name: Install dependencies
        run: flutter pub get

      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Analyze project source
        run: flutter analyze --fatal-infos

      - name: Run custom lint
        run: dart run custom_lint
```

### Pre-commit Hooks

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: flutter-format
        name: Flutter Format
        entry: flutter format
        language: system
        files: \.dart$

      - id: flutter-analyze
        name: Flutter Analyze
        entry: flutter analyze
        language: system
        files: \.dart$
        pass_filenames: false
```

Install pre-commit:

```bash
pip install pre-commit
pre-commit install
```

## Running Lints

### Command Line

```bash
# Format code
dart format .

# Analyze with all lint rules
flutter analyze

# Fix auto-fixable issues
dart fix --apply

# Run custom lints
dart run custom_lint
```

### Make Commands

Add to your `Makefile`:

```makefile
.PHONY: lint format analyze fix

lint: format analyze

format:
	dart format .

analyze:
	flutter analyze --fatal-infos

fix:
	dart fix --apply

clean-lint:
	dart fix --apply && dart format .
```

## Recommended Rules for Your Project

Based on your existing code style (from CLAUDE.md), these rules align well:

```yaml
linter:
  rules:
    # Matches your style guide
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_final_fields: true
    avoid_print: true
    prefer_single_quotes: true
    sort_child_properties_last: true
    sort_constructors_first: true
    use_key_in_widget_constructors: true

    # Documentation (matches your @Method: and @Widget: comments)
    public_member_api_docs: false # You use custom format

    # Code organization
    directives_ordering: true
    avoid_unnecessary_containers: true
    prefer_is_empty: true
    prefer_is_not_empty: true
```

## Troubleshooting

### Common Issues

1. **Too many linting errors**: Start with basic `flutter_lints` and gradually add more rules
2. **Performance issues**: Exclude generated files in `analyzer.exclude`
3. **Conflicting rules**: Override specific rules in your `analysis_options.yaml`

### Gradual Migration

1. Start with `flutter_lints`
2. Add `very_good_analysis` with many rules disabled
3. Gradually enable more rules as you fix code
4. Use `dart fix --apply` to auto-fix when possible

## Next Steps

1. Choose your preferred linting setup (start with enhanced `flutter_lints`)
2. Update your `analysis_options.yaml`
3. Run `flutter analyze` to see current issues
4. Fix issues gradually or in batches
5. Set up IDE integration for real-time feedback
6. Add CI/CD checks to prevent regressions
