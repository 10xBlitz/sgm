# Flutter-Specific Instructions for GitHub Copilot

This document provides Flutter-specific guidance for GitHub Copilot to help it generate more accurate and useful code suggestions for the Seoul Guide Medical app.

## Widget Structure

When suggesting widgets:
- Always prefer `const` constructors when possible
- Use named parameters for clarity
- Follow trailing comma convention for better formatting
- Group related parameters together

## StatelessWidget Template

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({
    super.key,
    required this.parameter1,
    this.parameter2 = defaultValue,
  });

  final Type parameter1;
  final Type? parameter2;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget implementation
    );
  }
}
```

## StatefulWidget Template

```dart
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({
    super.key,
    required this.requiredParam,
    this.optionalParam,
  });

  final Type requiredParam;
  final Type? optionalParam;

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // State variables here
  
  @override
  void initState() {
    super.initState();
    // Initialization code
  }

  @override
  void dispose() {
    // Cleanup code
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget implementation
    );
  }
}
```

## Responsive Design

Always consider responsive design by:
- Using `MediaQuery` to adapt to screen size
- Using `LayoutBuilder` for constraints-based layouts
- Using flexible widgets like `Expanded` and `Flexible`
- Using `FractionallySizedBox` for proportional sizing

```dart
// Example of responsive pattern
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else {
      return DesktopLayout();
    }
  },
),
```

## Async Widget Building

When building widgets that depend on async data:

```dart
FutureBuilder<DataType>(
  future: futureData,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data == null) {
      return const Center(child: Text('No data available'));
    }
    
    final data = snapshot.data!;
    return YourWidget(data: data);
  },
),
```

## Error Handling

Always include proper error handling in async operations:

```dart
try {
  await someAsyncOperation();
} on SpecificException catch (e) {
  // Handle specific exception
} on AnotherException catch (e) {
  // Handle another specific exception
} catch (e) {
  // Generic error handling
} finally {
  // Cleanup code that always runs
}
```

## Navigation

For navigation use go_router with screen's routeName constant:

```dart
// Navigate to a new screen
context.go(TargetScreen.routeName);

// Navigate with parameters
context.go('${TargetScreen.routeName}/$paramValue');

// Navigate and replace current screen
context.replace(TargetScreen.routeName);

// Go back
context.pop();
```

## Theme Usage

Always use the app's theme system rather than hardcoding colors and styles:

```dart
// Good - Uses theme
Text(
  'Some text',
  style: Theme.of(context).textTheme.bodyLarge,
),

Container(
  color: Theme.of(context).colorScheme.surface,
  // ...
),

// Bad - Hardcoded styles
Text(
  'Some text',
  style: TextStyle(fontSize: 16, color: Colors.black),
),
```

## Accessibility

Consider accessibility in all widget suggestions:
- Use semantic labels
- Ensure sufficient contrast
- Use appropriate text scaling

```dart
// Example of good accessibility practice
IconButton(
  icon: const Icon(Icons.add),
  onPressed: _handleAdd,
  tooltip: 'Add new item', // Provides accessible description
),

Image.asset(
  'assets/logo.png',
  semanticLabel: 'Company logo', // Provides screen reader description
),
```

## Korean Text Support

Since this app uses Korean text with NotoSansKR font:
- Always ensure text widgets use 'NotoSansKR' font family
- Consider text direction and overflow for Korean characters
- Use proper line height for Korean text (typically 1.5× fontSize)

```dart
Text(
  '안녕하세요',
  style: TextStyle(
    fontFamily: 'NotoSansKR',
    height: 1.5,
  ),
  overflow: TextOverflow.ellipsis,
),
```