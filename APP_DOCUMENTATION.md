# Readlock App Documentation

## Overview

Readlock is a Flutter-based educational app focused on design courses. It provides an interactive learning experience with various content types including text lessons, questions, reflections, and design showcases.

## App Architecture

### Core Structure

```
RelevantApp (Main App)
├── MainNavigation (Navigation Controller)
│   ├── CourseRoadmapScreen (Courses Tab)
│   │   └── Course sections with progress tracking
│   └── ProfileScreen (Profile Tab)
│       └── User statistics and achievements
```

### Directory Structure

```
lib/
├── main.dart                    # App entry point
├── main_navigation.dart         # Bottom navigation controller
├── globals.dart                 # Global variables and state
├── constants/                   # App-wide constants
│   ├── app_constants.dart      # General constants
│   ├── app_theme.dart          # Theme and colors
│   └── typography.dart         # Text styles
├── course_screens/             # Course-related screens
│   ├── course_detail_screen.dart    # Individual course viewer
│   ├── course_roadmap_screen.dart   # Course overview/roadmap
│   ├── models/                      # Data models
│   ├── data/                        # Course data management
│   ├── services/                    # Data services
│   └── widgets/                     # Course UI components
├── screens/                    # Other app screens
│   └── profile_screen.dart    # User profile
└── utility_widgets/           # Reusable UI components
    ├── layout/                # Layout utilities
    ├── text_animation/        # Text animations
    └── visual_effects/        # Visual effects
```

## Key Components

### 1. Navigation System

**MainNavigation** uses `IndexedStack` to preserve state between tabs:

- **Courses Tab**: Shows course roadmap
- **Profile Tab**: Displays user statistics

### 2. Course Content System

#### Content Flow

1. **CourseRoadmapScreen**: Displays course sections and progress
2. **CourseDetailScreen**: Shows individual content items in a vertical PageView
3. **JsonContentWidgetFactory**: Creates appropriate widgets based on content type

#### Content Types

- **IntroContent**: Course/section introductions with animated text
- **TextContent**: Regular lesson content with progressive text display
- **QuestionContent**: Interactive multiple-choice questions
- **TrueFalseQuestion**: Binary choice questions
- **FillGapQuestion**: Fill-in-the-blank exercises
- **IncorrectStatement**: Identify incorrect statements
- **EstimatePercentage**: Percentage estimation exercises
- **ReflectionContent**: Thought-provoking prompts
- **OutroContent**: Section/course conclusions
- **DesignExamplesShowcase**: Visual design examples

### 3. Widget Hierarchy

#### Course Detail Screen

```
CourseDetailScreen
├── PageView.builder (Vertical scrolling)
│   └── Content Widgets (via Factory)
│       ├── Question Widgets
│       │   ├── Question Text
│       │   ├── Answer Options
│       │   └── Explanation (after answer)
│       ├── Text Content Widgets
│       │   └── Progressive Text Animation
│       └── Other Content Types
└── Progress Bar (Bottom)
```

#### Question Widget Flow

1. User sees question with options
2. Selects an answer
3. Widget validates answer
4. Shows feedback (snackbar)
5. Displays explanation
6. Updates XP if correct

### 4. State Management

#### Current Implementation

- **Local State**: Each widget manages its own state using `StatefulWidget`
- **PageController**: Manages scroll position in PageView
- **Navigation State**: Preserved using IndexedStack

#### Known Issues

- PageView scroll position resets when question widgets call `setState()`
- This happens because state changes trigger rebuilds up the widget tree

### 5. Styling System

#### Design Tokens

- **Typography**: Centralized in `typography.dart`
- **Colors**: Defined in `app_theme.dart`
- **Spacing**: 4-pixel grid system
- **Padding**: Standardized padding presets

#### Custom Widgets

- **Div**: Container wrapper (row/column)
- **Spacing**: Consistent spacing widget
- **ProgressiveText**: Animated text display
- **TypewriterText**: Typewriter effect

### 6. Data Layer

#### Course Data Structure

```json
{
  "id": "course-id",
  "title": "Course Title",
  "color": "blue/green/purple",
  "sections": [
    {
      "id": "section-id",
      "title": "Section Title",
      "content": [
        {
          "entityType": "content-type",
          "id": "content-id"
          // Type-specific fields
        }
      ]
    }
  ]
}
```

#### Data Loading

1. **CourseData** class loads JSON from assets
2. **JsonCourseDataService** parses JSON to models
3. **Course Model** provides strongly-typed data

### 7. User Experience Features

#### Progress Tracking

- Linear progress bar at bottom of course screen
- Visual indicators for completed sections
- XP rewards for correct answers

#### Interactive Elements

- Swipeable course cards
- Vertical page navigation
- Interactive questions with immediate feedback
- Animated text reveals

#### Visual Feedback

- Color-coded answer validation
- Snackbar notifications
- Progress animations
- Theme-aware styling

## Code Conventions (from CLAUDE.md)

### Naming

- No abbreviations in names
- No underscore prefixes for private members
- Descriptive variable names
- PascalCase for widget builder methods
- UPPER_SNAKE_CASE for constants

### Structure

- Extract hardcoded strings to constants
- Avoid deeply nested widgets
- Use curly braces for all control structures
- Separate logical sections with newlines
- Use Div and Spacing utility widgets

### Best Practices

- Prefix const widgets with `const`
- Follow 4-pixel spacing rule
- Extract complex UI into separate widgets
- Keep business logic out of UI code

## Future Improvements

### Potential Enhancements

1. **State Management**: Consider Provider or Riverpod for global state
2. **Scroll Preservation**: Implement AutomaticKeepAliveClientMixin
3. **Offline Support**: Cache course data locally
4. **Analytics**: Track user learning patterns
5. **Accessibility**: Add screen reader support
6. **Testing**: Comprehensive widget and integration tests

### Performance Optimizations

1. Lazy loading for course content
2. Image caching for design examples
3. Preload next content item
4. Optimize animation performance

## Technical Stack

- **Framework**: Flutter
- **Language**: Dart
- **Fonts**: Google Fonts (Crimson Text)
- **Theme**: Material Design 3
- **State**: StatefulWidget (local state)
- **Navigation**: BottomNavigationBar with IndexedStack
