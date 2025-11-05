# Project Overview and Flutter Basics

## Project Description: Relevant App

**Relevant** is a Flutter educational application featuring a multi-screen interface for learning and course management.

### Architecture

- **Main Navigation**: Three-tab interface (World, Books, Profile) with animated page transitions
- **Course System**: Structured learning content with sections, stories, and reflections
- **State Management**: Built-in Flutter StatefulWidget pattern with PageController

### Key Features

- Bottom navigation with smooth page transitions
- Course content delivery system with multiple content types
- Responsive design following Material Design 3
- Custom theming with seed-based color schemes

### Project Structure

```
lib/
├── constants/           # App-wide constants
├── course_screens/      # Course-related screens and components
│   ├── models/         # Data models (Course, CourseSection, etc.)
│   ├── widgets/        # Reusable course widgets
│   └── data/           # Course data management
├── screens/            # Main application screens
├── widgets/            # Shared UI components
└── main.dart          # App entry point
```

## Dart Basics

### Variables and Types

```dart
// Variable declarations
String name = 'John';
int age = 25;
double height = 5.9;
bool isActive = true;

// Null safety
String? nullableName;  // Can be null
String nonNullName = 'Required';  // Cannot be null

// Final and const
final String userId = 'user123';  // Runtime constant
const int maxRetries = 3;         // Compile-time constant
```

### Collections

```dart
// Lists
List<String> items = ['apple', 'banana'];
items.add('orange');

// Maps
Map<String, int> scores = {'alice': 100, 'bob': 85};
scores['charlie'] = 92;

// Sets
Set<String> uniqueItems = {'red', 'blue', 'green'};
```

### Functions

```dart
// Basic function
String greetUser(String name) {
  return 'Hello, $name!';
}

// Arrow function
String greetUserShort(String name) => 'Hello, $name!';

// Optional parameters
void processData(String data, {bool verbose = false}) {
  if (verbose) {
    print('Processing: $data');
  }
}
```

### Classes

```dart
class User {
  final String name;
  final int age;

  // Constructor
  User({required this.name, required this.age});

  // Method
  void introduce() {
    print('Hi, I am $name and I am $age years old');
  }
}

// Usage
User user = User(name: 'Alice', age: 30);
user.introduce();
```

### Null Safety

```dart
// Null-aware operators
String? nullableText;
String result = nullableText ?? 'Default';  // If null, use 'Default'

// Safe navigation
User? user;
String? name = user?.name;  // Returns null if user is null

// Non-null assertion (use carefully)
String definitelyNotNull = nullableText!;  // Throws if null
```

## Flutter Reactivity

### StatefulWidget vs StatelessWidget

#### StatelessWidget

Immutable widgets that don't change after creation:

```dart
class WelcomeText extends StatelessWidget {
  final String message;

  const WelcomeText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}
```

#### StatefulWidget

Widgets that can change state and rebuild:

```dart
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  void increment() {
    setState(() {  // Triggers rebuild
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### setState() Method

The core of Flutter reactivity:

```dart
void updateData() {
  setState(() {
    // All changes inside this function will trigger a rebuild
    currentIndex = newIndex;
    isLoading = false;
    errorMessage = null;
  });
}
```

### Widget Lifecycle

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize data, controllers, listeners
  }

  @override
  void dispose() {
    // Clean up controllers, listeners, timers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build UI (called every time setState is triggered)
    return Container();
  }
}
```

### Controllers and Reactivity

```dart
class PageNavigationState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
  }

  void handlePageChanged(int index) {
    setState(() {
      currentIndex = index;  // Updates UI automatically
    });
  }

  @override
  void dispose() {
    pageController.dispose();  // Prevent memory leaks
    super.dispose();
  }
}
```

### Key Reactivity Patterns

#### 1. State Updates

```dart
// Always use setState for state changes
void toggleActive() {
  setState(() {
    isActive = !isActive;
  });
}
```

#### 2. List Updates

```dart
void addItem(String item) {
  setState(() {
    items.add(item);  // List modification triggers rebuild
  });
}
```

#### 3. Conditional Rendering

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      if (isLoading)
        const CircularProgressIndicator()
      else
        ContentWidget(data: data),
    ],
  );
}
```

#### 4. Event Handling

```dart
Widget button() {
  return ElevatedButton(
    onPressed: () {
      // Event triggers state change
      setState(() {
        counter++;
      });
    },
    child: const Text('Press Me'),
  );
}
```

### Best Practices for Reactivity

1. **Minimize setState scope**: Only rebuild what's necessary
2. **Extract widgets**: Break large widgets into smaller, focused ones
3. **Use const constructors**: For widgets that don't change
4. **Dispose resources**: Always clean up controllers and listeners
5. **Avoid setState in build()**: Can cause infinite rebuild loops

### Example: Project's Navigation Reactivity

```dart
// From the Relevant app's MainNavigationScreen
void handlePageChanged(int index) {
  setState(() {
    currentIndex = index;  // Updates bottom navigation highlight
  });
}

void handleNavigationTap(int index) {
  pageController.animateToPage(index);  // Triggers handlePageChanged
}
```

This creates a reactive loop where user interaction → page change → state update → UI rebuild, providing smooth navigation experience.
