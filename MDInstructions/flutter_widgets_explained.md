# Flutter Widgets vs Web Development

## Core Concepts

Flutter widgets are the building blocks of the UI, similar to HTML elements but more composable and reactive. Every piece of UI is a widget - buttons, text, layouts, animations, and even styling.

## Widget Inheritance & Architecture

### Stateless Widgets

- **Like**: Pure functions in React or simple HTML elements
- **Inherits from**: StatelessWidget
- **Purpose**: Displays static content that doesn't change
- **Example**: Text, Icons, static layouts

### Stateful Widgets

- **Like**: React class components with state
- **Inherits from**: StatefulWidget + State<T>
- **Purpose**: Manages changing data and rebuilds UI when state changes
- **Example**: Forms, counters, animated elements

## Layout Widgets - Core Differences

### Container vs SizedBox vs Padding

These look similar but serve different purposes:

**Container** - The Swiss Army knife

```dart
Container(
  width: 100,
  height: 100,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  decoration: BoxDecoration(color: Colors.blue),
  child: Text('Hello'),
)
```

- **Use when**: You need styling (colors, borders, shadows) + sizing + spacing
- **Performance**: Heavier - creates multiple render objects
- **Like**: `<div>` with full CSS styling capabilities

**SizedBox** - Just for sizing

```dart
SizedBox(
  width: 100,
  height: 100,
  child: Text('Hello'),
)
// Or for spacing
SizedBox(height: 16) // Like margin/padding
```

- **Use when**: You only need fixed width/height or spacing
- **Performance**: Lighter - single purpose
- **Like**: CSS `width` and `height` properties only

**Padding** - Just for inner spacing

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)
```

- **Use when**: You only need inner spacing, no styling
- **Performance**: Lighter than Container
- **Like**: CSS `padding` property only

### Column vs Row vs Flex

All are flex containers but with different default directions:

**Column** - Vertical flex

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,    // Vertical alignment
  crossAxisAlignment: CrossAxisAlignment.start,   // Horizontal alignment
  children: [Text('A'), Text('B')],
)
```

- **Main axis**: Vertical (top to bottom)
- **Cross axis**: Horizontal (left to right)
- **Like**: `flex-direction: column`

**Row** - Horizontal flex

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Horizontal alignment
  crossAxisAlignment: CrossAxisAlignment.center,     // Vertical alignment
  children: [Text('A'), Text('B')],
)
```

- **Main axis**: Horizontal (left to right)
- **Cross axis**: Vertical (top to bottom)
- **Like**: `flex-direction: row`

**Flex** - Configurable direction

```dart
Flex(
  direction: Axis.vertical, // or Axis.horizontal
  children: [Text('A'), Text('B')],
)
```

- **Use when**: Direction changes dynamically
- **Column and Row**: Are just Flex with fixed directions

### Stack vs Positioned vs Align

For overlapping widgets:

**Stack** - The container

```dart
Stack(
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    Positioned(
      top: 20,
      left: 20,
      child: Text('Overlay'),
    ),
  ],
)
```

- **Like**: CSS `position: relative` container
- **Children**: Can be positioned absolutely within it

**Positioned** - Absolute positioning within Stack

```dart
Positioned(
  top: 10,    // Distance from top
  right: 10,  // Distance from right
  child: Icon(Icons.close),
)
```

- **Like**: CSS `position: absolute`
- **Must be**: Direct child of Stack
- **Use when**: You need precise positioning

**Align** - Relative positioning within Stack

```dart
Align(
  alignment: Alignment.topRight,
  child: Icon(Icons.close),
)
```

- **Like**: CSS `position: absolute` with predefined positions
- **Easier**: Than Positioned for simple alignments
- **Options**: topLeft, center, bottomRight, etc.

### Expanded vs Flexible vs Spacer

For controlling space in Row/Column:

**Expanded** - Takes all available space

```dart
Row(
  children: [
    Text('Fixed'),
    Expanded(child: Text('Takes remaining space')),
    Text('Fixed'),
  ],
)
```

- **Behavior**: Forces child to fill available space
- **Like**: CSS `flex: 1`
- **Use when**: You want child to take all remaining space

**Flexible** - Takes space but can be smaller

```dart
Row(
  children: [
    Text('Fixed'),
    Flexible(child: Text('Can be smaller than available space')),
    Text('Fixed'),
  ],
)
```

- **Behavior**: Child can shrink if it doesn't need all space
- **Like**: CSS `flex-shrink: 1`
- **Use when**: Child should be flexible but not forced to fill

**Spacer** - Just empty space

```dart
Row(
  children: [
    Text('Left'),
    Spacer(), // Pushes everything apart
    Text('Right'),
  ],
)
```

- **Behavior**: Creates flexible empty space
- **Like**: CSS `margin: auto` or `flex: 1` on empty div
- **Use when**: You just need space between widgets

### ListView vs Column vs SingleChildScrollView

For vertical lists:

**Column** - No scrolling, fixed height

```dart
Column(
  children: [Text('A'), Text('B'), Text('C')],
)
```

- **Scrolling**: None - will overflow if too tall
- **Performance**: All children built at once
- **Use when**: Few children, definitely fits on screen

**SingleChildScrollView** - Makes any widget scrollable

```dart
SingleChildScrollView(
  child: Column(
    children: [Text('A'), Text('B'), Text('C')],
  ),
)
```

- **Scrolling**: Yes, for any child widget
- **Performance**: All children built at once
- **Use when**: Unknown height content that might overflow

**ListView** - Built for scrolling lists

```dart
ListView(
  children: [Text('A'), Text('B'), Text('C')],
)
// Or better for performance:
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => Text(items[index]),
)
```

- **Scrolling**: Built-in, optimized
- **Performance**: Can lazy-load with `.builder`
- **Use when**: Known list of items, especially long lists

### Wrap vs Row vs Column

For flowing layouts:

**Row** - Single horizontal line

```dart
Row(
  children: [Text('A'), Text('B'), Text('C')],
)
```

- **Overflow**: Will overflow if children too wide
- **Lines**: Single line only

**Column** - Single vertical line

```dart
Column(
  children: [Text('A'), Text('B'), Text('C')],
)
```

- **Overflow**: Will overflow if children too tall
- **Lines**: Single column only

**Wrap** - Multiple lines/columns as needed

```dart
Wrap(
  direction: Axis.horizontal, // or Axis.vertical
  spacing: 8,    // Space between items on same line
  runSpacing: 8, // Space between lines
  children: [Text('A'), Text('B'), Text('C'), Text('D')],
)
```

- **Overflow**: Wraps to next line/column
- **Lines**: Multiple lines/columns as needed
- **Like**: CSS `flex-wrap: wrap`

## Quick Decision Guide

**Need styling (colors, borders, shadows)?**

- Yes → `Container`
- No, just spacing → `Padding` or `SizedBox`

**Arranging multiple children?**

- Horizontally → `Row`
- Vertically → `Column`
- With wrapping → `Wrap`
- Overlapping → `Stack`

**Child might overflow?**

- Known list → `ListView`
- Unknown content → `SingleChildScrollView`
- Should wrap → `Wrap`

**Controlling space in Row/Column?**

- Fill all space → `Expanded`
- Flexible space → `Flexible`
- Just empty space → `Spacer`

## Interactive Widgets

### GestureDetector

- **Like**: JavaScript event listeners (`onClick`, `onHover`, etc.)
- **Inherits from**: StatelessWidget
- **Purpose**: Detects gestures (tap, drag, swipe) on child widgets
- **Web equivalent**: Adding event listeners to DOM elements

### InkWell / Material Button

- **Like**: HTML `<button>` with Material Design ripple effects
- **Inherits from**: StatelessWidget
- **Purpose**: Provides Material Design tap feedback and handling

## Navigation Widgets

### PageView

- **Like**: CSS carousel or slider component
- **Inherits from**: StatefulWidget
- **Purpose**: Swipeable pages, like Instagram stories or onboarding screens

### Navigator

- **Like**: React Router or Vue Router
- **Inherits from**: StatefulWidget (managed by Flutter)
- **Purpose**: Manages app navigation stack (push/pop screens)

## Styling Widgets

### Theme / ThemeData

- **Like**: CSS custom properties (CSS variables) or SCSS variables
- **Purpose**: Centralized styling that cascades down the widget tree
- **Web equivalent**: CSS `:root` variables or theming systems

### BoxDecoration

- **Like**: CSS styling properties combined
- **Purpose**: Provides background color, gradients, borders, shadows, border radius
- **Web equivalent**: Multiple CSS properties like `background`, `border`, `box-shadow`

### TextStyle

- **Like**: CSS text properties
- **Purpose**: Defines font, size, color, weight, spacing for text
- **Web equivalent**: `font-family`, `font-size`, `color`, `font-weight`

## Animation Widgets

### AnimatedContainer

- **Like**: CSS transitions on container properties
- **Inherits from**: StatefulWidget
- **Purpose**: Automatically animates changes to container properties
- **Web equivalent**: CSS `transition` property

### AnimationController

- **Like**: Web Animations API or requestAnimationFrame
- **Inherits from**: Animation system
- **Purpose**: Controls timing and progress of animations

## Form Widgets

### TextField

- **Like**: HTML `<input>` or `<textarea>`
- **Inherits from**: StatefulWidget
- **Purpose**: Text input with validation, formatting, and styling

### Form / FormField

- **Like**: HTML `<form>` with validation
- **Inherits from**: StatefulWidget
- **Purpose**: Groups form fields and handles validation

## Display Widgets

### Text

- **Like**: HTML text nodes or `<span>`
- **Inherits from**: StatelessWidget
- **Purpose**: Displays styled text

### Image

- **Like**: HTML `<img>`
- **Inherits from**: StatefulWidget
- **Purpose**: Displays images from network, assets, or memory

### Icon

- **Like**: Font icons or SVG icons
- **Inherits from**: StatelessWidget
- **Purpose**: Displays vector icons

## Scrolling Widgets

### SingleChildScrollView

- **Like**: CSS `overflow: scroll` on a container
- **Inherits from**: StatelessWidget
- **Purpose**: Makes a single child scrollable

### ListView

- **Like**: Virtual scrolling lists (React virtualized)
- **Inherits from**: StatefulWidget
- **Purpose**: Efficiently displays scrollable lists of items

## Key Differences from Web Development

1. **Everything is a Widget**: No separation between structure (HTML) and styling (CSS)
2. **Composition over Inheritance**: Build complex widgets by combining simple ones
3. **Declarative**: Describe what the UI should look like, not how to build it
4. **Reactive**: UI automatically updates when state changes
5. **No CSS**: Styling is done through widget properties and specialized styling widgets
6. **Built-in Animations**: Animation support is first-class, not an afterthought
7. **Platform Adaptive**: Same code runs on mobile, web, and desktop

## Practical Examples & Common Patterns

### Card with Shadow and Rounded Corners

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        spreadRadius: 2,
      ),
    ],
  ),
  child: Text('Card Content'),
)
```

**CSS Equivalent:**

```css
.card {
  padding: 16px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
```

### Flexible Layout with Spacing

```dart
Column(
  children: [
    Text('Header'),
    SizedBox(height: 16), // Like margin-bottom: 16px
    Expanded(          // Like flex: 1
      child: ListView(...),
    ),
    SizedBox(height: 8),
    ElevatedButton(...), // Fixed at bottom
  ],
)
```

### Clickable Card with Feedback

```dart
GestureDetector(
  onTap: () => print('Tapped!'),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('Tap me'),
  ),
)
```

### Responsive Grid Layout

```dart
Wrap(
  spacing: 16,
  runSpacing: 16,
  children: items.map((item) =>
    Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(item.title)),
    ),
  ).toList(),
)
```

### Loading States

```dart
// Show loading spinner
if (isLoading)
  Center(child: CircularProgressIndicator())
else
  ListView(children: items)

// Or with AnimatedSwitcher for smooth transitions
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: isLoading
    ? CircularProgressIndicator(key: ValueKey('loading'))
    : ListView(key: ValueKey('content'), children: items),
)
```

### Form with Validation

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Email required';
          if (!value!.contains('@')) return 'Invalid email';
          return null;
        },
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### Image with Fallback

```dart
Image.network(
  imageUrl,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) =>
    Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported),
    ),
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(
      width: 100,
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
            : null,
        ),
      ),
    );
  },
)
```

### Navigation Patterns

```dart
// Navigate to new screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DetailScreen(item: item)),
);

// Pop back
Navigator.pop(context);

// Replace current screen
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
);
```

### Bottom Sheet (Like Modal)

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => Container(
    height: MediaQuery.of(context).size.height * 0.7,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: // Your content here
  ),
);
```

### Animated Button States

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  padding: EdgeInsets.symmetric(
    horizontal: isPressed ? 12 : 16,
    vertical: isPressed ? 8 : 12,
  ),
  decoration: BoxDecoration(
    color: isPressed ? Colors.blue[700] : Colors.blue,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Press me', style: TextStyle(color: Colors.white)),
)
```

### Safe Area for Notches/Status Bar

```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        // Content that won't be hidden by notch/status bar
      ],
    ),
  ),
)
```

## Performance Tips

### Use const constructors when possible

```dart
// Good
const Text('Static text')
const SizedBox(height: 16)
const Icon(Icons.home)

// Avoid
Text('Static text')  // Creates new instance each rebuild
```

### ListView.builder for long lists

```dart
// Good for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
)

// Avoid for long lists (creates all items at once)
ListView(
  children: items.map((item) => ListTile(title: Text(item))).toList(),
)
```

### Extract widgets to reduce rebuilds

```dart
// Good - MyCustomWidget only rebuilds when its props change
class MyScreen extends StatefulWidget {
  Widget build(context) {
    return Column(
      children: [
        MyCustomWidget(data: someData),
        // Other widgets
      ],
    );
  }
}

// Avoid - inline widgets rebuild with parent
Widget build(context) {
  return Column(
    children: [
      Container(
        // Complex widget tree that rebuilds unnecessarily
      ),
    ],
  );
}
```

## Common Patterns in This App

### Course Card Pattern

```dart
GestureDetector(
  onTap: () => onCourseSelected(course),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(/* course colors */),
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    ),
    child: Padding(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.title, style: AppTheme.headingMedium),
          SizedBox(height: AppTheme.spacingS),
          Text(course.description, style: AppTheme.bodyMedium),
          Spacer(),
          LinearProgressIndicator(value: course.progress),
        ],
      ),
    ),
  ),
)
```

### Bottom Navigation Pattern

```dart
Scaffold(
  body: PageView(
    controller: pageController,
    children: [WorldScreen(), BooksScreen(), ProfileScreen()],
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (index) => pageController.animateToPage(index),
    items: [/* navigation items */],
  ),
)
```

### Progressive Text Reveal Pattern

```dart
AnimatedBuilder(
  animation: animationController,
  builder: (context, child) => Opacity(
    opacity: animationController.value,
    child: Text(textSegment),
  ),
)
```
